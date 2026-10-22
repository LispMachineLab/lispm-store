John Conway's Game of Life on a field of squares.  Each generation, every cell lives, dies or is
born by how many of its eight neighbours are alive.

## What it does

The rules are three:

- A live cell with two or three live neighbours lives on.
- An empty cell with exactly three live neighbours comes alive.
- Every other cell dies, or stays empty.

Nobody plays; the pattern you start with decides everything after it.  From these rules come still
lifes that never change, oscillators that return to their shape every few generations, and
gliders, five cells that walk diagonally across the field, a square every four generations.
Emacs starts from one of a set of patterns, chosen at random: among them a row of ten cells,
Gosper's glider gun, the pentadecathlon and the queen bee shuttle.

## Playing

The field runs by itself, a generation every quarter of a second, and the bottom of the window
shows the generation and how many cells are alive.  It stops when all life has perished.

- **Stop** halts it and **Go** lets it run again; `SPC` does either.
- **Next**, or `n`, shows one more generation and stops there.
- **New Pattern**, or `r`, starts over from another pattern.

From Emacs, `M-x life` runs until a key is pressed; a numeric prefix sets the pause between
generations in tenths of a second, as in `C-u 2 M-x life`.

## Where it comes from

The mathematician John Horton Conway devised the game in 1970, and Martin Gardner made it known in
his Mathematical Games column in *Scientific American* that October.  Bill Gosper's glider gun,
found the same year, was the first pattern shown to grow without end.  Kyle Jones wrote life.el,
which has come with Emacs since version 18.52, in 1988.
