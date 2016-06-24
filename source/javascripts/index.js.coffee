//= require 'hebrewCalendar'
//= require 'dayCell'

ROWS_PER_PAGE = 4
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

updateCalendar = ->
  selectedYear = parseInt @value
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
      if (0 == weeks % ROWS_PER_PAGE)
        tables.push wrappedInTable(html)
        html = ""
      html += "<tr>"
    hebrewDate = advance(hebrewDate)
  blankDays = 7 - hebrewDate.gregorianDate.getDay()
  while blankDays--
    html += "<td></td>"
  html += "</tr>"
  tables.push wrappedInTable(html)
  $('#calendar').html tables.join(dividerRow())

$ ->
  window.hebrewCalendar = new HebrewCalendar(updateCalendar)
  hebrewCalendar.populateSelect()
  hebrewCalendar.$yearSelect.change()
