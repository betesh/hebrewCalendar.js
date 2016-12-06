//= require 'hebrewEvents'
//= require 'hebrewDateExtensions'
//= require 'anniversary'
//= require 'birthdays'
//= require 'yahrzeits'
//= require 'hachrazatTaanit'
//= require 'zmanim/zmanim'
//= require 'zmanim/sunrise'

class DayCell
  constructor: (hebrewDate, rowsPerCell, showLessDetailedEvents, zmanimOnly, coordinates) ->
    @hebrewDate = hebrewDate
    @rowsPerCell = rowsPerCell
    @showLessDetailedEvents = showLessDetailedEvents
    @zmanimOnly = zmanimOnly
    @coordinates = coordinates
  sedra: -> @_sedra ?= (
    if @hebrewDate.isShabbat()
      unless @hebrewDate.isRegel() || @hebrewDate.isYomKippur() || @hebrewDate.isYomTob()
        @hebrewDate.sedra().replace(/-/g, ' - ')
  )
  hebrewDescription: -> @_hebrewDescription ?= "#{@hebrewDate.staticHebrewMonth.name} #{@hebrewDate.dayOfMonth}"
  gregorianDescription: -> @_gregorianDescription ?= moment(@hebrewDate.gregorianDate).format("D MMMM")
  eventList: -> @_eventList ?= (
    list = []
    events = $.extend({}, HebrewEvents)
    events = $.extend(events, DetailedHebrewEvents) unless @showLessDetailedEvents
    for event, name of events
      list.push name if @hebrewDate["is#{event}"]()
    if @hebrewDate.omer()?.tonight?
      list.push "<small class='no-wrap'>Tonight: #{@hebrewDate.omer().tonight} לָעֹמֶר</small>"
      if !@showLessDetailedEvents && 49 == @hebrewDate.omer().tonight
        list.push "<small class='no-wrap'>&nbsp;&nbsp;&nbsp;&nbsp;(Skip פְּסוּקִים in לְשֵׁם יִחוּד that mention 49)</small>"
    if @hebrewDate.isFirstDayOfRoshHashana() && !@showLessDetailedEvents
      yesterday = new Date(@hebrewDate.gregorianDate)
      yesterday.setDate(yesterday.getDate() - 1)
      hachrazatRoshHodesh = new HachrazatRoshChodesh(new HebrewDate(yesterday))
      announcement = hachrazatRoshHodesh.moladAnnouncement()
      announcement = announcement.replace(/The (מוֹלַד) of חֹדֶשׁ תִּשְׁרִי will be/g, "$1")
      list.push "<small class='no-wrap'>#{announcement}</small>"
    if @hebrewDate.isShabbatMevarechim()
      if @showLessDetailedEvents
        list.push "שַׁבָּת מְבָרְכִים"
      else
        hachrazatRoshHodesh = new HachrazatRoshChodesh(@hebrewDate)
        announcement = "#{hachrazatRoshHodesh.moladAnnouncement()}<br>#{hachrazatRoshHodesh.sephardicAnnouncement()}"
        announcement = announcement.replace(/(will be on) /g, "$1<br>&nbsp;&nbsp;&nbsp;&nbsp;")
        announcement = announcement.replace(/(בְּסִימַן)/g, "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$1")
        announcement = announcement.replace(/(רֹאשׁ חֹדֶשׁ) /g, "$1<br>&nbsp;&nbsp;&nbsp;&nbsp;")
        list.push "<small class='no-wrap'>#{announcement}</small>"
    if !@showLessDetailedEvents && @hebrewDate.isHachrazatTaanit()
      list.push (new HachrazatTaanit(@hebrewDate)).announcement()
    if @hebrewDate.isAnniversary()
      list.push "Anniversay"
    for name, birthday of Birthdays
      if @hebrewDate.isBirthday(birthday)
        list.push "#{name}'s Birthday"
    for name, yahrzeit of Yahrzeits
      for month in yahrzeit.months
        if @hebrewDate.monthAndRangeAre(month, [yahrzeit.date])
          list.push "<small>אַזְכָּרָה: #{name}</small>"
    if @hebrewDate.isShabbat() && @sedra()?
      list.push @sedra()
    zmanim = new Zmanim(@hebrewDate.gregorianDate, @coordinates)
    if @hebrewDate.isEreb9Ab()
      list.push "<small>Fast begins: </small>#{zmanim.sunset().seconds(0).format('h:mm')}"
    if @hebrewDate.is9Ab()
      list.push "<small>חֲצוֹת: </small>#{zmanim.chatzot().seconds(60).format('h:mm')}"
      list.push "<small>Fast ends: </small>#{zmanim.setHaKochabim3Stars().seconds(60).format('h:mm')}#{if 0 == @hebrewDate.gregorianDate.getDay() then " <small><br>(Say הַבְדָלָה before eating)</small>" else ""}"
    # if @hebrewDate.isBedikatHames()
    if @hebrewDate.isErebPesach()
      list.push "<small>Stop eating חָמֵץ before </small>#{zmanim.latestTimeToEatHametz().seconds(0).format('h:mm')}"
      if @hebrewDate.isShabbat()
        list.push "<small>Say כָּל חֲמִירָא before </small>#{zmanim.latestTimeToOwnHametz().seconds(0).format('h:mm')}"
    if @hebrewDate.isBedikatHames()
      list.push "<small>בְּדִיקַת חָמֵץ after:</small>#{zmanim.setHaKochabim3Stars().seconds(60).format('h:mm')}"
    if @hebrewDate.isBiurHames()
      list.push "<small>Destroy #{if @hebrewDate.isErebPesach() then "all" else ""} חָמֵץ before </small>#{zmanim.latestTimeToOwnHametz().seconds(0).format('h:mm')}"
    if @hebrewDate.isShabbat() && (@hebrewDate.tonightIsYomTob())
      list.push "<small>Start 'סְעוּדַת ג before </small>#{zmanim.samuchLeminchaKetana().seconds(0).format('h:mm')}"
    if zmanim.hadlakatNerot()?
      list.push "<small>הַדְלַקָת נֵרות: </small>#{zmanim.hadlakatNerot()}"
    if (@hebrewDate.is2ndDayOfYomTob() && !@hebrewDate.isErebShabbat()) || @hebrewDate.isShabbat() || @hebrewDate.isYomKippur()
      list.push "<small>זְמַן מְלָאכָה: </small>#{zmanim.setHaKochabim3Stars().seconds(60).format('h:mm')}"
    if @hebrewDate.isErebPesach() || @hebrewDate.is1stDayOfPesach()
      list.push "<small>חֲצוֹת: </small>#{zmanim.chatzot().seconds(0).format('h:mm')}"
    list
  )
  zmanimList: -> @_zmanimList ?= (
    zmanim = new Zmanim(@hebrewDate.gregorianDate, @coordinates)
    list = []
    alotHaShahar = zmanim.magenAbrahamDawn().format("h:mm:ss")
    list.push("עֲהַ\"שַּׁ: #{alotHaShahar}")
    misheyakir = zmanim.earliestTallit().seconds(60).format("h:mm")
    list.push("מִשֶּׁיַכִּיר: #{misheyakir}")
    sunrise = (new Sunrise(@hebrewDate)?.time() ? zmanim.sunrise()).format("h:mm:ss")
    list.push("עֲמִידָה: #{sunrise}")
    sofZmanKeriatShema = zmanim.sofZmanKeriatShema().seconds(0).format("h:mm")
    list.push("סזק\"שׁ: #{sofZmanKeriatShema}")
    sofZmanTefila = zmanim.shaaZemaniMagenAbrahamDegrees(4).seconds(0).format("h:mm")
    list.push("סזי\"ח: #{sofZmanTefila}")
    if @hebrewDate.isErebPesach() || @hebrewDate.isBiurHames()
      fifthHour = zmanim.shaaZemaniMagenAbrahamDegrees(5).seconds(0).format("h:mm")
      list.push("חָמֵץ: #{fifthHour}")
    chatzot = zmanim.chatzot().seconds(60).format("h:mm")
    list.push("חֲצוֹת: #{chatzot}")
    earliestMincha = zmanim.earliestMincha().seconds(60).format("h:mm")
    list.push("מ\"ג: #{earliestMincha}")
    if (@hebrewDate.isErebShabbat() && !@hebrewDate.is10Tevet()) || @hebrewDate.isErebYomTob() || @hebrewDate.is1stDayOfYomTob()
      samuchLeminchaKetana = zmanim.samuchLeminchaKetana().seconds(0).format("h:mm")
      list.push("סז\"ס: #{samuchLeminchaKetana}")
    if (@hebrewDate.isErebShabbat() || @hebrewDate.isErebYomKippur() || @hebrewDate.isErebYomTob()) && !@hebrewDate.isShabbat() && !@hebrewDate.isYomTob()
      minchaKetana = zmanim.shaaZemaniGra(9.5).seconds(0).format("h:mm")
      list.push("סס\"ב: #{minchaKetana}")
    if (!@hebrewDate.isShabbat() && !@hebrewDate.isYomKippur() && !@hebrewDate.isErebYomKippur() && !@hebrewDate.isErebYomTob() && !@hebrewDate.isYomTob()) || @hebrewDate.is6thDayOfPesach() || (@hebrewDate.yomYobThatWePrayAtPlag() && !@hebrewDate.isShabbat())
      plag = zmanim.plag().seconds(60).format("h:mm")
      list.push("פלג: #{plag}")
    sunset = zmanim.sunset().seconds(0).format("h:mm")
    list.push("שְׁקִיעָה: #{sunset}")
    if @hebrewDate.isTaanit() || @hebrewDate.omer()?.tonight? || @hebrewDate.hasHadlakatNerotHanukah() || @hebrewDate.isErebPurim()
      setHaKochabimGeonim = zmanim.setHaKochabimGeonim().seconds(60).format("h:mm")
      list.push("צהכ\"ג: #{setHaKochabimGeonim}")
    setHaKochabim3Stars = zmanim.setHaKochabim3Stars().seconds(60).format("h:mm")
    list.push("צה\"כ: #{setHaKochabim3Stars}")
    if @hebrewDate.isShabbat() || @hebrewDate.isYomKippur()
      rabbenuTam = moment(zmanim.sunset()).add(72, 'minutes').seconds(60).format('h:mm')
      list.push("ר\"ת: #{rabbenuTam}")
    "<small>#{item}</small>" for item in list
  )
  content: ->
    if @zmanimOnly
      events = @zmanimList().join("<br>")
      @rowsPerCell = @rowsPerCell + 5
    else
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

(exports ? this).DayCell = DayCell
