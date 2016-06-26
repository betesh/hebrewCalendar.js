# HebrewCalendar.js

### Why

I like being able to keep track of what I need to do each day without being tied to an electronic device.

Since 2003, I've been buying a daily planner so that as things come up,
I can write them in, and (more exciting!) as I complete them, I can cross them out.

This is getting less practical every year for a few reasons:

1. Each year, demand for paper calendars goes down, leading to higher prices and less variety.
2. While many of the things I need to write down are ad-hoc, many others are recurring on a predictable basis--birthdays, holidays, extra prayers.  Last year, it took me about 2 hours to write down all the recurring events in my daily planner.  It's error prone, my hand gets tired, and it's illegible to anyone but me.
3. When you buy a calendar, it comes with holidays you don't care about.  I am happier not knowing when it's Groundhog Day or Canadian Independence Day, or even Father's Day (yes, I am a father).  I want a calendar that contains the events I care about, without the ones I don't care about.

This is my solution.

### How

1. Make sure Ruby is installed
2. ````
        $ cd hebrewCalendar.js && bundle install && middleman server
        ````
3. Visit localhost:4567/

    It will default to the current year, but you can select any year coming up soon,
    or you can put any future year in the URL bar, i.e. localhost:4567?5999

4. Print it!

5. Come back next year and print it again.

### Customization

For privacy reasons, the following files contains sampledata.  Customize them as you please:

source/javascripts/anniversary.js.coffee
source/javascripts/yahrzeits.js.coffee
source/javascripts/birthdays.js.coffee
