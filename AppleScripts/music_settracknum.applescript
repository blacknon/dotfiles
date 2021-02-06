#!/usr/bin/osascript
--  Copyright(c) 2021 Blacknon. All rights reserved.
--  Use of this source code is governed by an MIT license
--  that can be found in the LICENSE file.
--
-- User: blacknon
-- Description: iTunes�̑I�𒆂̋Ȃ�track number��A�ԂŃZ�b�g���Ă���apple script.
-- Base: https://gist.github.com/aurora/793108

-- ���ݓ��̏����擾
set today_year to year of (current date) -- 2020
set today_month to month of (current date) as number -- 1
set today_month to text -2 thru -1 of ("0" & today_month) -- 01
set today_day to day of (current date) -- 3
set today_day to text -2 thru -1 of ("0" & today_day) -- 03

-- iTunes���Ăяo��
tell application "Music"
	-- ���ݑI�𒆂̃g���b�N���擾����
	set tracklist to selection
	set count_selection to count of tracklist
	log "selection: " & count_selection as string
	
	-- ���ݑI�𒆂̃g���b�N���ɉ����ď�����؂�ւ���
	if selection = {} then -- �I�𒆂̃g���b�N���Ȃ��ꍇ�A���̎|��\�����ďI��
		display dialog "No tracks selected." buttons {"Cancel"} default button 1 with icon 1
		
	else -- �I�𒆂̃g���b�N������ꍇ
		-- repeat�ŏ���
		repeat with i from 1 to count of tracklist
			-- �I�𒆂̏����擾
			set entry to item i of tracklist
			set track number of entry to i
			set comment of entry to ""
		end repeat
		
	end if
	
end tell






