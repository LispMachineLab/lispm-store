Gomoku against Emacs.  You and Emacs put stones in turn on the points of a board of 15 lines by
15, and the first to have five in an unbroken row, across, down or on a diagonal, wins.

## Playing

- Click a free point to put your stone there.
- Or move with the arrows or `C-f`, `C-b`, `C-n` and `C-p`, or with `h`, `j`, `k` and `l`, and
  diagonally with `y`, `u`, `b` and `n`; then `RET`, `SPC` or `x` plays where you are.
- `C-c C-b` takes back your last move, with Emacs's answer to it; `C-c C-r` resigns.
- **New Game**, **Take Back** and **Resign** are on the window's buttons.

As a game starts, Emacs asks whether it may play first.  You play black and Emacs white; the
last stone played is ringed in red.  The placards along the window's bottom say whose move it
is and keep the count of games won, lost and drawn.

Emacs does not search ahead.  It looks at every run of five points on the board, scores each by
the stones already in it, and plays on the free point whose runs add up to the most.  A run
holding stones of both colours counts for nothing, and its own stones count for more than
yours, so it completes a five of its own when it can, and otherwise blocks a four of yours before
anything else.

## Where it comes from

Gomoku comes from Japan, where it is played with the stones and board of go.  With no limits on
where the first player may play, the first player can force a win, which is why tournament
players use restricted forms such as renju.  Emacs plays the free game, without restrictions.

Philippe Schnoebelen wrote this Gomoku for Emacs in 1988.
