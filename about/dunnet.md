A text adventure in the manner of Zork.  You begin at the dead end of a dirt road lined with royal
palms, a lamp in your hand and a shovel at your feet, and find your way by typing what to do.

## Playing

Type a command and press `RET`.  Dunnet reads a verb, usually with an object after it.

- Move with `north`, `south`, `east`, `west`, `northeast`, `southeast`, `northwest`,
  `southwest`, `up`, `down`, `in` and `out`, or the short forms `n`, `s`, `e`, `w`, `ne`, `se`,
  `nw`, `sw`, `u` and `d`.
- `look` describes where you are; `examine`, or `x`, looks closely at one thing.
- `take` and `drop` pick things up and put them down; `inventory`, or `i`, lists what you carry.
- `dig`, `climb`, `eat`, `put` and `type` do what they say, where it makes sense.
- `save` and `restore`, each followed by a file name, keep a game for another day.

The buttons **Look**, **Inventory**, **Score** and **Help** say their word for you, as if you had
typed it.

## What to expect

You score by bringing treasures to a certain place, whole and untarnished, out of a possible 90
points; `score` tells you how you stand, and `help` gives a few hints from the author.  Keep the
lamp: some places are pitch dark, and unwise to wander in without a light.  Not all of the world is
out of doors: there are old buildings, a maze, and computers at whose consoles you can `type`,
with logins, files and a network of their own.  Reach all 90 points and an endgame opens.

## Where it comes from

Ron Schnell wrote Dunnet in 1982, in MacLisp on a DECSYSTEM-20, and rewrote it in Emacs Lisp in
1992.  It has come with GNU Emacs since version 19.17.  It plays just as well without a window:
`emacs --batch -f dunnet` runs it in a terminal.
