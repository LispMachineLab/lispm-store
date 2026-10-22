Shapes of four squares fall one at a time into a well ten squares wide and twenty deep.  Turn
and slide each one so that it completes whole rows: a full row clears, and the game ends when
the stack reaches the top.

## Playing

- The left and right arrows move the falling shape; the up arrow turns it clockwise.
- The down arrow moves it down a row; `SPC` drops it to the bottom at once.
- `p` pauses and resumes, `n` starts a new game, and `q` ends the game.
- LispM Desktop gives the arrows' work to `C-b`, `C-f`, `C-p` and `C-n` as well, for keyboards
  without arrows.
- **New Game** and **Pause** do the same from the window's buttons.

The next shape waits beside the well.  Every shape that comes to rest scores five to eight
points, by its kind and how it lies, and every row completed makes the shapes fall a little
faster: a row every 0.4 seconds at the start, quicker as the rows mount up.  The placards along
the window's bottom count the score, the rows and the shapes; when the game is over, the strip
under the title bar says so, with the best score so far.

## Where it comes from

Alexey Pajitnov wrote the first Tetris in 1984 at the Computing Centre of the Soviet Academy of
Sciences in Moscow, and named it after the Greek *tetra*, four, and tennis.  Copies spread from
Moscow to the West, and from 1989 it was sold with Nintendo's Game Boy.

Glynn Clements wrote this Tetris for Emacs in 1997, together with `gamegrid.el`, the small
library of grids, timers and score files that Emacs's Snake and Pong are built on as well.
