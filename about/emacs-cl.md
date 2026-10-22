Common Lisp, written in Emacs Lisp: Lars Brinkhoff's Emacs Common Lisp, in LispMachineLab's fork
for Emacs 30 and 31.  It gives you a Common Lisp listener, and it is the Common Lisp that MYCIN
and SHRDLU run on.

## What it does

Emacs Common Lisp implements most of the language: packages, readtables, lexical closures,
multiple values, bignums and ratios, arrays, structures, conditions, `LOOP` and `FORMAT`.  Its
object system is partial, with primary methods only, and its pretty printer is unfinished.
Common Lisp functions are compiled to Emacs's byte code.

It runs in a batch Emacs beside the one you work in, so that it neither changes your Emacs nor
holds it up during a long computation.  The first start compiles it, which takes a few seconds;
it is compiled again only when its sources or your Emacs's version change.

## Using it

`M-x emacs-cl-repl` opens the listener, `*Common Lisp*`.  Type a form after the prompt, which
names the current package, and press `RET`; a form may run over several lines.  The values are
printed below it, and after an error the listener says what went wrong and carries on.  `M-p`
and `M-n` bring back earlier input.

```
COMMON-LISP-USER> (defun square (x) (* x x))
SQUARE
COMMON-LISP-USER> (square 12)
144
COMMON-LISP-USER> (expt 2 100)
1267650600228229401496703205376
COMMON-LISP-USER> (/ 1 3)
1/3
```

For programs of your own, `emacs-cl-start` starts Common Lisp in a buffer, loading files and
evaluating forms, as MYCIN and SHRDLU do.

## Where it comes from

Lars Brinkhoff began [Emacs Common Lisp](https://github.com/larsbrinkhoff/emacs-cl) in 2003; it
ran on Emacs up to version 24.  [LispMachineLab's fork](https://github.com/LispMachineLab/emacs-cl)
brings it to Emacs 30 and 31, with the aim of running existing Common Lisp programs as they were
written, MYCIN from Peter Norvig's *Paradigms of Artificial Intelligence Programming* among them.
It is free software, under the GNU General Public License, version 2 or later.
