What the App Store's applications are made with.  You need not install it yourself: the App
Store installs it before Rotom, 1Password, Security, MYCIN and SHRDLU, which use it, and it works
in any Emacs 30.1 or later.

## What it does

An application has commands: Start, Sign In, Copy Password.  Each has a key, an item in the
application's menu, and, for the main ones, a button along the top of its window; each is
enabled only when it can be used.  LispM Kit lets an application say all of that once, for each
command.  Emacs then shows the keys and the menus as it shows any mode's, and LispM's desktop
makes the window's buttons and its list of keys from the same words, so the menu, the buttons
and the keys always agree.

## For those writing an application

`lispm-kit-define-commands` declares a mode's commands:

```
(lispm-kit-define-commands lispm-rotom-mode
  :menu "Rotom"
  (lispm-rotom-restart
   :key "r" :help "Restart the daemon"
   :label "Restart Daemon" :button "Restart"
   :enabled (and (lispm-rotom-running-p) (not lispm-rotom-busy))))
```

It binds the keys in the mode's keymap, makes the menus with easy-menu, and leaves what was
declared on the mode's symbol as plain data, for any interface to read.  Its
[README](https://github.com/LispMachineLab/lispm-kit) says the rest.  LispM Kit is free software,
under the GNU Affero General Public License, version 3 or later.
