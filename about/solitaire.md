Peg solitaire on the cross-shaped board of 33 holes.  Every hole but the middle one starts with a
peg.  A peg jumps over a neighbour into the empty hole beyond, along a row or a column, and the
peg it jumps over comes off the board.  The aim is to leave a single peg, in the middle if you
can.

## Playing

- Click a peg, then one of the holes it can jump to; those holes are marked with a dot.
- With the keys, go from hole to hole with the arrows or `C-f`, `C-b`, `C-n` and `C-p`.
  `S-<right>`, `S-<left>`, `S-<up>` and `S-<down>` jump the peg you are on that way, as does
  `RET` followed by a direction.
- `C-/` takes back a jump, as does the **Undo** button; **New Game** sets the board up again.
- `SPC` counts the jumps still open to you.
- `s`, before the first jump, plays most of a solution for you, stopping with five pegs left.

The placard along the window's bottom counts the pegs left, and the strip under the title bar
says when only one remains.  A game can also end with several pegs stranded apart, none of them
able to jump; `SPC` tells you when it has come to that.

A perfect game is thirty-one jumps, each taking one of the 32 pegs off, until one is left.

## Where it comes from

Peg solitaire is first recorded in France at the end of the seventeenth century.  The cross of
33 holes is the English board; the French board has four holes more, 37 in all, and other
shapes have been played too.

Jan Schormann wrote this version for Emacs in 1994.
