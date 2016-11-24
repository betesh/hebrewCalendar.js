class HebrewCalendar
  constructor: (callback) ->
    @$yearSelect = $('#year-select')
    @$collate = $('#collate')
    @$lessDetailedEvents = $('#less-detailed-events')
    @$zmanimOnly = $('#zmanim-only')
    @$yearSelect.change(callback)
    @$collate.change => @$yearSelect.change()
    @$lessDetailedEvents.change => @$yearSelect.change()
    @$zmanimOnly.change =>
      @$lessDetailedEvents.closest('div').toggle(this.checked)
      @$collate.closest('div').toggle(this.checked)
      @$yearSelect.change()

  urlYear: -> @_urlYear ?= parseInt window.location.search.replace("?", "")

  currentYear: -> @_currentYear ?= (
    initialDate = new Date()
    initialDate.setDate(initialDate.getDate() + 2)
    new HebrewDate(initialDate).getYearFromCreation()
  )

  initialYear: -> @_initialYear ?= (if !@urlYear().isNaN && @currentYear() < @urlYear() then @urlYear() else @currentYear())

  populateSelect: ->
    i = 0
    year = @currentYear()
    while i < 10
      @$yearSelect.append($("<option>", { value: year, text: year }))
      year = year + 1
      i = i+1
    unless @$yearSelect.find("option[value='#{@initialYear()}']").length > 0
      @$yearSelect.append($("<option>", { value: @initialYear(), text: @initialYear() }))
    @$yearSelect.val(@initialYear())

(exports ? this).HebrewCalendar = HebrewCalendar
