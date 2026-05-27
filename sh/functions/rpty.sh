# rpty_functions_v3.sh
# Lightweight remote PTY session keeper/attach helper.
# Requires: bash, python3 on remote host.

: "${RPTY_RUNTIME_DIR:=${XDG_RUNTIME_DIR:-/tmp}/rpty-${USER}}"
: "${RPTY_BANNER:=1}"
: "${RPTY_ATTACH_POLICY:=first}"   # first|last
: "${RPTY_DETACH_KEY:=0x1d}"       # default Ctrl-]

mkdir -p "$RPTY_RUNTIME_DIR" 2>/dev/null || true

_rpty_pyfile() {
  local f="$RPTY_RUNTIME_DIR/.rpty_impl.py"
  if [[ ! -f "$f" ]]; then
    cat > "$f" <<'PY'
import errno, fcntl, json, os, pty, select, signal, socket, struct, subprocess, sys, termios, time

RUNTIME = os.environ.get("RPTY_RUNTIME_DIR") or f"{os.environ.get('XDG_RUNTIME_DIR') or '/tmp'}/rpty-{os.environ.get('USER','user')}"
BANNER = os.environ.get("RPTY_BANNER", "1") != "0"
DETACH = os.environ.get("RPTY_DETACH_KEY", "0x1d")


def _parse_detach(v: str) -> bytes:
    v = (v or "0x1d").strip()
    if v.startswith("0x"):
        return bytes([int(v, 16)])
    if v.startswith("^^") and len(v) >= 3:
        c = v[2]
        if c == '?':
            return b'\x7f'
        return bytes([ord(c.upper()) & 0x1f])
    if len(v) == 1:
        return v.encode()
    return b'\x1d'

DETACH_BYTES = _parse_detach(DETACH)


def sp(name, kind):
    return os.path.join(RUNTIME, f"{name}.{kind}")


def valid_name(name):
    return name and all(c.isalnum() or c in "._-" for c in name)


def load_json(path, default=None):
    try:
        with open(path) as f:
            return json.load(f)
    except Exception:
        return default


def save_json(path, data):
    tmp = path + ".tmp"
    with open(tmp, "w") as f:
        json.dump(data, f)
    os.replace(tmp, path)


def pid_alive(pid):
    if not pid:
        return False
    try:
        os.kill(int(pid), 0)
        return True
    except Exception:
        return False


def cleanup_one(name):
    meta = load_json(sp(name, "meta"), {}) or {}
    pid = meta.get("keeper_pid")
    if pid_alive(pid):
        return False
    for ext in ("sock", "ctrl", "meta", "pid", "rc", "wrap"):
        p = sp(name, ext)
        try:
            os.unlink(p)
        except FileNotFoundError:
            pass
        except IsADirectoryError:
            pass
    return True


def cleanup_all():
    os.makedirs(RUNTIME, exist_ok=True)
    seen = set()
    for fn in os.listdir(RUNTIME):
        if "." not in fn:
            continue
        name = fn.rsplit(".", 1)[0]
        if name in seen:
            continue
        seen.add(name)
        cleanup_one(name)


def set_winsz(fd, rows, cols):
    fcntl.ioctl(fd, termios.TIOCSWINSZ, struct.pack("HHHH", rows, cols, 0, 0))


def get_winsz(fd):
    try:
        buf = fcntl.ioctl(fd, termios.TIOCGWINSZ, struct.pack("HHHH", 0, 0, 0, 0))
        return struct.unpack("HHHH", buf)[:2]
    except Exception:
        return (24, 80)


class RawTTY:
    def __init__(self, fd):
        self.fd = fd
        self.old = None
    def __enter__(self):
        if not os.isatty(self.fd):
            raise termios.error(25, "Inappropriate ioctl for device")
        self.old = termios.tcgetattr(self.fd)
        tty = termios.tcgetattr(self.fd)
        tty[3] = tty[3] & ~(termios.ECHO | termios.ICANON | termios.IEXTEN | termios.ISIG)
        tty[1] = tty[1] & ~termios.OPOST
        tty[0] = tty[0] & ~(termios.IXON | termios.ICRNL | termios.BRKINT | termios.INPCK | termios.ISTRIP)
        tty[2] = tty[2] | termios.CS8
        tty[6][termios.VMIN] = 1
        tty[6][termios.VTIME] = 0
        termios.tcsetattr(self.fd, termios.TCSANOW, tty)
        return self
    def __exit__(self, exc_type, exc, tb):
        if self.old is not None:
            termios.tcsetattr(self.fd, termios.TCSANOW, self.old)


def daemonize():
    if os.fork() > 0:
        os._exit(0)
    os.setsid()
    if os.fork() > 0:
        os._exit(0)
    devnull = os.open('/dev/null', os.O_RDWR)
    for fd in (0, 1, 2):
        try:
            os.dup2(devnull, fd)
        except OSError:
            pass
    if devnull > 2:
        os.close(devnull)


def keeper(name, argv):
    os.makedirs(RUNTIME, exist_ok=True)
    cleanup_one(name)
    msock = sp(name, 'sock')
    csock = sp(name, 'ctrl')
    meta_path = sp(name, 'meta')
    pid_path = sp(name, 'pid')

    master, slave = pty.openpty()
    env = os.environ.copy()
    proc = subprocess.Popen(argv, stdin=slave, stdout=slave, stderr=slave, start_new_session=True, env=env, close_fds=True)
    os.close(slave)

    ds = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    ds.bind(msock)
    os.chmod(msock, 0o600)
    ds.listen(8)
    ds.setblocking(False)

    cs = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    cs.bind(csock)
    os.chmod(csock, 0o600)
    cs.listen(8)
    cs.setblocking(False)

    meta = {
        'name': name,
        'keeper_pid': os.getpid(),
        'child_pid': proc.pid,
        'cmd': argv,
        'attached_rw': False,
        'rw_client_pid': None,
        'ro_count': 0,
        'created': time.time(),
    }
    save_json(meta_path, meta)
    with open(pid_path, 'w') as f:
        f.write(str(os.getpid()))

    clients = {}  # sock -> {'mode': 'rw'|'ro'}
    rw = None

    while True:
        if proc.poll() is not None:
            break
        rlist = [ds, cs, master] + list(clients)
        try:
            ready, _, _ = select.select(rlist, [], [], 0.5)
        except InterruptedError:
            continue

        for obj in ready:
            if obj is ds:
                conn, _ = ds.accept()
                try:
                    hello = conn.recv(4096)
                    req = json.loads(hello.decode() or '{}')
                except Exception:
                    conn.close(); continue
                mode = req.get('mode', 'rw')
                force = bool(req.get('force', False))
                rows = int(req.get('rows', 24))
                cols = int(req.get('cols', 80))
                client_pid = req.get('client_pid')
                if mode == 'rw':
                    if rw is not None:
                        if force:
                            try: rw.sendall(b'{"event":"detached-by-force"}\n')
                            except Exception: pass
                            try: rw.close()
                            except Exception: pass
                            clients.pop(rw, None)
                            rw = None
                        else:
                            conn.sendall(b'{"ok":false,"reason":"busy"}\n')
                            conn.close(); continue
                    rw = conn
                    meta['attached_rw'] = True
                    meta['rw_client_pid'] = client_pid
                    set_winsz(master, rows, cols)
                else:
                    meta['ro_count'] = int(meta.get('ro_count', 0)) + 1
                save_json(meta_path, meta)
                conn.sendall(b'{"ok":true}\n')
                conn.setblocking(False)
                clients[conn] = {'mode': mode}
            elif obj is cs:
                conn, _ = cs.accept()
                try:
                    msg = conn.recv(4096)
                    req = json.loads(msg.decode() or '{}')
                    if req.get('op') == 'winsz' and rw is not None:
                        set_winsz(master, int(req.get('rows', 24)), int(req.get('cols', 80)))
                    elif req.get('op') == 'force-detach' and rw is not None:
                        try: rw.sendall(b'{"event":"detached-by-force"}\n')
                        except Exception: pass
                        try: rw.close()
                        except Exception: pass
                        clients.pop(rw, None)
                        rw = None
                        meta['attached_rw'] = False
                        meta['rw_client_pid'] = None
                        save_json(meta_path, meta)
                    conn.sendall(b'{"ok":true}\n')
                except Exception:
                    pass
                conn.close()
            elif obj == master:
                try:
                    data = os.read(master, 65536)
                except OSError:
                    data = b''
                if not data:
                    proc.terminate()
                    break
                dead = []
                for c, info in clients.items():
                    try:
                        c.sendall(data)
                    except Exception:
                        dead.append(c)
                for c in dead:
                    mode = clients.get(c, {}).get('mode')
                    clients.pop(c, None)
                    try: c.close()
                    except Exception: pass
                    if c is rw:
                        rw = None
                        meta['attached_rw'] = False
                        meta['rw_client_pid'] = None
                    elif mode == 'ro' and meta.get('ro_count', 0) > 0:
                        meta['ro_count'] -= 1
                    save_json(meta_path, meta)
            else:
                c = obj
                info = clients.get(c, {})
                try:
                    data = c.recv(65536)
                except Exception:
                    data = b''
                if not data:
                    mode = info.get('mode')
                    clients.pop(c, None)
                    try: c.close()
                    except Exception: pass
                    if c is rw:
                        rw = None
                        meta['attached_rw'] = False
                        meta['rw_client_pid'] = None
                    elif mode == 'ro' and meta.get('ro_count', 0) > 0:
                        meta['ro_count'] -= 1
                    save_json(meta_path, meta)
                    continue
                if info.get('mode') == 'rw':
                    try:
                        os.write(master, data)
                    except Exception:
                        pass

    for c in list(clients):
        try: c.close()
        except Exception: pass
    for p in (msock, csock, meta_path, pid_path):
        try: os.unlink(p)
        except Exception: pass
    try: os.close(master)
    except Exception: pass
    os._exit(proc.wait() if proc.poll() is not None else 0)


def start(name, argv):
    if not valid_name(name):
        print('invalid session name', file=sys.stderr); return 2
    os.makedirs(RUNTIME, exist_ok=True)
    cleanup_one(name)
    daemonize()
    keeper(name, argv)
    return 0


def wait_ready(name, timeout=5.0):
    end = time.time() + timeout
    while time.time() < end:
        if os.path.exists(sp(name, 'sock')) and os.path.exists(sp(name, 'meta')):
            return True
        time.sleep(0.05)
    return False


def list_sessions():
    cleanup_all()
    os.makedirs(RUNTIME, exist_ok=True)
    names = sorted({fn.rsplit('.',1)[0] for fn in os.listdir(RUNTIME) if '.' in fn})
    for name in names:
        m = load_json(sp(name, 'meta'), {}) or {}
        state = 'attached' if m.get('attached_rw') else 'idle'
        ro = m.get('ro_count', 0)
        pid = m.get('keeper_pid')
        cmd = ' '.join(m.get('cmd') or [])
        print(f"{name}\tpid={pid}\tstate={state}\tro={ro}\tcmd={cmd}")
    return 0


def kill_session(name):
    if not valid_name(name):
        print('invalid session name', file=sys.stderr); return 2
    meta = load_json(sp(name, 'meta'), {}) or {}
    pid = meta.get('keeper_pid')
    if pid_alive(pid):
        try: os.kill(int(pid), signal.SIGTERM)
        except Exception: pass
        time.sleep(0.1)
        if pid_alive(pid):
            try: os.kill(int(pid), signal.SIGKILL)
            except Exception: pass
    cleanup_one(name)
    print(name)
    return 0


def ctrl_send(name, obj):
    s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    s.connect(sp(name, 'ctrl'))
    s.sendall(json.dumps(obj).encode())
    try: s.recv(4096)
    except Exception: pass
    s.close()


def attach(name, mode='rw', force=False, wait=False):
    if not valid_name(name):
        print('invalid session name', file=sys.stderr); return 2
    cleanup_one(name)
    sockp = sp(name, 'sock')
    if not os.path.exists(sockp):
        print('no such session', file=sys.stderr); return 1
    interactive = os.isatty(0) and os.isatty(1)
    if mode == 'rw' and not interactive:
        print('stdin is not a tty; use an interactive shell or rattach -r', file=sys.stderr)
        return 1

    while True:
        s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        try:
            s.connect(sockp)
        except FileNotFoundError:
            print('no such session', file=sys.stderr); return 1
        rows, cols = get_winsz(0 if interactive else 1)
        hello = {'mode': mode, 'force': force, 'rows': rows, 'cols': cols, 'client_pid': os.getpid()}
        s.sendall(json.dumps(hello).encode())
        resp = b''
        while not resp.endswith(b'\n'):
            chunk = s.recv(4096)
            if not chunk:
                break
            resp += chunk
        try:
            obj = json.loads(resp.decode() or '{}')
        except Exception:
            print('attach handshake failed', file=sys.stderr); s.close(); return 1
        if obj.get('ok'):
            break
        if obj.get('reason') == 'busy' and wait:
            s.close(); time.sleep(0.25); force = False; continue
        print('session busy', file=sys.stderr); s.close(); return 1

    if BANNER:
        msg = f"[rpty:{name}] attached ({mode})"
        if mode == 'rw':
            msg += f"; detach={DETACH_BYTES!r}"
        os.write(2, (msg + "\n").encode())

    def on_winch(signum, frame):
        if interactive and mode == 'rw':
            r, c = get_winsz(0)
            try: ctrl_send(name, {'op':'winsz', 'rows': r, 'cols': c})
            except Exception: pass
    old_winch = signal.signal(signal.SIGWINCH, on_winch)
    try:
        if mode == 'ro':
            while True:
                data = s.recv(65536)
                if not data:
                    break
                os.write(1, data)
            return 0
        else:
            with RawTTY(0):
                on_winch(None, None)
                while True:
                    ready, _, _ = select.select([0, s], [], [])
                    if 0 in ready:
                        data = os.read(0, 1024)
                        if not data:
                            break
                        if DETACH_BYTES in data:
                            idx = data.index(DETACH_BYTES)
                            if idx:
                                s.sendall(data[:idx])
                            break
                        s.sendall(data)
                    if s in ready:
                        data = s.recv(65536)
                        if not data:
                            break
                        os.write(1, data)
            return 0
    finally:
        signal.signal(signal.SIGWINCH, old_winch)
        try: s.close()
        except Exception: pass
        # Leave the local terminal in a clean state for the parent shell prompt.
        if interactive and mode == 'rw':
            try:
                os.write(1, b"\r\n")
            except Exception:
                pass


def main(argv):
    if len(argv) < 2:
        print('usage: impl.py <start|wait-ready|attach|list|kill|cleanup> ...', file=sys.stderr)
        return 2
    op = argv[1]
    if op == 'start':
        if len(argv) < 4:
            print('usage: impl.py start NAME CMD...', file=sys.stderr); return 2
        return start(argv[2], argv[3:])
    if op == 'wait-ready':
        return 0 if wait_ready(argv[2]) else 1
    if op == 'attach':
        mode='rw'; force=False; wait=False
        i=2
        while i < len(argv) and argv[i].startswith('--'):
            if argv[i] == '--ro': mode='ro'
            elif argv[i] == '--force': force=True
            elif argv[i] == '--wait': wait=True
            i += 1
        return attach(argv[i], mode=mode, force=force, wait=wait)
    if op == 'list':
        return list_sessions()
    if op == 'kill':
        return kill_session(argv[2])
    if op == 'cleanup':
        cleanup_all(); return 0
    print('unknown op', file=sys.stderr); return 2

if __name__ == '__main__':
    sys.exit(main(sys.argv))
PY
    chmod 600 "$f"
  fi
  printf '%s\n' "$f"
}

