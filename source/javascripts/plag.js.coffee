#= require 'vendor/hebrewDate'
#= require 'hebrewCalendarPlag'

#= require 'hebrewDateExtensions'
#= require 'zmanim/zmanim'

window.CITY = 'baltimore'

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

      '72min/Geonim': @plag(zmanim, moment(zmanim.zmanim.sunrise).subtract(72, 'minutes'), zmanim.setHaKochabimGeonim())
      '72 min / 8.5&deg;': @plag(zmanim, moment(zmanim.zmanim.sunrise).subtract(72, 'minutes'), zmanim.zmanim.setHaKochabim)
      '72 min/72 min': @plag(zmanim, moment(zmanim.zmanim.sunrise).subtract(72, 'minutes'), moment(zmanim.zmanim.sunset).add(72, 'minutes'))

    for name, time of plags
      list.push("<small>#{name}</small>: #{time.seconds(60).millisecond(0).format("h:mm")}")
    list
  )
  content: ->
    zmanim = new Zmanim(@hebrewDate.gregorianDate, @coordinates)
    # plag = @plag(zmanim, zmanim.zmanim.magenAbrahamDawn, zmanim.zmanim.magenAbrahamDusk) # Gets as late as 8:29
    plag = @plag(zmanim, zmanim.zmanim.magenAbrahamDawn, zmanim.zmanim.setHaKochabim) # Gets as late as 7:39
    mincha = moment(plag).minutes(plag.minutes() - 25)
    if mincha.isAfter(moment(plag).hours(19).minutes(5).seconds(0))
      """
        <td>#{@hebrewDescription()}</td>
        <td>#{@gregorianDescription()}</td>
        <td>#{@hebrewDate.sedra()}</td>
        <td colspan="2" style="text-align:center;">Join 7:15 Minyan</td>
        <td style='text-align:center;'>#{zmanim.setHaKochabim3Stars().seconds(60).format("h:mm")}</td>
      """
    else if mincha.isBefore(moment(plag).hours(18).minutes(0).seconds(0))
      ""
    else
      """
        <td>#{@hebrewDescription()}</td>
        <td>#{@gregorianDescription()}</td>
        <td>#{if @hebrewDate.isErebYomTob() then "" else @hebrewDate.sedra()}</td>
        <td style='text-align:center;'>#{mincha.seconds(60).format("h:mm")}</td>
        <td style='text-align:center;'>#{plag.seconds(60).format("h:mm")}</td>
        <td style='text-align:center;'>#{zmanim.setHaKochabim3Stars().seconds(60).format("h:mm")}</td>
      """

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

advance = (hebrewDate) ->
  gregorianDate = hebrewDate.gregorianDate
  gregorianDate.setDate(gregorianDate.getDate() + 1)
  new HebrewDate(gregorianDate)

headerRow = -> "<tr><th></th><th></th><th></th><th style='text-align:center;'>מִנְחָה</th><th style='text-align:center;'>בֹּאִי כַּלָּה בֹּאִי כַּלָּה <br>not before</th><th style='text-align:center;'>Repeat קְרִיאַת שְׁמַע /<br>Count סְפִירַת הָעֹמֶר after</th></tr>"

dividerRow = -> "<p class='page-break-before'>&nbsp;</p>"

wrappedInTable = (content, collate) ->
  """
    <table class='table table-striped table-condensed'>
      <thead>#{headerRow()}</thead>
      <tbody>#{content}</tbody>
    </table>
  """

updateCalendar = ->
  selectedYear = parseInt @value
  hebrewDate = new HebrewDate(new RoshHashana(selectedYear + 3759).getGregorianDate())
  hebrewDate = advance(hebrewDate) until hebrewDate.gregorianDate.getFullYear() == selectedYear
  tables = []
  html = "<tr>"
  while hebrewDate.gregorianDate.getFullYear() == selectedYear
    coordinates = COORDINATES[CITY]
    moment.tz.setDefault(coordinates.timezone)
    hebrewDate = advance(hebrewDate) until moment(hebrewDate.gregorianDate).isDST()
    hebrewDate = advance(hebrewDate) until (hebrewDate.isErebShabbat() && !hebrewDate.isErebYomTob()) || hebrewDate.is6thDayOfPesach()
    if hebrewDate.gregorianDate.getFullYear() == selectedYear && moment(hebrewDate.gregorianDate).isDST()
      dayCell = new PlagCell(hebrewDate, ROWS_PER_CELL, coordinates)
      html += dayCell.content()
      html += "</tr><tr>"
      hebrewDate = advance(hebrewDate)
  html += "</tr>"
  html = wrappedInTable(html, false)
  tables.push html
  $('#calendar').html tables.join(dividerRow())

$ ->
  window.hebrewCalendar = new HebrewCalendar(updateCalendar)
  hebrewCalendar.populateSelect()
  hebrewCalendar.$yearSelect.change()
