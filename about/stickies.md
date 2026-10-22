Small paper notes in seven colours that sit on the desktop, each in a window of its own, as on a
Mac of the 1990s.  Every note is also a heading in one org file, which agents can read.

## What it does

- The note in front shows a classic pinstriped title bar, with a close box on the left, a zoom
  box on the right and a grow box in the lower corner; the notes behind it are plain paper.
  Colours and boxes were sampled from the original.
- The **Color** menu offers Yellow, Blue, Green, Pink, Purple, Gray, and Black & White.
- Double-click a title bar to roll the note up to that bar alone, labelled with the note's first
  line; double-click again to unroll it.  The zoom box sizes the note to fit its text, and a
  second click restores it.
- Notes are saved a moment after you stop typing.  The close box deletes a note, asking first if
  there is text in it.  Quitting Stickies only hides the notes; they reappear in the same places
  next time.
- **Import Text…** and **Export Text…** in the **File** menu turn a text file into a note, and a
  note back into a file.

## Where the notes are kept

All notes are stored in `~/.emacs.d/stickies.org` (`lispm-stickies-file`).  Each is a heading
named after its first line, with its colour, position and dates in a property drawer and its text
below, so Org and agents can search it.  Stickies rewrites the file while it runs: edit it by hand
only when Stickies is closed.

## Using it

In a note:

- `C-c C-n` makes a new note; `C-c C-k` deletes the current one.
- `C-c C-f` and `C-c C-b` move to the next and the previous note.
- `C-c C-l` picks a colour, `C-c C-r` rolls the note up or down, `C-c C-z` zooms it.
- `C-c C-d` shows when the note was created and last modified.
- `C-c C-q` quits Stickies.

While Stickies is in front, the **File**, **Note** and **Color** menus in the menu bar hold the
same commands.  Removing Stickies in the App Store quits it but keeps the file.

## Where it comes from

Jens Alfke wrote Stickies at Apple, and it first shipped with System 7.5 in 1994.  macOS still
includes it.
