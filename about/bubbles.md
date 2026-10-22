A board packed with coloured bubbles.  Pop a group of two or more that touch and share a colour,
and the bubbles above drop into the space; clear as much of the board as you can, in big groups.

## Playing

- Click a bubble to pop its group.
- Or move with the arrows, `C-f`, `C-b`, `C-n` and `C-p`, or `f`, `b`, `n` and `p`, and pop the
  group at the cursor with `SPC` or `RET`.
- `u` takes back the last move, as does the **Undo** button; **New Game** deals a fresh board.

A group of *n* bubbles scores (*n* − 1)², so a single group of ten, at 81 points, is worth far
more than five pairs, at 5.  It pays to clear the small groups that keep the big ones apart.
Clearing the whole board adds a bonus of a point for every square on it.  The placards along
the window's bottom show the score and what the group at the cursor would make.

When a column empties, the columns to its right close up to the left.  *Game Theme* in the
**Bubbles** menu sets the difficulty, and starts a new game:

- *Easy*, the default: 10 by 10 bubbles in two colours.
- *Medium*: 15 by 10 in three colours.
- *Difficult*: 20 by 15 in four colours.
- *Hard*: 30 by 20 in five colours.

On *Difficult* and *Hard*, bubbles also slide left along their rows to fill every gap, which
changes the board more with each move.

## Where it comes from

Bubbles is Emacs's version of SameGame, a puzzle that began on Japanese home computers in the
mid-1980s and has since been copied for almost every system, Same GNOME among them.

Ulf Jasper wrote it for Emacs in 2007.
