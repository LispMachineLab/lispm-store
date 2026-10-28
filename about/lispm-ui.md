What LispM's applications are drawn with: their forms, and the ways they ask you something.  You
need not install it yourself: LispM installs it, and the App Store installs it before the
applications that use it.  It works in any Emacs 30.1 or later, in a window or on a text terminal.

## What it does

An application writes a form as data: its fields, as a name, a picture, a choice or a check box,
and what to do with what you fill in.  LispM UI lays it out as a dialog, the labels in a column
and the buttons at the bottom right, and checks it before it is sent: a field you must fill, a
value it cannot take.  It asks you something the same way wherever it is: an alert and its
buttons, a question to agree to, a choice from a menu, a file to open.

On LispM's desktop all of these are drawn in its classic look, in its own alerts, menus and Choose
a File dialog.  In Emacs without the desktop, or on a text terminal, they are Emacs's own fields
and minibuffer, so the application works just the same.  Every one of them works from the
keyboard: in a form, Tab and Shift-Tab go from field to field and C-c C-c sends it; in an alert,
Return presses the default button and Escape the Cancel button.

Its words are shown in English, German, French, Japanese or Chinese, Simplified or Traditional,
in the language LispM speaks.

## For those writing an application

`lispm-ui-form` shows a form and calls back with its values:

```
(lispm-ui-form "New Note"
  '((title :type text :label "Title" :required t)
    (color :type choice :label "Colour"
           :choices ((yellow . "Yellow") (blue . "Blue")))
    (pinned :type check :label "Keep on top"))
  :submit "Create"
  :on-submit (lambda (values) (my-notes-create values)))
```

`lispm-ui-confirm` asks a question, `lispm-ui-choose` shows choices and `lispm-ui-choose-file`
asks for a file, each drawn by whatever shows the application, or asked in the minibuffer.  Its
[README](https://github.com/LispMachineLab/lispm-ui) says the rest.  LispM UI is free software,
under the GNU Affero General Public License, version 3 or later.
