//= require 'hebrewDateExtensions'
//= require 'birthdays'

class DayCell
  constructor: (hebrewDate, rowsPerCell) ->
    @hebrewDate = hebrewDate
    @rowsPerCell = rowsPerCell
  sedra: -> @_sedra ?= (
    if @hebrewDate.isShabbat()
      unless @hebrewDate.isRegel() || @hebrewDate.isYomKippur() || @hebrewDate.isYomTob()
        @hebrewDate.sedra().replace(/-/g, ' - ')
  )
  hebrewDescription: -> @_hebrewDescription ?= "#{@hebrewDate.staticHebrewMonth.name} #{@hebrewDate.dayOfMonth}"
  gregorianDescription: -> @_gregorianDescription ?= moment(@hebrewDate.gregorianDate).format("D MMMM")
  eventList: -> @_eventList ?= (
    list = []
    if @hebrewDate.omer()?.tonight?
      list.push "<small class='no-wrap'>Tonight: #{@hebrewDate.omer().tonight} לָעֹמֶר</small>"
      if 49 == @hebrewDate.omer().tonight
        list.push "<small class='no-wrap'>&nbsp;&nbsp;&nbsp;&nbsp;(Skip פְּסוּקִים in לְשֵׁם יִחוּד that mention 49)</small>"
    for name, birthday of Birthdays
      if @hebrewDate.isBirthday(birthday)
        list.push "#{name}'s Birthday"
    if @hebrewDate.isShabbat() && @sedra()?
      list.push @sedra()
    list
  )
  content: ->
    events = @eventList().join("<br>")
    newLines = events.match(/<br>/g)?.length ? 0
    placeholderCount = @rowsPerCell - 2 - newLines
    placeholders = "<br>".repeat placeholderCount
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

(exports ? this).DayCell = DayCell
