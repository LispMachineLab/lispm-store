Calc is the calculator that comes with Emacs.  It works in reverse Polish notation, on a stack of
numbers kept to whatever precision you ask for, and goes well past arithmetic: units, matrices,
algebra and calculus.

## What it does

- Keeps integers of any size exactly, fractions as fractions, and decimals to 12 digits, or as
  many as you set.
- Knows complex numbers, vectors and matrices, intervals, times and dates.
- Converts between units, from inches to metres or from knots to kilometres an hour.
- Works on formulas as well as numbers: it simplifies them, differentiates and integrates them,
  and solves equations.

## Using it

LispM shows Calc's stack over a keypad, laid out as a desk calculator's: the digits you press
appear in its display, an operation works on the stack, and **Enter** puts the number typed onto
it.  The buttons over the stack are **Undo**, **Redo** and **Degrees**, which switches the
angles to radians and back; the bottom of the window gives the angles and the precision.

In reverse Polish notation you give the numbers first, then what to do with them.  `6 RET 7 *`
pushes 6, then 7, then multiplies the two:

```
6 RET 7 *     gives 42
2 Q           gives 1.41421356237
```

- The digits, then `RET`, push a number; `+`, `-`, `*`, `/` and `^` take the last two.
- `n` changes the sign, `Q` takes the square root; `DEL` drops the last number, and `TAB`
  swaps the last two.
- `'` takes a whole formula, typed as you would write it.
- `u c` converts a quantity, such as `'10 knot`, to other units; `a d` differentiates a
  formula, `a i` integrates it and `a S` solves it.
- `p` sets the precision; `m d` and `m r` set degrees and radians.
- `U` undoes and `D` redoes.

## Where it comes from

David Gillespie wrote Calc around 1990.  He meant it as a two-week project, after a desk
calculator program would not show him every digit of a large number; the formulas and matrices
of an HP-28 calculator drew it much further.  Calc has been part of Emacs since Emacs 22, in 2007,
and its [manual](https://www.gnu.org/software/emacs/manual/html_mono/calc.html) has a tutorial
of its own.
