#= require 'vendor/hebrewDate'
#= require 'hebrewCalendar'
#= require 'dayCell'

ROWS_PER_PAGE = 2
ROWS_PER_CELL = 9

DALLAS =
  latitude: 32.99
  longitude: -96.79
  timezone: "America/Chicago"

window.COORDINATES = (
  ->
    params = new URLSearchParams(location.search)
    if params.has('Coordinates')
      JSON.parse(params.get('Coordinates'))
    else
      DALLAS
  )()

window.CITY = (
  ->
    params = new URLSearchParams(location.search)
    if params.has('city') then params.get('city') else 'mexicoCity'
  )()

window.SELECTED_COORDINATES = window.COORDINATES[CITY]

Weekdays = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'שַׁבָּת']

advance = (hebrewDate, days = 1) ->
  gregorianDate = hebrewDate.gregorianDate
  gregorianDate.setDate(gregorianDate.getDate() + days)
  new HebrewDate(gregorianDate)

headerRow = -> "<tr>#{("<th>#{day}</th>" for day in Weekdays).join('')}</tr>"

dividerRow = -> "<p class='page-break-before'>&nbsp;</p>"

wrappedInTable = (content, collate, showHeader) ->
  """
    <table class='table table-striped table-condensed'>
      #{if showHeader then "<#{if collate then "tbody class='thead'" else "thead"}>#{headerRow()}</thead>" else ""}
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
  shabbatYTOnly = hebrewCalendar.$shabbatYTOnly.is(':checked')
  zmanimOnly = hebrewCalendar.$zmanimOnly.is(':checked')
  berachot100 = hebrewCalendar.$berachot100.is(':checked')
  hebrewDate =  new HebrewDate(new RoshHashana(selectedYear).getGregorianDate())
  days = 1
  tables = []
  html = "<tr>"
  unless shabbatYTOnly
    while days < hebrewDate.gregorianDate.getDay() + 1
      html += "<td></td>"
      days += 1
  weeks = 0
  while hebrewDate.getYearFromCreation() == selectedYear
    dayCell = new DayCell(hebrewDate, ROWS_PER_CELL, showLessDetailedEvents, zmanimOnly, berachot100, SELECTED_COORDINATES, CITY, shabbatYTOnly)
    html += dayCell.content()
    if days == 7
      days = 0
      weeks += 1
      html += "</tr>"
      if collate && 0 == (weeks % ROWS_PER_PAGE)
        tables.push wrappedInTable(html, collate, !shabbatYTOnly)
        html = ""
      html += "<tr>"
    days += 1
    hebrewDate = advance(hebrewDate)
    if shabbatYTOnly
      hebrewDate = advance(hebrewDate) until hebrewDate.isShabbat() || hebrewDate.isYomTob() || hebrewDate.isYomKippur() || hebrewDate.isMoed()
  if days > 1
    while days < 8
      html += "<td></td>"
      days += 1
  html += "</tr>"
  html = wrappedInTable(html, collate, !shabbatYTOnly)
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
