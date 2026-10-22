Steer a snake round a walled field to eat the fruit that appears in it, one at a time.  Each
fruit makes the snake a square longer, and the game ends when its head runs into a wall or into
its own body.

## Playing

- `C-f`, `C-b`, `C-p` and `C-n`, or the arrows, turn the snake right, left, up and down.
- A turn straight back on itself is ignored; turns pressed in quick succession wait their turn,
  so none is lost between two steps.
- `p` pauses and resumes, `n` starts a new game, and `q` ends the game.
- **New Game** and **Pause** do the same from the window's buttons.

The snake sets off five squares long, heading right, and moves a square every fifth of a second.
It never speeds up: what makes the game harder is its own length, which leaves less room to turn
in with every fruit.  The placards along the window's bottom show the score, one point a fruit,
and the snake's length; when the game is over, the strip under the title bar says so, with the
best score so far.

## Where it comes from

Snake descends from *Blockade*, an arcade game Gremlin released in 1976, in which two players
steer lines that grow behind them and each tries to make the other crash.  The game of a single
snake that grows as it eats followed on many machines, mobile phones among them.

Glynn Clements wrote this Snake for Emacs in 1997, a month after his Tetris, on the same
`gamegrid.el`.
