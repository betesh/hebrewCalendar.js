(exports ? this).Anniversary = JSON.parse((new URLSearchParams(location.search)).get('Anniversary'))

HebrewDate.prototype.isAnniversary = ->
 @hebrewYear.getYearFromCreation() >= Anniversary.year &&
 @monthAndRangeAre(Anniversary.month, [Anniversary.date])
