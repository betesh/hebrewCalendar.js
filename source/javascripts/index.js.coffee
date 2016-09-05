//= require 'hebrewCalendar'
//= require 'dayCell'

ROWS_PER_CELL = 9

Weekdays = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'שַׁבָּת']

advance = (hebrewDate) ->
  gregorianDate = hebrewDate.gregorianDate
  gregorianDate.setDate(gregorianDate.getDate() + 1)
  new HebrewDate(gregorianDate)

headerRow = -> "<tr>#{("<th>#{day}</th>" for day in Weekdays).join('')}</tr>"

dividerRow = -> "<p class='page-break-before'>&nbsp;</p>"

wrappedInTable = (content) ->
  """
    <table class='table table-striped table-condensed'>
      <thead>#{headerRow()}</thead>
      <tbody>#{content}</tbody>
    </table>
  """

splitAtMiddleOfPage = (top, bottom) ->
  "<div class='top'>#{top}</div><div class='bottom'>#{bottom}</div>"

updateCalendar = ->
  selectedYear = parseInt @value
  collate = hebrewCalendar.$collate.is(':checked')
  rowsPerPage = if collate then 2 else 5
  hebrewDate =  new HebrewDate(new RoshHashana(selectedYear).getGregorianDate())
  blankDays = hebrewDate.gregorianDate.getDay()
  tables = []
  html = "<tr>"
  while blankDays--
    html += "<td></td>"
  weeks = 0
  while hebrewDate.getYearFromCreation() == selectedYear
    dayCell = new DayCell(hebrewDate, ROWS_PER_CELL)
    html += dayCell.content()
    if hebrewDate.isShabbat()
      weeks += 1
      html += "</tr>"
      if (0 == weeks % rowsPerPage)
        tables.push wrappedInTable(html)
        html = ""
      html += "<tr>"
    hebrewDate = advance(hebrewDate)
  blankDays = 7 - hebrewDate.gregorianDate.getDay()
  while blankDays--
    html += "<td></td>"
  html += "</tr>"
  html = wrappedInTable(html)
  if collate
    weeks += 1
    while (weeks % rowsPerPage)
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
