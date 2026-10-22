Browse your 1Password vaults from Emacs through `op`, 1Password's command-line tool: find items as
you type, copy usernames, passwords and one-time codes, and add logins with generated passwords.
1Password belongs to AgileBits, who neither made nor endorse this application.

## Using it

`M-x lispm-1password` lists your items by title, with the buttons **New…**, **Open**,
**Copy Password**, **Copy Code**, **Search…** and **Show All**.

- `RET` opens an item to show its fields, websites, notes and tags.
- `s` or `/` filters the list as you type.  `v` limits it to one vault, `k` to one kind of item,
  `*` to favourites; `a` shows everything again.
- `u`, `c` and `t` copy the username, the password and the one-time code.
- `w` visits the item's website; `o` shows it in the 1Password app.
- `f` marks the item a favourite or unmarks it; `d` moves it to the Archive.
- `+` adds a login, with a password op generates and copies for you.
- `g` reloads the vaults; `L` locks 1Password, signing op out and dropping everything read.

Inside an item, `u`, `c`, `t`, `w`, `o`, `f` and `d` work as in the list; `RET` copies the field
on its line, `r` reveals a hidden value, `n` and `p` step through the fields, and `q` returns to
the list.

## Secrets

- A secret is fetched from op at the moment you copy or reveal it, and wiped once used.
- Copied secrets go to the system clipboard rather than the kill ring.  They are cleared after 90
  seconds, or when Emacs exits, provided nothing newer has been copied
  (`lispm-1password-clear-seconds`).
- A revealed value is hidden again after 30 seconds (`lispm-1password-reveal-seconds`).
- When you add a login, its password is passed to op through standard input, so it never appears
  among a program's arguments.
- Nothing goes to disk.  Titles and usernames are held in memory until you lock or quit Emacs.

## What it needs

- **op**, which the App Store installs with the application.
- **An account op can use.**  With the 1Password app, enable *Integrate with 1Password CLI* in its
  settings, under Developer, and op asks the app to unlock, by Touch ID or your password.
  Without the app, run `op account add` once in a terminal; Emacs then asks for the password in
  the minibuffer when unlocking, and passes it to op.
