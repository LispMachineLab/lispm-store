Telega is a Telegram client for Emacs: your chats, groups and channels in one list, each opening
in a buffer where you read and write.  It talks to Telegram through TDLib, Telegram's own library,
by way of telega-server, a small program built once on your Mac.

## What it does

- The list shows your chats with how many messages each has unread; `/` filters it and `\` sorts
  it.
- A chat shows its photos, stickers, voice and video notes, files, replies and reactions.
- You reply to, edit, forward and react to messages, and send text, photos and files.

## Getting started

The first time it opens, the window says what Telega still lacks, and installs it:

1. TDLib, version 1.8.66 or later.  Homebrew's release is older, so the Installer builds TDLib
   from its latest sources, which takes a while.
2. A C compiler, from Apple's Command Line Tools.
3. telega-server itself: **Build telega-server** compiles it, in about a minute.

Telega then signs in with your phone number and the code Telegram sends you, and with your
password when your account has two-step verification.

## Using it

In the list:

- `RET` opens a chat; `n` and `p` move between chats.
- `s` searches, `N` starts a new chat, `J` joins a group or channel by its link, `Q` quits Telega.
  **Search…**, **New Chat…** and **Join by Link…** do the same.

In a chat:

- `RET` sends what you typed; `M-p` edits the message you sent last.
- `C-c C-a` attaches a file, a photo or another kind of attachment; `C-c C-v` attaches what you
  copied.
- On a message, `r` replies, `e` edits, `f` forwards and `!` reacts.
- **Back** returns to the list; **Mark Read** marks the whole chat read.

## What it needs

TDLib and a C compiler, as above; the App Store installs both.

## Where it comes from

Zajcev Evgeny began Telega in November 2016 and develops it on
[GitHub](https://github.com/zevlg/telega.el); its [manual](https://zevlg.github.io/telega.el/)
covers its many options.  [TDLib](https://github.com/tdlib/td) is the library Telegram publishes
for building clients.
