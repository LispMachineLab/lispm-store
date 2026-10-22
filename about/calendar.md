Emacs's calendar shows three months at a time, today marked and the holidays in red.  It also
knows the times of sunrise and sunset, the phases of the moon and a dozen other calendars, and it
keeps a diary of your own in a plain text file.

## What it does

- Lists the holidays of the day, or of the months shown: American ones by default, with
  Christian, Jewish, Islamic, Bahá’í and Chinese holidays, the equinoxes and the solstices.
- Gives the times of sunrise and sunset for the day, once it has asked where you are.
- Lists the phases of the moon for the months shown.
- Says what the day is in other calendars, among them the Hebrew, Islamic, Persian, Chinese,
  Mayan, Julian and French Revolutionary ones.
- Keeps a diary in the file `diary` in your Emacs directory, one entry a line, each beginning
  with its date.  An entry can come back every week, month or year:

```
October 22, 2026 Dentist at 10:00
Thursday Choir practice
```

## Using it

LispM draws the three months as a desktop calendar.  A click on a day goes to it; **Today**, and
the arrows by the months' names, move to today and to earlier and later months.  The bottom of the
window gives the day point is on, with its holidays.

- `C-f` and `C-b` go to the next and the previous day, `C-n` and `C-p` a week on and back.
- `{` and `}` go a month back and on, `[` and `]` a year.
- `.` goes to today, and `g d` to a date you type.
- `h` gives the day's holidays, `a` those of the months shown.
- `S` gives the day's sunrise and sunset, `M` the phases of the moon, `p o` the day in the other
  calendars.
- `d` shows the diary's entries for the day, `m` marks the days that have some, and `i d` writes
  a new one for the day; `i w`, `i m` and `i y` write one for every week, month or year.

## Where it comes from

Edward M. Reingold wrote the calendar for Emacs, from 1988.  The arithmetic behind its dates,
worked out with Nachum Dershowitz, became the book *Calendrical Calculations*, whose Ultimate
Edition Cambridge University Press published in 2018.
