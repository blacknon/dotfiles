
-- OSのコマンドを実行してその結果をstringで返すfunction
function exec_oscommand( command )
    local handle = io.popen(command , "r")
    local result = handle:read("*all")
    handle:close()

    return(result)
end


-- 区切りとして使っているbarの表示
function conky_print_infobar(title)
    return("${font arial black:size=20}${color1}"..title.."${color}INFORMATION${color2} ${hr 3}${color}${font}")
end


-- スペースでパディングするfunction
function conky_padding( format, number )
    return string.format( format, conky_parse( number ) )
end


-- 特定の文字列で区切ってテーブルとして返すfunction
function split( str, ts )
    -- 引数がないときは空tableを返す
    if ts == nil then return {} end

    local t = {} ;
    i=1
    for s in string.gmatch(str, "([^"..ts.."]+)") do
        t[i] = s
        i = i + 1
    end

    return t
end


-- -- System関係の情報を出力
function conky_system_info()
    local text = ""

    -- ユーザ名@ホスト名
    text = text.."${color9}${font arial black:size=32}${execi 3600 whoami}@${color2}${nodename}${color}${font}\n"

    -- Kernel,Uptimeの表示
    text = text.."${color}Kernel: ${alignr}${color9}${kernel} ${color}\n"
    text = text.."${color}Uptime: ${alignr}${color9}${uptime} ${color}\n"

    -- 現在のワークスペースの表示
    text = text.."${color}WorkSpace: ${alignr}${color2}${desktop} ${color}\n"

    -- バッテリーの数を確認
    local battery_num = exec_oscommand("ls -1d /sys/class/power_supply/BAT* | wc -l")

    -- バッテリーの状態について出力する
    for i = 0, battery_num - 1 do
        text = text.."${color}Battery "..i..": ${color2}${lua_parse padding %3.0f ${battery_percent BAT"..i.."}}% ${goto 180}(${color9}${battery_time BAT"..i.."}${color2}) ${goto 320}${battery_bar 10 BAT"..i.."}\n"
    end

    -- 時計の表示
    text = text.."${goto 20}${voffset 0}${font arial black:size=64}${color2}${time %H:%M}${voffset -40}${goto 240}${font arial black:size=24}${color9}${time %Y年%m月}${color}${color2}${time %d}${color9}日${voffset 35}${goto 240}${font arial black:size=24}        ${color2}${time %a}${color9}曜日${font}${color}\n"

    return(text)
end


-- CPUの型番などを出力
function conky_cpu_info()
    -- textの初期化
    local text = ""

    -- CPUのモデルを出力
    local text = text.."Model:\n"
    local text = text.."${color9}${execi 3600 sed -ne '/model name/s/model name.*: //p' /proc/cpuinfo | uniq}\n"

    return(text)
end

-- CPUの各コアの使用率を出力
function conky_cpu_bar()
    -- textの初期化
    local text = ""

    -- cpuのコア数を取得
    local cpu_core_num = exec_oscommand("grep '^model name' /proc/cpuinfo | wc -l")

    -- CPUのグラフを出力
    for i = 1, cpu_core_num do
        text = text..'${color9}${goto 15}CPU '..i..': ${goto 90}${color2}${lua_parse padding %3.0f ${cpu cpu'..i..'}}% ${goto 160}${color2}${cpubar cpu'..i..' 18}\n'
    end

    return(text)
end

-- メモリの使用率を出力する
function conky_memory_info()
    local text=""

    -- RAM
    local text = text.."${color}RAM:  ${color2}${lua_parse padding %3.0f ${memperc}}% ${alignr}${color9}${mem} / ${memmax}\n"
    local text = text.."${color2}${membar 6}${color}\n"

    -- SWAP
    local text = text.."${color}SWAP: ${color2}${lua_parse padding %3.0f ${swapperc}}% ${alignr}${color9}${swap} / ${swapmax}\n"
    local text = text.."${color2}${swapbar 6}${color}\n"

    -- bufferd/cached
    local text = text.."${goto 170}${color9}buffers:${color} ${buffers} ${alignr}${color9}cached:${color} ${cached}\n"

    return(text)
end


-- Networkの使用率等を出力する
function conky_network_info()
    -- textの初期化
    local text = ""

    -- 現在のグローバルIPの表示
    local text = text.."${color}GlobalIP : ${alignr}${color9}${execi 600 curl globalip.me}${color}\n"

    -- NICの一覧を取得
    local nic_list = exec_oscommand("ip -f inet -o addr show | awk -F'[\t ]' '{print $2}'")
    local nic_table = split(nic_list,"\n")


    for key, value in pairs(nic_table) do
        local nic = value
        if (string.len(nic) >= 8) then
            nic = string.sub(nic, 1, 6)
            nic = nic..".."
        end
        text = text.."${color}"..nic..":  ${color2}${goto 100}${addr "..value.."}"
        text = text.."${color9}${goto 280}${downspeed ${lua_parse padding %5s "..value.."}}/s ${goto 360}${upspeed ${lua_parse padding %5s "..value.."}}/s${color}\n"
    end

    return(text)
