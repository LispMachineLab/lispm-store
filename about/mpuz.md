A long multiplication in which every digit has been replaced by a letter.  Work out which digit
each letter stands for.

## What it does

Mpuz multiplies a three-digit number by a two-digit one and sets out the whole working: the two
numbers, the two partial products and the total.  Then it puts it into code.  Each digit becomes
one of the letters A to J, the same letter wherever that digit appears, and no two digits share a
letter.

The arithmetic has to hold, and that is the only clue you get.  The last digit of each partial
product follows from the last digits of the numbers multiplied; the last digit of the total is
the last digit of the first partial product; adding up the total, no column carries more than
one.  Each digit you find shows up in every square where it occurs, and the rest of the sum
narrows with it.

Letters still to find are red and digits you have found are green.  When what you know settles a
whole row, Mpuz fills it in for you, in blue.  The bottom of the window counts your errors in this
game and the games you have won.

## Playing

- Click a letter and choose its digit from the menu.
- Or type the letter, then the digit: `A` then `3` says that A stands for 3.
- A wrong guess counts as an error.  When every digit is found, Mpuz rates the game by how few
  errors you made.
- **New Game** draws another puzzle.  **Show Solution** fills in every digit and ends the game.
- `C-g` asks whether to abandon the puzzle.

## Where it comes from

Puzzles of this kind, sums written in letters, are called cryptarithms.  Philippe Schnoebelen
wrote Mpuz for GNU Emacs around 1990, and it came with Emacs 19.  Daniel Pfeiffer later overhauled
it, and since Emacs 22 it has used colours and solved the rows that follow from the digits you
have already found.
