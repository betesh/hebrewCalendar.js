(exports ? this).Anniversary = JSON.parse((new URLSearchParams(location.search)).get('Anniversary'))

HebrewDate.prototype.isAnniversary = ->
  Anniversary? &&
   @hebrewYear.getYearFromCreation() >= Anniversary.year &&
   @monthAndRangeAre(Anniversary.month, [Anniversary.date])
