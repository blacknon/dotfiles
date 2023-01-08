#!/usr/bin/osascript
--  Copyright(c) 2021 Blacknon. All rights reserved.
--  Use of this source code is governed by an MIT license
--  that can be found in the LICENSE file.
--
-- User: blacknon
-- Description: iTunes�̑I�𒆂̃^�C�g�������A`~/Work/YYYYmm/YYYYmmdd/itunes.txt`�̃^�C�g���ɕϊ����Ă����X�N���v�g(`~/Work/YYYYmm/YYYYmmdd/itunes.txt`��Shift-JIS�ŋL�q����K�v������̂Œ���)
-- Base: https://gist.github.com/aurora/793108

-- ���ݓ��̏����擾
set today_year to year of (current date) -- 2020
set today_month to month of (current date) as number -- 1
set today_month to text -2 thru -1 of ("0" & today_month) -- 01
set today_day to day of (current date) -- 3
set today_day to text -2 thru -1 of ("0" & today_day) -- 03

-- ANSI Color Code���w��
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

-- iTunes���Ăяo��
tell application "Music"
    -- ���ݑI�𒆂̃g���b�N���擾����
    set tracklist to selection
    set count_selection to count of tracklist
    log "selection: " & count_selection as string

    -- ���ݑI�𒆂̃g���b�N���ɉ����ď�����؂�ւ���
    if selection = {} then -- �I�𒆂̃g���b�N���Ȃ��ꍇ�A���̎|��\�����ďI��
        display dialog "No tracks selected." buttons {"Cancel"} default button 1 with icon 1

    -- �I�𒆂̃g���b�N������ꍇ
    else
        -- �����̍�Ɨp�f�B���N�g����PATH(~/Work/YYYYmm/YYYYmmdd/)���擾
        set today_dir to (the POSIX path of (path to home folder)) & "Work/" & today_year & today_month & "/" & today_year & today_month & today_day & "/" as string

        -- �u��list�̃t�@�C��PATH(~/Work/YYYYmm/YYYYmmdd/itunes.txt)���擾
        set replace_list_file to today_dir & "itunes.txt" as string

        -- �u��list�̓��e���擾
        set replace_list to read replace_list_file using delimiter linefeed

        -- �u��list�̍s�����擾
        set count_replace_list to count of replace_list
        log "�u��list: " & count_replace_list as string

        -- �u��list�̌�����Selection�̌����������ꍇ
        if count_replace_list = count_selection then
            -- repeat�ŏ���
            repeat with i from 1 to count of tracklist
                -- �I�𒆂̏����擾
                set entry to item i of tracklist

                -- ���^�C�g�����擾
                set old_name to name of entry

                -- �V�^�C�g�����擾
                set new_name to item i of replace_list

                set show_text to ansi_fg_color_purple & old_name & ansi_color_none & "=>" & ansi_fg_color_cyan & new_name & ansi_color_none
                log show_text

                set name of entry to new_name
                set comment of entry to ""


            end repeat


        else
            -- �u��list�̌�����Selection�̌������Ⴄ�ꍇ
            display dialog "�u��list�ƑI������Ă���Ȃ̌������قȂ�܂�" buttons {"OK"} default button 1
        end if

    end if

end tell
