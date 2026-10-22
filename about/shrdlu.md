Talk in English with SHRDLU about a table of coloured blocks, pyramids and a box, and watch its
hand move them.  Terry Winograd wrote SHRDLU at MIT between 1968 and 1970; this is the Common
Lisp port of the 1990s, run in Emacs.

## What it does

SHRDLU parses each sentence, works out which things on the table you mean, and then answers a
question or plans the moves a command needs.  Told to pick up a big red block, it first lifts
away the green block standing on it.  Told to grasp the pyramid, it says it does not know which
pyramid you mean.  Asked what the box contains, or how many blocks are not in it, it looks and
tells you.

Under the dialogue, in the same window, a drawing of the table follows the hand as it rises,
crosses and comes down, carrying what it has grasped; a thing SHRDLU picks out flashes.  The
code that survives is not the whole of SHRDLU: some words of Winograd's published dialogue are
missing from it, and some of the later questions, such as when it picked a thing up, it no
longer understands.

## Using it

- Type a sentence, as `pick up a big red block.`, and press `RET`.
- The **Sentences** menu holds the lines of the 1972 dialogue, in order; choosing one says it.
  **Say…** (`C-c C-s`) asks for one, with completion.
- **New Dialogue** (`C-c C-n`) starts again, with the blocks back where they began.

## Where it comes from

Winograd wrote SHRDLU for his doctoral work at MIT, in Lisp and Micro-Planner, and published it
with its dialogue in *Understanding Natural Language* (1972).  Its grammar, its reasoning about
meaning and its planning of moves worked together over one small world, and it became one of the
best-known programs of early research in artificial intelligence.  Its name comes from ETAOIN
SHRDLU, the order of the letter keys on a Linotype machine, the commonest letters of English
first.

In the 1990s the program was ported to Common Lisp.  Tom Sgouros revived that port in 2014 as
[www-shrdlu](https://github.com/tsgouros/www-shrdlu), and LispMachineLab's fork of it keeps fixes
checked against the code of 1972.

## What it needs

`git`, to fetch SHRDLU's Common Lisp on its first start, and the Common Lisp extension, which
runs it in a batch Emacs beside yours; the App Store installs both.
