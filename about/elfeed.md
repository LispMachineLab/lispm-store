Elfeed reads the web feeds that blogs, news sites and podcasts publish, in RSS, Atom or JSON, and
keeps every entry it fetches in a database of its own.  Its window lists the entries newest first,
and a filter of a few words narrows the list by tag, age, feed or text.

## What it does

- Fetches every feed you have added at once, in the background, through curl.
- Marks each new entry `unread`, and takes the mark away when you open it.  Tags of your own can
  be added to entries by hand.
- Filters the list: `+unread` keeps the entries with a tag, `-unread` those without it, `@2-weeks`
  those of the last two weeks, `=` before a word those of a feed whose title or address matches
  it, and any other word the entries whose title or link matches it.  It opens on
  `@6months +unread`.
- Shows an entry as a page in its window, with its links; a podcast's file can be saved, or played
  in EMMS.
- Reads and writes lists of feeds as OPML, the format other feed readers export.

## Using it

The buttons along the top of its window are **Update**, which fetches every feed, **Add Feed…**,
**Filter…** and **Open**.  The bottom of the window counts the entries shown and those unread, and
says when the feeds were last fetched.  Until it has feeds, the window offers **Add Feed…** and
**Import OPML…** instead.

- `n` and `p` move through the list; `RET` opens the entry on the line.
- `s` filters as you type; `c` puts back the filter it opens with.
- `r` marks the entry read, `u` unread; `+` and `-` add and remove a tag.
- `b` opens the entry in the web browser; `w` copies its link.
- `G` fetches the feeds, as **Update** does.

In an entry, `n` and `p` go to the next and the previous one, `SPC` scrolls, `d` saves a podcast's
file and `P` plays it in EMMS.  **Back** returns to the list.

## Where it comes from

Christopher Wellons wrote Elfeed in 2013 and released it into the public domain.  In 2026 Karthik
Chikmagalur, Ihor Radchenko and Daniel Mendler took it over, under the
[emacs-elfeed](https://github.com/emacs-elfeed/elfeed) project on GitHub, and released its
version 4 that June.
