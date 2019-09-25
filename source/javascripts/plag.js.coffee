#= require 'vendor/hebrewDate'
#= require 'hebrewCalendar'

#= require 'hebrewDateExtensions'
#= require 'zmanim/zmanim'

maximums = {}

class PlagCell
  constructor: (hebrewDate, rowsPerCell, coordinates) ->
    @hebrewDate = hebrewDate
    @rowsPerCell = rowsPerCell
    @coordinates = coordinates
  hebrewDescription: -> @_hebrewDescription ?= "#{@hebrewDate.staticHebrewMonth.name} #{@hebrewDate.dayOfMonth}"
  gregorianDescription: -> @_gregorianDescription ?= moment(@hebrewDate.gregorianDate).format("D MMMM")
  plag: (zmanim, beginningOfDay, endOfDay) ->
    beginningOfDay = moment(beginningOfDay)
    lengthOfDay = (endOfDay - beginningOfDay) / 1000
    zmanim.shaaZemani(beginningOfDay, lengthOfDay, 10.75)
  eventList: -> @_eventList ?= (
    list = []
    zmanim = new Zmanim(@hebrewDate.gregorianDate, @coordinates)
    plags =
      'sunrise/sunset' : @plag(zmanim, zmanim.zmanim.sunrise, zmanim.zmanim.sunset)

      '16.1&deg;/Geonim': @plag(zmanim, zmanim.zmanim.magenAbrahamDawn, zmanim.setHaKochabimGeonim())
      '16.1&deg; / 8.5&deg;': @plag(zmanim, zmanim.zmanim.magenAbrahamDawn, zmanim.zmanim.setHaKochabim)
      '16.1&deg; / 16.1&deg;': @plag(zmanim, zmanim.zmanim.magenAbrahamDawn, zmanim.zmanim.magenAbrahamDusk)

      '72min/Geonim': @plag(zmanim, moment(zmanim.zmanim.sunrise).subtract(72, 'minutes'), zmanim.setHaKochabimGeonim())
      '72 min / 8.5&deg;': @plag(zmanim, moment(zmanim.zmanim.sunrise).subtract(72, 'minutes'), zmanim.zmanim.setHaKochabim)
      '72 min/72 min': @plag(zmanim, moment(zmanim.zmanim.sunrise).subtract(72, 'minutes'), moment(zmanim.zmanim.sunset).add(72, 'minutes'))

    for name, time of plags
      list.push("<small>#{name}</small>: #{time.seconds(60).millisecond(0).format("h:mm")}")
      if maximums[name]?
        timeToCompareToToday = moment(maximums[name][0]).year(time.year()).month(time.month()).date(time.date())
        if timeToCompareToToday.isBefore(time)
          maximums[name] = [time]
        else if !timeToCompareToToday.isAfter(time)
          maximums[name].push(time)
      else
        maximums[name] = [time]
    list
  )
  content: ->
    events = @eventList().join("<br>")
    newLines = events.match(/<br>/g)?.length ? 0
    placeholderCount = @rowsPerCell - 2 - newLines
    try
      placeholders = "<br>".repeat placeholderCount
    catch RangeError
      alert "#{newLines + 1} rows of events for #{@gregorianDescription()}"
      placeholders = ""
    """
      <td>
        #{placeholders}
        #{events}
        <br>
        #{@hebrewDescription()}
        <br>
        #{@gregorianDescription()}
      </td>
    """

ROWS_PER_PAGE = 2
ROWS_PER_CELL = 8

COORDINATES =
  baltimore:
    latitude: 39.36
    longitude: -76.7
    timezone: "America/New_York"
  boston:
    latitude: 42.346
    longitude: -71.152
    timezone: "America/New_York"

Weekdays = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'שַׁבָּת']

advance = (hebrewDate) ->
  gregorianDate = hebrewDate.gregorianDate
  gregorianDate.setDate(gregorianDate.getDate() + 1)
  new HebrewDate(gregorianDate)

headerRow = -> "<tr>#{("<th>#{day}</th>" for day in Weekdays).join('')}</tr>"

dividerRow = -> "<p class='page-break-before'>&nbsp;</p>"

wrappedInTable = (content, collate) ->
  """
    <table class='table table-striped table-condensed'>
      <#{if collate then "tbody class='thead'" else "thead"}>#{headerRow()}</thead>
      <tbody>#{content}</tbody>
    </table>
  """

splitAtMiddleOfPage = (top, bottom) ->
  "<div class='top'>#{top}</div><div class='bottom'>#{bottom}</div>"

updateCalendar = ->
  selectedYear = parseInt @value
  collate = hebrewCalendar.$collate.is(':checked')
  hebrewDate =  new HebrewDate(new RoshHashana(selectedYear).getGregorianDate())
  blankDays = hebrewDate.gregorianDate.getDay()
  tables = []
  html = "<tr>"
  while blankDays--
    html += "<td></td>"
  weeks = 0
  while hebrewDate.getYearFromCreation() == selectedYear
    coordinates = COORDINATES.baltimore
    moment.tz.setDefault(coordinates.timezone)
    dayCell = new PlagCell(hebrewDate, ROWS_PER_CELL, coordinates)
    html += dayCell.content()
    if hebrewDate.isShabbat()
      weeks += 1
      html += "</tr>"
      if collate && 0 == (weeks % ROWS_PER_PAGE)
        tables.push wrappedInTable(html, collate)
        html = ""
      html += "<tr>"
    hebrewDate = advance(hebrewDate)
  blankDays = 7 - hebrewDate.gregorianDate.getDay()
  while blankDays--
    html += "<td></td>"
  html += "</tr>"
  html = wrappedInTable(html, collate)
  if collate
    weeks += 1
    while (weeks % ROWS_PER_PAGE)
      weeks += 1
      html += "<br>".repeat ROWS_PER_CELL
    tables.push html
    collatedTables = []
    while (tables.length % 4)
      tables.push "<br>".repeat (ROWS_PER_CELL * 2 - 1)
    while (tables.length)
      collatedTables.push splitAtMiddleOfPage(tables.pop(), tables.shift())
      collatedTables.push splitAtMiddleOfPage(tables.shift(), tables.pop())
    $('#calendar').html collatedTables.join(dividerRow())
  else
    tables.push html
    $('#calendar').html tables.join(dividerRow())

$ ->
  window.hebrewCalendar = new HebrewCalendar(updateCalendar)
  hebrewCalendar.populateSelect()
  hebrewCalendar.$yearSelect.change()
  for name, dates of maximums
    console.log "Latest #{name}: #{dates[parseInt(dates.length / 2)].format('YYYY-MM-DD h:mm:ss.SSS a')}"
