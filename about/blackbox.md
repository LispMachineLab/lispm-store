Four balls are hidden in a box of eight squares by eight.  You cannot look inside: you can only
fire rays in from the edges, see where they come out, and work back to where the balls must be.

## How rays behave

A ray travels in a straight line until a ball is near.

- A ray that meets a ball head-on is absorbed: a **hit**.
- A ray about to pass a ball that lies diagonally ahead of it turns through a right angle, away
  from the ball.  It may turn several times before it leaves the box somewhere else: a
  **detour**.
- A ray with a ball diagonally ahead on both sides turns back, and so does one with a ball
  diagonally beside the square where it would enter: a **reflection**.

The squares around the box keep the record: H for a hit, R for a reflection, and the same number
at both ends of each detour.

## Playing

- Click a square on the edge, or move to it and press `SPC`, to fire a ray from it.
- Click a square inside the box, or press `SPC` on it, to guess that a ball is there; do it again
  to take the guess back.
- `C-f`, `C-b`, `C-n` and `C-p`, or the arrow keys, move; `C-a` and `C-e` jump to the left and
  right edges.
- Once you have guessed as many balls as are hidden, **Done** (or `RET`) opens the box.  Wrong
  guesses are crossed out, and the balls you missed appear in grey.

The bottom of the window counts the balls hidden, your guesses and the score.  **New Game** hides
a fresh set.  Started from Emacs, a numeric prefix sets how many balls to hide, as in
`C-u 6 M-x blackbox`.

## Scoring

Lower is better.  A hit or a reflection costs one point and a detour two, so every ray you fire
costs something; each ball guessed in the wrong place adds five when the box is opened.

## Where it comes from

The game is Black Box, which Eric Solomon devised as a board game in the 1970s.  F. Thomas May
wrote this version in Emacs Lisp in the mid-1980s, and Eric S. Raymond improved its interface in
1991.
