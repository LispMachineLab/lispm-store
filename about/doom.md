Doom in a buffer: the first-person shooter of 1993, its levels drawn with OpenGL, as an image
among the buffer's text.  It plays Freedoom: Phase 1, a free game of new levels, monsters and
music made for Doom's engine, downloaded the first time it starts; your own `doom.wad` plays as
well.

## Playing

- `W` `A` `S` `D` or the arrows move, `Q` and `E` turn.
- `F` or `J` fires; `SPC` opens doors and works switches.
- `1` to `7` choose a weapon, `Tab` shows the map.
- `Esc` opens the menu: a new game, saving and loading, options.
- `C-c C-q` quits; `C-x` and `M-x` work as anywhere else.

Emacs hears a key pressed and repeated, never released, so a key counts as held until it stops
repeating: a short tap moves a little further than it would in a game of its own.  The game
stops while its window is hidden or LispM is not in front.

## What it needs

Emacs 32, as LispM's experimental install has it: the App Store installs lispm-doom only there,
and the Kernel panel of Control Panels switches LispM to it.  Its engine links with Homebrew's
SDL2_mixer, libsndfile and libzip, which the App Store installs with it.

## Where it comes from

id Software released Doom in December 1993, and the source of its engine in 1997.  This engine
is dsda-doom, the descendant of PrBoom+, whose OpenGL renderer draws here in a framebuffer of
its own, its window taken out; each frame goes to Emacs as an image, scaled up to fill the
window.  Freedoom has been made by
its contributors since 2001, under a BSD licence.