_rpty_require_python() {
  command -v python3 >/dev/null 2>&1 || { echo "python3 is required" >&2; return 1; }
}

rcleanup() {
  _rpty_require_python || return 1
  local py; py=$(_rpty_pyfile)
  RPTY_RUNTIME_DIR="$RPTY_RUNTIME_DIR" RPTY_BANNER="$RPTY_BANNER" RPTY_DETACH_KEY="$RPTY_DETACH_KEY" \
    python3 "$py" cleanup
}

rlist() {
  _rpty_require_python || return 1
  local py; py=$(_rpty_pyfile)
  RPTY_RUNTIME_DIR="$RPTY_RUNTIME_DIR" RPTY_BANNER="$RPTY_BANNER" RPTY_DETACH_KEY="$RPTY_DETACH_KEY" \
    python3 "$py" list
}


_rpty_shell_state() {
  {
    printf 'cd %q\n' "$PWD"
    export -p 2>/dev/null || true
    alias -p 2>/dev/null || true
    declare -pf 2>/dev/null || true
    shopt -p 2>/dev/null || true
    set +o 2>/dev/null || true
  }
}

_rpty_build_inherit_files() {
  local name="$1"
  local rcfile="$RPTY_RUNTIME_DIR/${name}.rc"
  local wrapfile="$RPTY_RUNTIME_DIR/${name}.wrap"
  umask 077
  cat > "$rcfile" <<'EOFRC'
# rpty inherited shell state
[[ -r ~/.bashrc ]] && source ~/.bashrc
EOFRC
  _rpty_shell_state >> "$rcfile"
  cat > "$wrapfile" <<EOFWRAP
#!/usr/bin/env bash
set +e
export RPTY_INHERITED=1
if [[ \$# -gt 0 ]]; then
  exec bash --noprofile --rcfile $(printf '%q' "$rcfile") -ic 'exec "$@"' bash "\$@"
else
  exec bash --noprofile --rcfile $(printf '%q' "$rcfile") -i
fi
EOFWRAP
  chmod 600 "$rcfile"
  chmod 700 "$wrapfile"
  printf '%s\n%s\n' "$rcfile" "$wrapfile"
}

rnew() {
  _rpty_require_python || return 1
  local inherit=0
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -I|--inherit) inherit=1; shift ;;
      --) shift; break ;;
      -*) echo "unknown option: $1" >&2; return 2 ;;
      *) break ;;
    esac
  done
  local name="$1"; shift || true
  [[ -n "$name" ]] || { echo "usage: rnew [-I] NAME [CMD ...]" >&2; return 2; }
  local py; py=$(_rpty_pyfile)
  local cmd=("$@")
  local rcfile="" wrapfile=""
  if [[ $inherit -eq 1 ]]; then
    local files
    files=$(_rpty_build_inherit_files "$name") || return 1
    rcfile=$(printf '%s\n' "$files" | sed -n '1p')
    wrapfile=$(printf '%s\n' "$files" | sed -n '2p')
    if [[ ${#cmd[@]} -eq 0 ]]; then
      cmd=("$wrapfile")
    else
      cmd=("$wrapfile" "${cmd[@]}")
    fi
  elif [[ ${#cmd[@]} -eq 0 ]]; then
    cmd=("${SHELL:-/bin/bash}" -l)
  fi
  RPTY_RUNTIME_DIR="$RPTY_RUNTIME_DIR" RPTY_BANNER="$RPTY_BANNER" RPTY_DETACH_KEY="$RPTY_DETACH_KEY" \
    python3 "$py" start "$name" "${cmd[@]}"
  local rc=$?
  if [[ $rc -ne 0 ]]; then
    [[ -n "$rcfile" ]] && rm -f -- "$rcfile" "$wrapfile"
    return $rc
  fi
  if ! RPTY_RUNTIME_DIR="$RPTY_RUNTIME_DIR" python3 "$py" wait-ready "$name"; then
    echo "session failed to become ready" >&2
    [[ -n "$rcfile" ]] && rm -f -- "$rcfile" "$wrapfile"
    return 1
  fi
  printf '%s\n' "$name"
}

rattach() {
  _rpty_require_python || return 1
  local force=0 wait=0 ro=0
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -f|--force) force=1; shift ;;
      -w|--wait) wait=1; shift ;;
      -r|--readonly|--ro) ro=1; shift ;;
      --) shift; break ;;
      -*) echo "unknown option: $1" >&2; return 2 ;;
      *) break ;;
    esac
  done
  local name="$1"
  [[ -n "$name" ]] || { echo "invalid session name" >&2; return 2; }
  local py; py=$(_rpty_pyfile)
  local args=(attach)
  if [[ $ro -eq 1 ]]; then args+=(--ro); fi
  if [[ $force -eq 1 || ( $ro -eq 0 && "$RPTY_ATTACH_POLICY" == "last" ) ]]; then args+=(--force); fi
  if [[ $wait -eq 1 ]]; then args+=(--wait); fi
  args+=("$name")
  RPTY_RUNTIME_DIR="$RPTY_RUNTIME_DIR" RPTY_BANNER="$RPTY_BANNER" RPTY_DETACH_KEY="$RPTY_DETACH_KEY" \
    python3 "$py" "${args[@]}"
}

rkill() {
  _rpty_require_python || return 1
  local name="$1"
  [[ -n "$name" ]] || { echo "usage: rkill NAME" >&2; return 2; }
  local py; py=$(_rpty_pyfile)
  RPTY_RUNTIME_DIR="$RPTY_RUNTIME_DIR" RPTY_BANNER="$RPTY_BANNER" RPTY_DETACH_KEY="$RPTY_DETACH_KEY" \
    python3 "$py" kill "$name"
}
