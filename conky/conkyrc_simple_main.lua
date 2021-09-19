-- メイン(右端)に表示するConky
-- Conkyの設定内容
conky.config = {
    alignment = 'top_right', -- 右上に合わせる
    gap_x = 5, -- 横位置の調整
    gap_y = 30, -- 縦位置の調整

    default_color = 'white',
    default_outline_color = 'white',
    default_shade_color = 'gray',

    color1 = 'green',
    color2 = 'lightgreen',
    color3 = 'cyan',
    color4 = 'orange',
    color9 = 'gray',

    draw_borders = false,
    draw_graph_borders = false,
    draw_outline = false,
    draw_shades = false,

    update_interval = 1.0, -- 表示の更新間隔(秒)
    uppercase = false, -- 強制大文字変換を無効化

    own_window = true,
    own_window_class = 'Conky',
    own_window_type = 'desktop',
    own_window_hints = 'undecorated,below,skip_taskbar,skip_pager,sticky',
    own_window_transparent = false,
    own_window_argb_visual = true,
    own_window_argb_value = 160,

    use_xft = true,
    font = 'TakaoGothic:style=Regular:size=13',

    double_buffer = true,
    background = true,

    cpu_avg_samples = 4,
    net_avg_samples = 2,

    out_to_console = false,
    out_to_ncurses = false,
    out_to_stderr = false,
    out_to_x = true,
    extra_newline = false,

    stippled_borders = 0,

    use_spacer = 'none',
    show_graph_scale = false,
    show_graph_range = false,

    lua_load = '~/dotfiles/conky/conkyrc_simple_function.lua',
}


-- 表示するテキスト
conky.text = [[
# system関係
${lua_parse print_infobar SYSTEM}
${lua_parse system_info}
# CPU関係
${lua_parse print_infobar CPU}
## CPUの情報を取得
${lua_parse cpu_info}
${goto 15}${color2}${cpugraph cpu0 -l 60}
${lua_parse cpu_bar}
# メモリ関係
${lua_parse print_infobar MEMORY}
${lua_parse memory_info}
# プロセス関係
${lua_parse print_infobar TOP}
${lua_parse top_info}















]]
