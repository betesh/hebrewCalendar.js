//= require 'hebrewEvents'
//= require 'hebrewDateExtensions'

class DayCell
  constructor: (hebrewDate, rowsPerCell, showLessDetailedEvents, zmanimOnly, coordinates) ->
    @hebrewDate = hebrewDate
    @rowsPerCell = rowsPerCell
    @showLessDetailedEvents = showLessDetailedEvents
    @coordinates = coordinates
  sedra: -> @_sedra ?= (
    if @hebrewDate.isShabbat()
      unless @hebrewDate.isRegel() || @hebrewDate.isYomKippur() || @hebrewDate.isYomTob()
        @hebrewDate.sedra().replace(/-/g, ' - ')
  )
  hebrewDescription: -> @_hebrewDescription ?= "#{@hebrewDate.staticHebrewMonth.name} #{@hebrewDate.dayOfMonth}"
  gregorianDescription: -> @_gregorianDescription ?= moment(@hebrewDate.gregorianDate).format("D MMM")
  eventList: -> @_eventList ?= (
    list = []
    events = $.extend({}, HebrewEvents)
    events = $.extend(events, DetailedHebrewEvents) unless @showLessDetailedEvents
    for event, name of events
      list.push name if @hebrewDate["is#{event}"]()
    if @hebrewDate.isShabbatMevarechim()
      if @showLessDetailedEvents
        list.push "שַׁבָּת מְבָרְכִים"
    if @hebrewDate.isShabbat() && @sedra()?
      if list.length % 2
        temp = list.pop()
        list.push @sedra()
        list.push temp
      else
        list.push @sedra()
    list
  )
  content: ->
    combinedEvents = []
    list = @eventList()
    while list.length
      firstEvent = "<span class='pull-right'>#{list.shift()}</span>"
      combinedEvents.push "#{list.shift() ? ''}#{firstEvent}"
    events = combinedEvents.join("<br>")
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
        <strong>#{events}</strong>
        <br>
        _____ סִימָן<span class='pull-right'>#{@gregorianDescription()}</span>
        <br>
        _____ סְעִיף<span class='pull-right'>#{@hebrewDescription()}</span>
      </td>
    """

(exports ? this).DayCell = DayCell
