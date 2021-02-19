# Copyright(c) 2021 Blacknon. All rights reserved.
# Use of this source code is governed by an MIT license
# that can be found in the LICENSE file.
# 【参考】
# https://github.com/ziti/uebersicht-calendar-widget/tree/66f539367a5afcd301300947bb88ef36f8169001

# Widget Settings
settings =
    colors:
      default: 'rgba(30, 30, 30, .75)'
      accent: 'rgba(0, 150, 255, .75)'
      background: 'rgba(255, 255, 255, .1)'
    shadows:
      box: '0 0 0 rgba(0, 0, 0, .5)'
      text: '0 0 0.625em rgba(0, 0, 0, .25)'

# 実行コマンド
command = 'cal -h && date "+%-m %-d %y"'
command: command

#Set this to true to enable previous and next month dates, or false to disable
otherMonths: true

refreshFrequency: 3600000

style: """
  top: 140px
  right: 10px
  color: #fff
  font-family: Helvetica Neue
  -webkit-backdrop-filter: blur(10px)
  table
    border-collapse: collapse
    table-layout: fixed
    background: #{ settings.colors.background }
    box-shadow: #{ settings.shadows.box }
    text-shadow: #{ settings.shadows.text }
    color: #{ settings.colors.default }
    border-radius: 1rem
  td
    text-align: center
    padding: 4px 6px
    text-shadow: 0 0 1px rgba(#000, 0.5)
  thead tr
    &:first-child td
      font-size: 24px
      font-weight: 100
    &:last-child td
      font-size: 11px
      padding-bottom: 10px
      font-weight: 500
  tbody td
    font-size: 12px
  .today
    font-weight: bold
    color: #{ settings.colors.accent }
    background: rgba(#f8f8f8, 0.8)
    border-radius: 50%
  .grey
    color: rgba(#C0C0C0, .7)
"""

render: -> """
  <table>
    <thead>
    </thead>
    <tbody>
    </tbody>
  </table>
"""


updateHeader: (rows, table) ->
  thead = table.find("thead")
  thead.empty()

  thead.append "<tr><td colspan='7'>#{rows[0]}</td></tr>"
  tableRow = $("<tr></tr>").appendTo(thead)
  daysOfWeek = rows[1].split(/\s+/)

  for dayOfWeek in daysOfWeek
    tableRow.append "<td>#{dayOfWeek}</td>"

updateBody: (rows, table) ->
  #Set to 1 to enable previous and next month dates, 0 to disable
  PrevAndNext = 1

  tbody = table.find("tbody")
  tbody.empty()

  rows.splice 0, 2
  rows.pop()

  today = rows.pop().split(/\s+/)
  month = today[0]
  date = today[1]
  year = today[2]

  lengths = [31, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30]
  if year%4 == 0
    lengths[2] = 29

  for week, i in rows
    days = week.split(/\s+/).filter((day) -> day.length > 0)
    tableRow = $("<tr></tr>").appendTo(tbody)

    if i == 0 and days.length < 7
      for j in [days.length...7]
        if @otherMonths == true
          k = 6 - j
          cell = $("<td>#{lengths[month-1]-k}</td>").appendTo(tableRow)
          cell.addClass("grey")
        else
          cell = $("<td></td>").appendTo(tableRow)

    for day in days
      day = day.replace(/\D/g, '')
      cell = $("<td>#{day}</td>").appendTo(tableRow)
      cell.addClass("today") if day == date

    if i != 0 and 0 < days.length < 7 and @otherMonths == true
      for j in [1..7-days.length]
        cell = $("<td>#{j}</td>").appendTo(tableRow)
        cell.addClass("grey")

update: (output, domEl) ->
  rows = output.split("\n")
  table = $(domEl).find("table")

  @updateHeader rows, table
  @updateBody rows, table
