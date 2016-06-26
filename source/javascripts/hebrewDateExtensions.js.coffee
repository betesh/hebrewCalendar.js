HebrewDate.prototype.isBirthday = (birthday) ->
  @hebrewYear.getYearFromCreation() >= birthday.year &&
    true in (@monthAndRangeAre(month, [birthday.date]) for month in birthday.months)
