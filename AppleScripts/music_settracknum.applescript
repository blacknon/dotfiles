#!/usr/bin/osascript
--  Copyright(c) 2021 Blacknon. All rights reserved.
--  Use of this source code is governed by an MIT license
--  that can be found in the LICENSE file.
--
-- User: blacknon
-- Description: iTunesの選択中の曲にtrack numberを連番でセットしていくapple script.
-- Base: https://gist.github.com/aurora/793108

-- 現在日の情報を取得
set today_year to year of (current date) -- 2020
set today_month to month of (current date) as number -- 1
set today_month to text -2 thru -1 of ("0" & today_month) -- 01
set today_day to day of (current date) -- 3
set today_day to text -2 thru -1 of ("0" & today_day) -- 03

-- iTunesを呼び出す
tell application "Music"
	-- 現在選択中のトラックを取得する
	set tracklist to selection
	set count_selection to count of tracklist
	log "selection: " & count_selection as string
	
	-- 現在選択中のトラック数に応じて処理を切り替える
	if selection = {} then -- 選択中のトラックがない場合、その旨を表示して終了
		display dialog "No tracks selected." buttons {"Cancel"} default button 1 with icon 1
		
	else -- 選択中のトラックがある場合
		-- repeatで処理
		repeat with i from 1 to count of tracklist
			-- 選択中の情報を取得
			set entry to item i of tracklist
			set track number of entry to i
			set comment of entry to ""
		end repeat
		
	end if
	
end tell






