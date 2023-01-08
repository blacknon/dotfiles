#!/usr/bin/osascript
--  Copyright(c) 2021 Blacknon. All rights reserved.
--  Use of this source code is governed by an MIT license
--  that can be found in the LICENSE file.
--
-- User: blacknon
-- Description: iTunesの選択中のタイトル名を、`~/Work/YYYYmm/YYYYmmdd/itunes.txt`のタイトルに変換していくスクリプト(`~/Work/YYYYmm/YYYYmmdd/itunes.txt`はShift-JISで記述する必要があるので注意)
-- Base: https://gist.github.com/aurora/793108

-- 現在日の情報を取得
set today_year to year of (current date) -- 2020
set today_month to month of (current date) as number -- 1
set today_month to text -2 thru -1 of ("0" & today_month) -- 01
set today_day to day of (current date) -- 3
set today_day to text -2 thru -1 of ("0" & today_day) -- 03

-- ANSI Color Codeを指定
set ansi_fg_color_red to system attribute "COLOR_RED"
set ansi_fg_color_green to system attribute "COLOR_GREEN"
set ansi_fg_color_orange to system attribute "COLOR_ORANGE"
set ansi_fg_color_blue to system attribute "COLOR_BLUE"
set ansi_fg_color_purple to system attribute "COLOR_PURPLE"
set ansi_fg_color_cyan to system attribute "COLOR_CYAN"
set ansi_fg_color_lgray to system attribute "COLOR_LGRAY"
set ansi_fg_color_dgray to system attribute "COLOR_DGRAY"
set ansi_fg_color_lred to system attribute "COLOR_LRED"
set ansi_fg_color_lgreen to system attribute "COLOR_LGREEN"
set ansi_fg_color_yellow to system attribute "COLOR_YELLOW"
set ansi_fg_color_lblue to system attribute "COLOR_LBLUE"
set ansi_fg_color_lpurple to system attribute "COLOR_LPURPLE"
set ansi_fg_color_lcyan to system attribute "COLOR_LCYAN"
set ansi_fg_color_white to system attribute "COLOR_WHITE"
set ansi_color_none to system attribute "COLOR_NONE"

-- iTunesを呼び出す
tell application "Music"
    -- 現在選択中のトラックを取得する
    set tracklist to selection
    set count_selection to count of tracklist
    log "selection: " & count_selection as string

    -- 現在選択中のトラック数に応じて処理を切り替える
    if selection = {} then -- 選択中のトラックがない場合、その旨を表示して終了
        display dialog "No tracks selected." buttons {"Cancel"} default button 1 with icon 1

    -- 選択中のトラックがある場合
    else
        -- 当日の作業用ディレクトリのPATH(~/Work/YYYYmm/YYYYmmdd/)を取得
        set today_dir to (the POSIX path of (path to home folder)) & "Work/" & today_year & today_month & "/" & today_year & today_month & today_day & "/" as string

        -- 置換listのファイルPATH(~/Work/YYYYmm/YYYYmmdd/itunes.txt)を取得
        set replace_list_file to today_dir & "itunes.txt" as string

        -- 置換listの内容を取得
        set replace_list to read replace_list_file using delimiter linefeed

        -- 置換listの行数を取得
        set count_replace_list to count of replace_list
        log "置換list: " & count_replace_list as string

        -- 置換listの件数とSelectionの件数が同じ場合
        if count_replace_list = count_selection then
            -- repeatで処理
            repeat with i from 1 to count of tracklist
                -- 選択中の情報を取得
                set entry to item i of tracklist

                -- 旧タイトルを取得
                set old_name to name of entry

                -- 新タイトルを取得
                set new_name to item i of replace_list

                set show_text to ansi_fg_color_purple & old_name & ansi_color_none & "=>" & ansi_fg_color_cyan & new_name & ansi_color_none
                log show_text

                set name of entry to new_name
                set comment of entry to ""


            end repeat


        else
            -- 置換listの件数とSelectionの件数が違う場合
            display dialog "置換listと選択されている曲の件数が異なります" buttons {"OK"} default button 1
        end if

    end if

end tell
