[ESeq](https://github.com/universalsequences/eseq) is a live sequencer and audio engine for the
Mac, made after Emacs by Alec Resende.  Its interface and its sequencers are written in a Lisp of
its own, eseqlisp, and change while it plays: save a file, and ESeq loads it again.  Its
instruments and effects are written in DGenLisp, a Lisp for sound that ESeq compiles to native
code while it runs.  This application is ESeq's side in LispM, where its Lisp is edited: what you
made for ESeq, made new from ESeq's own, edited, and checked with ESeq's check.

## Using it

`M-x lispm-eseq` shows ESeq, running or not, then your instruments, effects, sequencers and
packages, each with how its last check went.

- `o` opens ESeq, the sequencer itself, in a window of its own.
- `+` makes an instrument or an effect from one of ESeq's own, copied into a folder of yours, or
  a sequencer: a pair of modules, its tick and its panel, sixteen steps played on one track.
- `RET` or `e` edits the line's `dsp.lisp` or module, `u` an instrument's panel, `ui.lisp`.
- `c` checks it with ESeq's own check, which compiles it, plays a test note through it, fails on
  silence or clipping, and draws its panel; `v` shows the panel it drew, `l` what it said.
- `i` installs a package from its git repository, `I` imports one from a folder or an archive.
- `G` opens ESeq's guide to making instruments, effects and sequencers.

ESeq's Lisp files open in a mode of their own: `C-c C-c` saves and checks what the file belongs
to, `C-c C-v` shows the panel the check drew, `C-c C-o` opens ESeq.  A sequencer's module or an
instrument's panel changes in ESeq as you save it; a `dsp.lisp` already on a track is loaded again
from ESeq's Edit menu, *Reload Instrument From Disk*.

## For agents

The *Make things for ESeq* skill lets LispM's agents read where ESeq stands and what you made for
it, make new instruments, effects and sequencers, and check them with ESeq's check until they pass,
following ESeq's own guide.  Ask for "a tape delay with wow and flutter" or "a Euclidean rhythm
sequencer", and the agent writes it, checks it and looks at the panel it drew.

## What it installs

ESeq.app itself comes from ESeq's releases: the App Store downloads the release its catalog names,
signed and notarized by its maker, installs it only if it is that very file, and puts it in the
Applications folder.  It needs a Mac with Apple silicon and macOS 11 or later.  ESeq keeps what you
make in `~/Library/Application Support/com.universalsequences.eseq/` and `~/.eseq.d/`; uninstalling
this application leaves ESeq and all of it in place.  ESeq is free software under the GNU GPL,
version 3.
