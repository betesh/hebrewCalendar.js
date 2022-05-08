#= require 'vendor/hebrewDate'
#= require 'hebrewCalendar'
#= require 'dayCell'

ROWS_PER_PAGE = 2
ROWS_PER_CELL = 9

COORDINATES =
  baltimore:
    latitude: 39.36
    longitude: -76.7
    timezone: "America/New_York"
  boston:
    latitude: 42.346
    longitude: -71.152
    timezone: "America/New_York"
  mexicoCity:
    latitude: 19.434
    longitude: -99.1975
    timezone: "America/Mexico_City"
  dallas:
    latitude: 32.99
    longitude: -96.79
    timezone: "America/Chicago"

window.CITY = (
  ->
    params = new URLSearchParams(location.search)
    if params.has('city') then params.get('city') else 'mexicoCity'
  )()

window.SELECTED_COORDINATES = COORDINATES[CITY]

Weekdays = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'שַׁבָּת']

advance = (hebrewDate, days = 1) ->
  gregorianDate = hebrewDate.gregorianDate
  gregorianDate.setDate(gregorianDate.getDate() + days)
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
  collate = hebrewCalendar.$collate.is(':checked') &&
    !hebrewCalendar.$zmanimOnly.is(':checked') &&
    !hebrewCalendar.$berachot100.is(':checked')
  showLessDetailedEvents = hebrewCalendar.$lessDetailedEvents.is(':checked')
  zmanimOnly = hebrewCalendar.$zmanimOnly.is(':checked')
  berachot100 = hebrewCalendar.$berachot100.is(':checked')
  hebrewDate =  new HebrewDate(new RoshHashana(selectedYear).getGregorianDate())
  blankDays = hebrewDate.gregorianDate.getDay()
  tables = []
  html = "<tr>"
  while blankDays--
    html += "<td></td>"
  weeks = 0
  while hebrewDate.getYearFromCreation() == selectedYear
    dayCell = new DayCell(hebrewDate, ROWS_PER_CELL, showLessDetailedEvents, zmanimOnly, berachot100, SELECTED_COORDINATES, CITY)
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
  moment.tz.setDefault(SELECTED_COORDINATES.timezone)
  window.hebrewCalendar = new HebrewCalendar(updateCalendar)
  hebrewCalendar.populateSelect()
  hebrewCalendar.$yearSelect.change()
