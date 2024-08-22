#= require 'hebrewEvents'
#= require 'hebrewDateExtensions'
#= require 'anniversary'
#= require 'birthdays'
#= require 'yahrzeits'
#= require 'hachrazatTaanit'
#= require 'zmanim/zmanim'
#= require 'zmanim/sunrise'

class DayCell
  constructor: (hebrewDate, rowsPerCell, showLessDetailedEvents, zmanimOnly, berachot100, coordinates, city) ->
    @hebrewDate = hebrewDate
    @rowsPerCell = rowsPerCell
    @showLessDetailedEvents = showLessDetailedEvents
    @zmanimOnly = zmanimOnly
    @berachot100 = berachot100
    @coordinates = coordinates
    @city = city
  sedra: -> @_sedra ?= (
    if @hebrewDate.isShabbat()
      unless @hebrewDate.isRegel() || @hebrewDate.isYomKippur() || @hebrewDate.isYomTob()
        @hebrewDate.sedra().replace(/-/g, ' - ')
  )
  hebrewDescription: -> @_hebrewDescription ?= "#{@hebrewDate.staticHebrewMonth.name} #{@hebrewDate.dayOfMonth}"
  gregorianDescription: -> @_gregorianDescription ?= moment(@hebrewDate.gregorianDate).tz(moment.tz.guess()).format("D MMMM")
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
      announcement = announcement.replace(/The (מוֹלַד) of חֹדֶשׁ תִּשְׁרִי (will be on)|(is \[today\])|(was on)/g, "$1:")
      list.push "<small class='no-wrap'>#{announcement}</small>"
    if @hebrewDate.isTefilatHaShelah() && @hebrewDate.isMaharHodesh()
      list.splice list.indexOf(events["MaharHodesh"]), 1
      list.splice list.indexOf(events["TefilatHaShelah"]), 1
      list.unshift "#{events["TefilatHaShelah"]}&nbsp&nbsp&nbsp&nbsp&nbsp#{events["MaharHodesh"]}"
    if @hebrewDate.isShabbatMevarechim()
      if @showLessDetailedEvents
        list.push "שַׁבָּת מְבָרְכִים"
      else
        hachrazatRoshHodesh = new HachrazatRoshChodesh(@hebrewDate)
        announcement = "#{hachrazatRoshHodesh.moladAnnouncement()}<br>#{hachrazatRoshHodesh.sephardicAnnouncement()}"
        announcement = announcement.replace(/((will be on)|(is \[today\])|(was on)) /g, "$1<br>&nbsp;&nbsp;&nbsp;&nbsp;")
        announcement = announcement.replace(/(בְּסִימַן)/g, "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$1")
        announcement = announcement.replace(/(רֹאשׁ חֹדֶשׁ) /g, "$1<br>&nbsp;&nbsp;&nbsp;&nbsp;")
        list.push "<small class='no-wrap'>#{announcement}</small>"
    if !@showLessDetailedEvents && @hebrewDate.isHachrazatTaanit()
      list.push (new HachrazatTaanit(@hebrewDate)).announcement()
    if @hebrewDate.isAnniversary()
      list.push "Anniversary"
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
    if @hebrewDate.isErebPesach()
      list.push "<small>Stop eating חָמֵץ before </small>#{zmanim.latestTimeToEatHametz().seconds(0).format('h:mm')}"
      if @hebrewDate.isShabbat()
        list.push "<small>Say כָּל חֲמִירָא before </small>#{zmanim.latestTimeToOwnHametz().seconds(0).format('h:mm')}"
    if @hebrewDate.isBedikatHames()
      list.push "<small>בְּדִיקַת חָמֵץ after:</small>#{zmanim.setHaKochabim3Stars().seconds(60).format('h:mm')}"
    if @hebrewDate.isBiurHames()
      list.push "<small>Destroy #{if @hebrewDate.isErebPesach() then "all" else ""} חָמֵץ before </small>#{zmanim.latestTimeToOwnHametz().seconds(0).format('h:mm')}"
    if @hebrewDate.isShabbat() && (@hebrewDate.tonightIsYomTob())
      list.push "<small>Finish 'סְעוּדַת ג before </small>#{zmanim.samuchLeminchaKetana().seconds(0).format('h:mm')}"
    if zmanim.hadlakatNerot()?
      list.push "<small>הַדְלַקָת נֵרות: </small>#{zmanim.hadlakatNerot()}"
    if (@hebrewDate.is2ndDayOfYomTob() && !@hebrewDate.isErebShabbat())
      list.push "<small>זְמַן מְלָאכָה: </small>#{moment.max(zmanim.setHaKochabim3Stars().seconds(60), moment(zmanim.sunset()).seconds(0).add(46, 'minutes')).format('h:mm')}"
    if @hebrewDate.isShabbat() || @hebrewDate.isYomKippur()
      list.push "<small>זְמַן מְלָאכָה: </small>#{moment.max(zmanim.setHaKochabim3Stars().seconds(60), moment(zmanim.sunset()).seconds(0).add(46, 'minutes')).format('h:mm')}/#{moment(zmanim.sunset()).add(72, 'minutes').seconds(60).format('h:mm')}"
    if @hebrewDate.isErebPesach() || @hebrewDate.is1stDayOfPesach()
      list.push "<small>חֲצוֹת: </small>#{zmanim.chatzot().seconds(0).format('h:mm')}"
    list
  )
  zmanimList: -> @_zmanimList ?= (
    zmanim = new Zmanim(@hebrewDate.gregorianDate, @coordinates)
    list = []
    alotHaShaharFixedMinutes = moment(zmanim.zmanim.sunrise).subtract(72, 'minutes')
    alotHaShaharDegrees = zmanim.magenAbrahamDawn()
    alotHashahar = [alotHaShaharFixedMinutes, alotHaShaharDegrees]
    list.push("עֲהַ\"שַּׁ: #{moment.min(alotHashahar).seconds(0).format("h:mm")} / #{moment.max(alotHashahar).seconds(60).format("h:mm")}")
    misheyakir = zmanim.earliestTallit().seconds(60).format("h:mm")
    list.push("מִשֶּׁיַכִּיר: #{misheyakir}")
    sunrise = zmanim.sunrise().format("h:mm:ss")
    amidah = "#{sunrise}"
    visibleSunrise = new Sunrise(@hebrewDate, @city)?.time()
    amidah = "<small>#{amidah} בְּמִישׁוֹר / #{visibleSunrise.format("h:mm:ss")} נִרְאֶה</small>" if visibleSunrise?
    amidah = "עֲמִידָה: #{amidah}"
    list.push(amidah)
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
    if (@hebrewDate.isErebShabbat() || @hebrewDate.isErebYomKippur() || @hebrewDate.isErebYomTob()) && !@hebrewDate.isShabbat() && !@hebrewDate.isYomTob() && !@hebrewDate.isPurim() && !@hebrewDate.isErebPesach() && !@hebrewDate.isMoed()
      minchaKetana = zmanim.shaaZemaniGra(9.5).seconds(0).format("h:mm")
      list.push("סס\"ב: #{minchaKetana}")
    if (!@hebrewDate.isShabbat() && !@hebrewDate.isYomKippur() && !@hebrewDate.isErebYomKippur() && !@hebrewDate.isErebYomTob() && !@hebrewDate.isYomTob()) || @hebrewDate.is6thDayOfPesach() || (@hebrewDate.yomYobThatWePrayAtPlag() && !@hebrewDate.isShabbat())
      plag1 = zmanim.plag().seconds(60).format("h:mm")
      lengthOfDay = (zmanim.zmanim.setHaKochabim - alotHaShaharFixedMinutes) / 1000
      plag2 = zmanim.shaaZemani(alotHaShaharFixedMinutes, lengthOfDay, 10.75).seconds(60).millisecond(0).format("h:mm")
      list.push("פלג: #{plag1} / #{plag2}")
    sunset = zmanim.sunset().seconds(0).format("h:mm")
    list.push("שְׁקִיעָה: #{sunset}")
    if @hebrewDate.isTaanit() || @hebrewDate.omer()?.tonight? || (@hebrewDate.hasHadlakatNerotHanukah()  && !@hebrewDate.isShabbat())
      setHaKochabimGeonim = zmanim.setHaKochabimGeonim().seconds(60).format("h:mm")
      list.push("צהכ\"ג: #{setHaKochabimGeonim}")
    setHaKochabim3Stars = zmanim.setHaKochabim3Stars().seconds(60).format("h:mm")
    list.push("צה\"כ: #{setHaKochabim3Stars}")
    if @hebrewDate.isShabbat() || @hebrewDate.isYomKippur()
      rabbenuTam = moment(zmanim.sunset()).add(72, 'minutes').seconds(60).format('h:mm')
      list.push("ר\"ת: #{rabbenuTam}")
    "<small>#{item}</small>" for item in list
  )
  berachotList: -> @_berachotList ?= (
    list = []
    total = 0

    if @hebrewDate.isShabbat() && !@hebrewDate.isFirstDayOfPesach()
      list.push("ברכת מעין שבע: 1")
      total += 1

    if @hebrewDate.omer()?.today?
        list.push("ספירת העומר: 1")
        total += 1

    if @hebrewDate.is1stDayOfPesach() || @hebrewDate.is2ndDayOfPesach()
      kadesh = (if 0 == @hebrewDate.gregorianDate.getDay() then 5 else 3)
      karpas = 1
      magid = 1
      rochtza = 1
      motzi = 1
      matza = 1
      maror = 1
      barech = 4
      cup3 = 1
      halel = 1
      alHagefen = 1
      total += seder = kadesh + karpas + magid + rochtza + motzi + matza + maror + barech + cup3 + halel + alHagefen
      list.push("ליל הסדר: #{seder}")
      list.push("קידוש: 1")
      total += 1
    else
      total += kiddush = if @hebrewDate.is7thDayOfPesach() || @hebrewDate.is8thDayOfPesach()
        if 0 == @hebrewDate.gregorianDate.getDay() then 5 else 3
      else if @hebrewDate.isShabuot() || @hebrewDate.isRoshHashana()
        if 0 == @hebrewDate.gregorianDate.getDay() then 6 else 4
      else if @hebrewDate.isYomTob() && @hebrewDate.isSukkot()
        if 0 == @hebrewDate.gregorianDate.getDay() then 8 else 6
      else if @hebrewDate.isShabbat()
        if @hebrewDate.isSukkot()
          5
        else if !@hebrewDate.isYomKippur()
          3
        else 0
      else 0
      list.push("קידוש: #{kiddush}") unless 0 == kiddush

    total += havdala = if @hebrewDate.monthAndRangeAre('TISHRI', [11])
      4
    else if 0 == @hebrewDate.gregorianDate.getDay() && !@hebrewDate.isYomTob() && !@hebrewDate.is9Ab()
      5
    else if @hebrewDate.monthAndRangeAre('TISHRI', [3,17,24]) || @hebrewDate.monthAndRangeAre('NISAN', [17,23]) || @hebrewDate.monthAndRangeAre('SIVAN', [8])
      3
    else if 1 == @hebrewDate.gregorianDate.getDay() && @hebrewDate.monthAndRangeAre('AB', [10,11])
      3
    else 0
    list.push("הבדלה (עם ברכה אחרונה): #{havdala}") unless 0 == havdala

    if 0 == @hebrewDate.gregorianDate.getDay() && @hebrewDate.is9Ab()
      total += 1
      list.push("בורא מאורי האש: 1")

    if 0 == @hebrewDate.gregorianDate.getDay() && !@hebrewDate.is9Ab() && !@hebrewDate.isYomTob()
      total += 6
      list.push("סעודה רביעית: 6")

    if @hebrewDate.isPurim()
      list.push("קריאת המגילה: 5")
      total += 5

    if @hebrewDate.isYomKippur()
      list.push("שהחינו: 1")
      total += 1

    if @hebrewDate.isBiurHames()
      list.push("בדיקת חמץ: 1")
      total += 1

    total += chanukah = if @hebrewDate.isShabbat()
      0
    else if @hebrewDate.monthAndRangeAre('KISLEV', [24]) && 5 == @hebrewDate.gregorianDate.getDay()
      3
    else if @hebrewDate.monthAndRangeAre('KISLEV', [25])
      if 5 == @hebrewDate.gregorianDate.getDay() then 5 else 3
    else if @hebrewDate.monthAndRangeAre('KISLEV', [26,27,28,29,30]) || @hebrewDate.monthAndRangeAre('TEVET', [1]) || @hebrewDate.monthAndRangeAre('TEVET', [2]) && @hebrewDate.hebrewYear.getDaysInYear() % 10 <= 3
      if 5 == @hebrewDate.gregorianDate.getDay() then 4 else 2
    else if @hebrewDate.monthAndRangeAre('TEVET', [2]) && @hebrewDate.hebrewYear.getDaysInYear() % 10 > 3 || @hebrewDate.monthAndRangeAre('TEVET', [3]) && @hebrewDate.hebrewYear.getDaysInYear() % 10 <= 3
      2
    else 0
    list.push("הדלקת נרות חנוכה: #{chanukah}") unless 0 == chanukah

    total += birchotHaShacharVeHaTorah = 3 + (if @hebrewDate.is9Ab() || @hebrewDate.isYomKippur() then 10 else 11) + 3 + 1 + 2
    list.push("ברכות השחר והתורה: #{birchotHaShacharVeHaTorah}")

    if @hebrewDate.isErebKippur()
      list.push("ברכות ציצית ותפילין: 3")
      total += 3
    else if @hebrewDate.is9Ab()
      list.push("ברכות ציצית ותפילין: 4")
      total += 4
    else if @hebrewDate.isShabbat() || @hebrewDate.isYomKippur() || @hebrewDate.isYomTob() || @hebrewDate.isMoed()
      list.push("ברכות ציצית: 1")
      total += 1
    else
      list.push("ברכות ציצית ותפילין: 2")
      total += 2

    list.push("פסד\"ז וברכות ק\"ש: 9")
    total += 9

    total += amidah = if @hebrewDate.isRoshHashana()
      7 * 3 + 9
    else if @hebrewDate.isYomKippur()
      7 * 5
    else if @hebrewDate.isShabbat() || @hebrewDate.isYomTob()
      7 * 4
    else if @hebrewDate.isMoed() || @hebrewDate.isRoshHodesh()
      19 * 3 + 7
    else
      19 * 3
    list.push("עמידה: #{amidah}")

    total += lulav = if @hebrewDate.is1stDayOfSukkot() && !@hebrewDate.isShabbat()
      4
    else if @hebrewDate.is2ndDayOfSukkot() && 0 == @hebrewDate.gregorianDate.getDay()
      4
    else if @hebrewDate.isSukkot() && !@hebrewDate.isShabbat() && !@hebrewDate.isSheminiAseret()
      3
    else 0
    list.push("נטילת לולב והלל: #{lulav}") unless 0 == lulav

    total += halel = if @hebrewDate.isHanuka() || @hebrewDate.isShabuot() || (@hebrewDate.isSukkot() && @hebrewDate.isShabbat()) || @hebrewDate.isSheminiAseret()
      2
    else if @hebrewDate.is1stDayOfPesach() || @hebrewDate.is2ndDayOfPesach()
      4
    else 0
    list.push("הלל: #{halel}") unless 0 == halel

    total += keriatHaTorah = if @hebrewDate.isShabbat() && @hebrewDate.isYomKippur()
      7 * 2 + 7 + 2 * 2 + 7
    else if @hebrewDate.isShabbat()
      7 * 2 + 7 + 3 * 2
    else if @hebrewDate.isYomKippur()
      6 * 2 + 7 + 2 * 2 + 7
    else if @hebrewDate.isYomTob()
      5 * 2 + 7
    else if @hebrewDate.isMoed() || @hebrewDate.isRoshHodesh()
      4 * 2
    else if @hebrewDate.is9Ab()
      2 * 2 + 6 + 3 * 2 # Assumes no haftarah at Mincha.  Customs vary among Sephardic communities.
    else if @hebrewDate.isTaanit()
      3 * 2 + 3 * 2
    else if 1 == @hebrewDate.gregorianDate.getDay() || 4 == @hebrewDate.gregorianDate.getDay() || @hebrewDate.isPurim() || @hebrewDate.isHanuka()
      3 * 2
    else 0
    list.push("קריאת התורה: #{keriatHaTorah}") unless 0 == keriatHaTorah

    if @hebrewDate.isRoshHashana()
      total += shofar = if @hebrewDate.is1stDayOfYomTob() && !@hebrewDate.isShabbat() || @hebrewDate.is2ndDayOfYomTob() && 0 == @hebrewDate.gregorianDate.getDay()
        2
      else if @hebrewDate.is2ndDayOfYomTob() && 0 != @hebrewDate.gregorianDate.getDay()
        1
      else 0
      list.push("תקיעת שופר: #{shofar}") unless 0 == shofar

    if @hebrewDate.isShabbat() && !@hebrewDate.isYomKippur()
      total += meals = if @hebrewDate.is1stDayOfPesach() || @hebrewDate.is2ndDayOfPesach()
        6 * 2
      else if @hebrewDate.isSukkot() && !@hebrewDate.isSheminiAseret()
        6 * 2 + 7
      else
        6 * 3
      list.push("שלש סעודות: #{meals}")
    else if @hebrewDate.isYomTob()
      total += meals = if @hebrewDate.is1stDayOfPesach() || @hebrewDate.is2ndDayOfPesach()
        6
      else
        6 * 2
      list.push("סעודות יו\"ט: #{meals}")
    else if @hebrewDate.isPurim()
      total += meals = 7
      list.push("סעודות פורים: #{meals}")
    else if @hebrewDate.isErebKippur()
      total += meals = 6
      list.push("סעודות המפסקת: #{meals}")

    if 1 == @hebrewDate.hebrewYear.getYearFromCreation() % 28 && 3 == @hebrewDate.gregorianDate.getMonth() && @hebrewDate.gregorianDate.getDate() == (parseInt((@hebrewDate.gregorianDate.getFullYear()) / 100) - parseInt((@hebrewDate.gregorianDate.getFullYear()) / 400) - 7 + parseInt((4 - (@hebrewDate.gregorianDate.getFullYear() + 1) % 4) / 4))
      list.push("ברכת החמה: 1")
      total += 1

    kohanim = if @hebrewDate.isYomKippur()
      3
    else if @hebrewDate.is9Ab()
      1 # Assumes no Birkat Kohanim at Shacharit.  Customs vary among Sephardic communities.
    else if @hebrewDate.isShabbat() || @hebrewDate.isYomTob() || @hebrewDate.isMoed() || @hebrewDate.isRoshHodesh() || @hebrewDate.isTaanit()
      2
    else 1
    list.push("ברכת כהנים: #{kohanim}")

    list.push("Total: #{total} (כהנים:<span style='color:white;'>i</span>#{total + kohanim})")
    result = ("<small>#{item}</small>" for item in list)
    result = result.join("<br>")
    if total < 100
      "<!-- <br><br> --><div class='missing-berachot-line-adjustment'>&nbsp;</div><div class='missing-berachot'>#{100 - total}</div>#{result}"
    else result
  )
  content: ->
    if @zmanimOnly
      events = @zmanimList().join("<br>")
      @rowsPerCell = @rowsPerCell + 5
    else if @berachot100
      events = @berachotList()
      @rowsPerCell = @rowsPerCell + 4
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
