HebrewDate.prototype.isBedikatHames = ->
  (5 != @gregorianDate.getDay() && @monthAndRangeAre('NISAN', [13])) ||
  (4 == @gregorianDate.getDay() && @monthAndRangeAre('NISAN', [12]))
HebrewDate.prototype.isBiurHames = ->
    (6 != @gregorianDate.getDay() && @monthAndRangeAre('NISAN', [14])) ||
    (5 == @gregorianDate.getDay() && @monthAndRangeAre('NISAN', [13]))
HebrewDate.prototype.isBirthday = (birthday) ->
  @hebrewYear.getYearFromCreation() >= birthday.year &&
    true in (@monthAndRangeAre(month, [birthday.date]) for month in birthday.months)
HebrewDate.prototype.isEighthDayOfPesach = -> @monthAndRangeAre('NISAN', [22])
HebrewDate.prototype.isErebKippur = -> @monthAndRangeAre('TISHRI', [9])
HebrewDate.prototype.isErebPurim = -> @monthAndRangeAre('ADAR', [13]) || @monthAndRangeAre('ADAR_SHENI', [13])
HebrewDate.prototype.isErebRoshHashana = -> @monthAndRangeAre('ELUL', [29])
HebrewDate.prototype.isFirstDayOfPesach = -> @monthAndRangeAre('NISAN', [15])
HebrewDate.prototype.isFirstDayOfRoshHashana = -> @monthAndRangeAre('TISHRI', [1])
HebrewDate.prototype.isFirstDayOfSheminiAseret = -> @isSheminiAseret() && @is1stDayOfYomTob()
HebrewDate.prototype.isFirstYomTobOfPesach = -> @monthAndRangeAre('NISAN', [15, 16])
HebrewDate.prototype.isFirstYomTobOfSukkot = -> @monthAndRangeAre('TISHRI', [15, 16])
HebrewDate.prototype.isKalHamira = -> @isShabbat() && @monthAndRangeAre('NISAN', [14])
HebrewDate.prototype.isNesiim = -> @monthAndRangeAre('NISAN', [1..13])
HebrewDate.prototype.isNinthOfAb = HebrewDate.prototype.is9Ab
HebrewDate.prototype.isSecondDayOfRoshHashana = -> @monthAndRangeAre('TISHRI', [2])
HebrewDate.prototype.isSeventeenthOfTamuz = HebrewDate.prototype.is17Tamuz
HebrewDate.prototype.isSeventhDayOfPesach = HebrewDate.prototype.is7thDayOfPesach
HebrewDate.prototype.isShabbatHazon = -> @isShabbat() && @monthAndRangeAre('AB', [4..9])
HebrewDate.prototype.isShabbatNahamu = -> @isShabbat() && @monthAndRangeAre('AB', [11..16])
HebrewDate.prototype.isShabbatShuba = -> @isShabbat() && @monthAndRangeAre('TISHRI', [3..8])
HebrewDate.prototype.isSimhatTorah = -> @isSheminiAseret() && @is2ndDayOfYomTob()
HebrewDate.prototype.isSixthDayOfPesach = -> @monthAndRangeAre('NISAN', [20])
HebrewDate.prototype.isSixthDayOfSukkot = -> @monthAndRangeAre('TISHRI', [20])
HebrewDate.prototype.isTefillatHaParnasa = -> 2 == @gregorianDate.getDay() && "בְּשַׁלַּח" == @sedra()
HebrewDate.prototype.isTenthOfTebet = HebrewDate.prototype.is10Tevet
HebrewDate.prototype.isUshpizin = -> @monthAndRangeAre('TISHRI', [14..20])
HebrewDate.prototype.isZecherLeMahasitHaSheqel = HebrewDate.prototype.isTaanitEster