end


-- FileSystemの情報を出力する
function conky_fs_info()
    -- textの初期化
    local text = ""

    -- FileSystemの一覧を取得
    local fs_list = exec_oscommand("df -x tmpfs -x devtmpfs -x vfat --output=source,target | sed 1d")
    local fs_table = split(fs_list, "\n")

    for key, value in pairs(fs_table) do
        -- スペースで分割
        local value_table = split(value," ")
        local path = value_table[1]
        local mount = value_table[2]

        -- 1st line
        text = text.."${color}"..path.."[${color9}"..mount.."${color}]: "
        text = text.."${alignr}${color2}${lua_parse padding %3.0f ${fs_used_perc "..mount.."}}%\n"

        -- 2nd line
        text = text.."${color9}TYPE: ${color2}${fs_type "..mount.."}${color}${alignr}${color9}${fs_used "..mount.."}${color}/${color9}${fs_size "..mount.."}${color}\n"

        -- 3rd line
        text = text.."${goto 30}${color2}${fs_bar 12,355 "..mount.."}${color}\n"
    end

    return(text)
end


-- Diskの情報を出力する
function conky_disk_info()
    -- textの初期化
    local text = ""

    -- DISKの一覧を取得
    local disk_list = exec_oscommand("lsblk -ladnp -o NAME,MODEL")
    local disk_table = split(disk_list, "\n")

    for key, value in pairs(disk_table) do
        -- スペースで分割
        local value_table = split(value," ")
        local path = value_table[1]
        local model = value_table[2]

        -- 1st line
        text = text.."${color}"..path..": ${alignr}${color9}"..model.."\n"

        -- 2nd line
        text = text.."${color}DiskIO: ${color9}${lua_parse padding %5s ${diskio "..path.."}}${color}"
        text = text.."${goto 150}${color}Read:   ${color9}${lua_parse padding %5s ${diskio_read "..path.."}}${color}"
        text = text.."${goto 270}${color}Write:  ${color9}${lua_parse padding %5s ${diskio_write "..path.."}}${color}\n"
    end


    return(text)
end

-- リソースを使ってるプロセスについて出力する
function conky_top_info()
    -- textの初期化
    local text = ""

    -- header
    local text = text.."${color9}NAME${goto 200}PID${goto 270}CPU${goto 370}MEM\n"

    for i = 1,5 do
        text = text.."${top name "..i.."}${goto 200}${top pid "..i.."}${goto 270}${top cpu "..i.."}%${goto 370}${top mem "..i.."}%\n"
    end

    return(text)
end

-- 天候についての情報を取得させる
function conky_weather_info()
    -- textの初期化
    local text = ""

    -- json
    local json = require 'cjson'

    -- webへのアクセス用の定義
    local http = require "socket.http"
    local data = ""
    local function collect(chunk)
        if chunk ~= nil then
            data = data .. chunk
            end
        return true
    end

    -- API
    local baseurl = "http://api.openweathermap.org/data/2.5/weather"
    local apikey = "5ebfbf16450823a0e8be0cbc72f5773d"
    local place = "Tokyo,jp"
    local target = baseurl.."?q="..place.."&APPID="..apikey.."&units=metric"
    local iconurl = "http://openweathermap.org/img/wn/10d@2x.png"

    -- APIへアクセス
    local ok, statusCode, headers, statusText = http.request {
        method = "GET",
        url = target,
        sink = collect
    }

    -- text = json.decode(data)
    local weather_data = json.decode(data)
    local name = weather_data.name
    local icon = weather_data.weather[1].icon
    local temp = weather_data.main.temp
    local temp_max = weather_data.main.temp_max
    local temp_min = weather_data.main.temp_min
    local humidity = weather_data.main.humidity

    -- 現在の気温
    text = text.."${color2}${voffset 0}${font arial black:size=60}"..temp.."${font arial black:size=28}${color9}℃"

    -- 都市名
    text = text.."${voffset -33}${color9}${alignr}${font arial black:size=28}"..name.."${color}\n"

    -- 最高・最低気温
    text = text.."${voffset 10}${color}${font}最高気温:${color9}"..temp_max.."${color}℃ 最低気温:${color9}"..temp_min.."${color}℃\n"

    -- 湿度
    text = text.."${color}湿度　　:${color9}${lua_parse padding %3.0f "..humidity.."}${color}%"

    -- 現在の天気(アイコン)
    text = text.."${image ~/dotfiles/img/icon/weather/"..icon..".png -s 80x80 -p 310,80}"

    return(text)
end