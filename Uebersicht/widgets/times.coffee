# Copyright(c) 2021 Blacknon. All rights reserved.
# Use of this source code is governed by an MIT license
# that can be found in the LICENSE file.

# Widget Settings
settings =
    lang: 'en'
    militaryTime: true
    colors:
      default: 'rgba(30, 30, 30, .75)'
      accent: 'rgba(255, 255, 255, .75)'
      background: 'rgba(255, 255, 255, .1)'
    shadows:
      box: '0 0 0 rgba(0, 0, 0, .5)'
      text: '0 0 0.625em rgba(0, 0, 0, .25)'

# Locale Strings
locale =
  jp:
    weekdays: [
      '日'
      '月'
      '火'
      '水'
      '木'
      '金'
      '土'
    ]
  en:
    weekdays: [
      'Sun'
      'Mon'
      'Tue'
      'Wed'
      'Thu'
      'Fri'
      'Sat'
    ]


# 実行コマンド
command: ""

settings: settings
locale: locale

refreshFrequency: 1000

style: """
  width: 330px
  top: 10px
  right: 10px
  font-family: Helvetica
  font-size: 16px
  line-height: 1
  .container
    position: relative
    display: table
    height: 100%
    padding: 1rem 2rem
    border-radius: 1rem
    background: #{ settings.colors.background }
    box-shadow: #{ settings.shadows.box }
    text-shadow: #{ settings.shadows.text }
    overflow: hidden
    -webkit-backdrop-filter: blur(10px)
  .table
    position: relative
    display: table
    vertical-align: middle
    overflow: hidden
  .left
    float: left
  .txt-default
    color: #{ settings.colors.default }
  .txt-accent
    color: #{ settings.colors.accent }
    padding: 0.1rem
  .txt-small
    font-size: 2rem
    font-weight: 500
  .weekday
    padding: 0.8rem
  .txt-large
    font-size: 4rem
    font-weight: 700
  .divider
    display: block
    width: 1rem
    height: 100%
    margin: 0 1rem
    background: #{ settings.colors.accent }
    box-shadow: #{ settings.shadows.text }
"""

render: () -> """
  <div class='container'>
    <div class='table txt-small'>
      <span class='year txt-default'></span>
      <span class='txt-accent'>-</span>
      <span class='month txt-default'></span>
      <span class='txt-accent'>-</span>
      <span class='day txt-default'></span>
      <span class='weekday txt-accent'></span>

    </div>
    <div class='table'>
      <span class='hours txt-default txt-large '></span>
      <span class='txt-accent txt-large'>:</span>
      <span class='minutes txt-default txt-large'></span>
      <span class='txt-accent txt-large'>:</span>
      <span class='seconds txt-default txt-large'></span>
      <span class='suffix txt-default txt-small'></span>
    </div>

  </div>
"""

afterRender: (domEl) ->

update: (output, domEl) ->
  date = @getDate()

  $(domEl).find('.hours').text(date.hours)
  $(domEl).find('.minutes').text(date.minutes)
  $(domEl).find('.seconds').text(date.seconds)
  $(domEl).find('.suffix').text(date.suffix)
  $(domEl).find('.weekday').text(date.weekday)
  $(domEl).find('.day').text(date.day)
  $(domEl).find('.month').text(date.month)
  $(domEl).find('.year').text(date.year)

# Helper-Functions
zeroFill: (value) ->
  return ('0' + value).slice(-2)

getDate: () ->
  date = new Date()
  hour = date.getHours()

  suffix = (if (hour >= 12) then 'pm' else 'am') if (@settings.militaryTime is false)
  hour = (hour % 12 || 12) if (@settings.militaryTime is false)

  hours = @zeroFill(hour);
  minutes = @zeroFill(date.getMinutes())
  seconds = @zeroFill(date.getSeconds())
  weekday = @locale[@settings.lang].weekdays[date.getDay()]
  day = @zeroFill(date.getDate())
  month = @zeroFill(date.getMonth()+1)
  year = date.getFullYear()

  return {
    suffix: suffix
    hours: hours
    minutes: minutes
    seconds: seconds
    weekday: weekday
    day: day
    month: month
    year: year
  }
