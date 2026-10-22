Table tennis for two players at one keyboard.  Each moves a bat up and down at one side of the
screen to send the ball back; a ball that gets past a bat scores a point for the other side.

## Playing

- The left bat: the left arrow or `4` moves it up, the right arrow or `6` moves it down.
  LispM Desktop adds `C-b` and `C-f` for the same.
- The right bat: the up arrow or `8` moves it up, the down arrow or `2` moves it down.
  LispM Desktop adds `C-p` and `C-n`.
- `p` pauses and resumes, as does the **Pause** button; `q` quits.

Where the ball meets the bat decides where it goes next.  Off the top of the bat it climbs more
steeply, off the bottom it falls more steeply, and off the middle it keeps its slope, so a
player can aim.  The ball bounces off the top and bottom walls, and after each point it is
served again from the middle.  There is no computer player and no last point: the placards
along the window's bottom keep each side's score until you quit.

## Where it comes from

Atari's *Pong* of 1972, built by Allan Alcorn, was the first video game to be a commercial
success, in arcades and then, from 1975, at home.  The Magnavox Odyssey, the first home video
game console, had a table tennis game of its own in the same year.

Benjamin Drieu wrote this version for Emacs in 1999, on `gamegrid.el`, the grid library of
Emacs's Tetris and Snake.
