The Towers of Hanoi, solved while you watch: a tower of discs moved from one peg to another, one
disc at a time, never a larger disc on a smaller one.

## What it does

Hanoi does not ask you to play; it plays.  The tower starts on the left peg and goes to the middle
one, with the third as a spare.  Each disc is lifted up its peg, carried across and lowered onto
the next, by the shortest solution there is.

In LispM Desktop it moves five discs, drawn as raised bars of blue and orange on grey pegs, four
moves a second: 31 moves, a little under eight seconds.

- **Start Again** builds the tower afresh and solves it once more.
- Any key stops it.

## From Emacs

- `M-x hanoi` solves it with three discs, a move a second; a numeric prefix sets how many discs,
  as in `C-u 8 M-x hanoi`.
- `hanoi-move-period` sets the time a move takes, and `hanoi-horizontal-flag` lays the pegs on
  their side.
- `M-x hanoi-unix` shows a tower of 32 discs that has been moving, a move a second, since the start
  of 1970 by the Unix clock, and stands where it would be now.  `M-x hanoi-unix-64` does the same
  with 64 discs.

## Where it comes from

The French mathematician Édouard Lucas published the puzzle in 1883.  Moving a tower takes at
least one move fewer than two to the power of its number of discs: 7 moves for three, 31 for
five, more than a million for twenty.  Solving it, a tower moved by moving a smaller tower twice,
is a classic first lesson in recursion.

Damon Anton Permezel wrote hanoi.el in 1985, and it has come with Emacs since version 17, whose
news suggested it to anyone bored.  In 1999 Alakazam Petrofsky added the sideways pegs, towers of
many discs, timing in real time, colours, and the Towers of Unix.
