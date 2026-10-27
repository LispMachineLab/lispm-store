Your mail, read and written in LispM, laid out as the classic mail programs were: a folder list
on the left, each account's folders under it with how many messages are unread; a table of the
folder's messages, sorted by any of its columns, the unread ones bold under a closed envelope;
the message you choose under it, its headers in a box over its text, its attachments listed
there with their documents' icons.  LispM Mail is made of what Emacs has always had for mail,
imap.el, smtpmail, message mode, and its MIME and HTML libraries, put together in one window.

## Adding an account

The first time, the window offers to add your account.  Type your name, your address and your
password: the servers of Gmail, iCloud, Yahoo, Fastmail, QQ Mail, NetEase and others are filled in
from the address, and those of any other provider are looked up.  The form says what your
provider asks for, as Gmail's and iCloud's app passwords.  **Test Connection** logs in to both
servers before you save.

Your password goes to the macOS Keychain, or to auth-source elsewhere, and nowhere else.

## Using it

The buttons are **Get Mail**, **New**, **Reply**, **Reply All**, **Forward**, **Archive**,
**Delete**, **Search** and **Settings**, and every command has a key:

- `n` and `p` go from message to message, `TAB` from pane to pane, `SPC` reads on.
- `c` writes a message, `r` replies, `a` replies to all, `f` forwards.
- `e` archives, `d` deletes, `m` moves, `u` marks read or unread, `!` flags.
- `/` lists only the messages holding the words you type, as you type them; a click on a
  column's name sorts the table by it.
- `,` opens the settings: accounts, how often mail is checked, how messages are shown.

Pictures on the web that a message shows are not fetched until you ask, as each tells its
sender you read it.

## Writing

Messages are written in Emacs's message mode.  Drafts are kept in your account's Drafts mailbox,
on its server; mail goes in the background, and a message that could not go waits in the Outbox
to be sent again.  Addresses complete from the mail you have.

LispM Mail is Emacs's mail too: the Mail menu of the menu bar, `C-x m` and `mailto:` links all
open it.

## Your mail

An Emacs of each account's own speaks to its servers, so that LispM never waits on the network.
What it fetches is kept on your computer, readable by you alone, so that a mailbox shows at once
and a message read once opens again without the network.
