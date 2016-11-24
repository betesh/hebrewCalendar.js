#= require ../vendor/suncalc

SunCalc.addTime(-8.5, 'smallStars3', 'setHaKochabim')
SunCalc.addTime(-16.1, 'magenAbrahamDawn', 'magenAbrahamDusk')
SunCalc.addTime(-10.2, 'earliestTallit', 'dusk10_2')

shaaZemani = (beginningOfDay, lengthOfDay, hour) ->
  beginningOfDay.add(lengthOfDay * hour / 12.0, 'seconds')

class Zmanim
  constructor: (gregorianDate, coordinates) ->
    @gregorianDate = moment(gregorianDate).toDate()
    @gregorianDate.setHours(12)
    @zmanim = SunCalc.getTimes(@gregorianDate, coordinates.latitude, coordinates.longitude)
  shaaZemaniGra: (hour) ->
    beginningOfDay = moment(@zmanim.sunrise)
    lengthOfDay = (@zmanim.sunset - @zmanim.sunrise) / 1000
    shaaZemani(beginningOfDay, lengthOfDay, hour)
  shaaZemaniMagenAbrahamDegrees: (hour) ->
    beginningOfDay = moment(@magenAbrahamDawn())
    lengthOfDay = (@zmanim.magenAbrahamDusk - @zmanim.magenAbrahamDawn) / 1000.0
    shaaZemani(beginningOfDay, lengthOfDay, hour)
  shaaZemaniMagenAbrahamFixedMinutes: (hour) ->
    beginningOfDay = moment(@zmanim.sunrise).subtract(72, 'minutes')
    lengthOfDay = (@zmanim.sunset - @zmanim.sunrise) / 1000 + 144 * 60
    shaaZemani(beginningOfDay, lengthOfDay, hour)
  shaaZemaniMagenAbraham: (hour) -> moment.min(@shaaZemaniMagenAbrahamDegrees(hour), @shaaZemaniMagenAbrahamFixedMinutes(hour))
  magenAbrahamDawn: -> @_magenAbrahamDawn ?= moment(@zmanim.magenAbrahamDawn)
  sunrise: -> @_sunrise ?= moment(@zmanim.sunrise)
  latestTimeToEatHametz: -> @_latestTimeToEatHametz ?= @shaaZemaniMagenAbraham(4)
  latestTimeToOwnHametz: -> @_latestTimeToOwnHametz ?= @shaaZemaniMagenAbraham(5)
  chatzot: -> @_chatzot ?= moment(@zmanim.solarNoon)
  samuchLeminchaKetana: -> @_samuchLeminchaKetana ?= @shaaZemaniGra(9)
  plag: -> @_plag ?= @shaaZemaniGra(10.75)
  hadlakatNerot: -> @_hadlakatNerot ?= (
    hebrewDate = new HebrewDate(@gregorianDate)
    if hebrewDate.isShabbat()
      null
    else if hebrewDate.hasHadlakatNerotAfterSetHaKochabim()
      showEarlyTime = hebrewDate.yomYobThatWePrayAtPlag() && !hebrewDate.isShabbat()
      "After #{@setHaKochabim3Stars().seconds(60).format('h:mm')}#{if showEarlyTime then "<small><br>(After #{moment(@plag()).seconds(60).format('h:mm')} / eat from all<br>cooked foods before #{moment(@sunset()).seconds(0).format('h:mm')})</small>" else ""}"
    else if hebrewDate.hasHadlakatNerot()
      showEarlyTime = hebrewDate.isErebShabbat() && ((@plag().isDST() && !hebrewDate.isErebKippur() && (!hebrewDate.isErebYomTob() || hebrewDate.isSixthDayOfPesach())) || hebrewDate.hasHadlakatNerotHanukah())
      "#{moment(@sunset()).subtract(18, 'minutes').seconds(0).format('h:mm')}#{if showEarlyTime then "<small><br>(Earliest: #{moment(@plag()).seconds(60).format('h:mm')})</small>" else ""}"
    else
      null
  )
  sunset: -> @_sunset ?= moment(@zmanim.sunset)
  setHaKochabimGeonim: -> @_setHaKochabimGeonim ?= (
    time = @shaaZemaniGra(12.225)
    timeSinceSunset = time.diff(@sunset())
    if timeSinceSunset < 13.5 * 60 * 1000
      timeSinceSunset = 27 * 60 * 1000 - timeSinceSunset
      time = moment(@sunset()).add(timeSinceSunset)
    time.seconds(60)
  )
  setHaKochabim3Stars: -> @_setHaKochabim3Stars ?= moment(@zmanim.setHaKochabim)

(exports ? this).Zmanim = Zmanim
