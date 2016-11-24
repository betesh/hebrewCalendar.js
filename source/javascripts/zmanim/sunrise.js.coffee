#= require ./sunrises
#= require ../vendor/hebrewDate

class Sunrise
  constructor: (hebrewDate) ->
    momentInstance = moment(hebrewDate.gregorianDate)
    dstOffset = if moment(momentInstance).hour(12).isDST() then 1 else 0
    sunrisesThisYear = window.sunrises["#{hebrewDate.getYearFromCreation()}"]
    if sunrisesThisYear
      doy = hebrewDate.getDayOfYear()
      @sunrise = moment(sunrisesThisYear[doy - 1], 'h:mm:ss').add(dstOffset, 'hours').year(momentInstance.year()).month(momentInstance.month()).date(momentInstance.date())
  time: -> @sunrise

window.Sunrise = Sunrise
