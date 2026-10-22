emacs-slack is a Slack client for Emacs: the channels, direct messages and threads of your
workspaces, each read and written in a buffer.  It signs in as Slack's web app does, with a token
and a cookie, which LispM keeps with auth-source.

## What it does

- The window opens on a list of your workspaces, each over its channels, then the people you
  talk with.  Channels with messages unread are in bold, mentions counted in red; muted ones say
  so.
- A channel opens in the same window, and **Back** returns to the list.
- Messages show their threads, reactions and files; you reply in a thread, react, and attach
  files to what you send.

## Signing in

emacs-slack uses the token and the cookie your browser holds for Slack's web app.  **How to Sign
In** says where to find them with the browser's developer tools: a token beginning `xoxc-`, and
the cookie named `d`, beginning `xoxd-`.  **Add Workspace…** then asks for the workspace's name,
as in NAME.slack.com, your email there, the token and the cookie.

They are kept with auth-source.  Anyone who reads them can read and write in Slack as you, so
prefer an encrypted `~/.authinfo.gpg`, or the macOS Keychain, to a plain `~/.authinfo`.  A token of
a Slack app of your own, beginning `xoxp-`, needs no cookie.

## Using it

In the list:

- `RET` or a double click opens a conversation; `n` and `p` move between them.
- `a` adds a workspace, `r` signs in to it again, `D` signs out, `?` shows how to sign in.

In a channel:

- `RET` sends what you typed; `M-p` and `M-n` bring back the lines typed before.
- `C-c C-f` attaches a file, which is uploaded when you send the message.
- **Thread** opens the thread of the message you are on, or starts one; **React…** adds a reaction
  to it; **Attach…** attaches a file.

## What it needs

`curl`, through which emacs-slack talks to Slack and downloads files.  The App Store installs it
when it is missing.

## Where it comes from

Yuya Minami began emacs-slack in 2015.  It is now kept by the emacs-slack organisation on
[GitHub](https://github.com/emacs-slack/emacs-slack) and published on MELPA as `slack`.  Its
message buffers are built on lui, the chat interface of the IRC client Circe.
