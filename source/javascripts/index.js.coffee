//= require 'dayCell'

ROWS_PER_PAGE = 2
ROWS_PER_CELL = 2

COORDINATES =
  baltimore:
    latitude: 39.36
    longitude: -76.7
  boston:
    latitude: 42.346
    longitude: -71.152

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
  selectedYear = 5777
  collate = false
  showLessDetailedEvents = true
  zmanimOnly = false
  seedDate = new RoshHashana(selectedYear).getGregorianDate()
  seedDate.setDate(226)
  hebrewDate =  new HebrewDate(seedDate)
  blankDays = hebrewDate.gregorianDate.getDay()
  tables = []
  html = "<tr>"
  while blankDays--
    html += "<td></td>"
  weeks = 0
  while hebrewDate.getYearFromCreation() == selectedYear
    dayCell = new DayCell(hebrewDate, ROWS_PER_CELL, showLessDetailedEvents, zmanimOnly, COORDINATES.baltimore)
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
  tables.push html
  $('#calendar').html tables.join(dividerRow())
  $('#year').html "<h2>#{selectedYear}</h2>"

$ -> updateCalendar()
