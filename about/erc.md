ERC is the IRC client that comes with Emacs.  It connects to Internet Relay Chat networks,
Libera.Chat or another, and gives each channel and each private conversation a buffer of its own,
with the line you type at the bottom.

## What it does

- The window opens on a list of the networks you are on, each over its channels and the people
  talking with you.  A conversation with messages unread is in bold, with how many on its right,
  in red where someone names you.
- It connects with TLS, unless you choose port 6667, and keeps the networks and the channels you
  join, connecting and joining them again the next time it opens.
- Where a server needs a password, ERC looks it up with auth-source, so none need be written into
  your configuration.

## Using it

**Connect…** asks for a server, Libera.Chat's by default, a port and a nickname.  **Join…** asks
for a channel, adding the `#` when you leave it out.  **Disconnect** leaves the network of the line
you are on; it is still kept, to connect to again.

In the list:

- `RET` or a double click opens a conversation; `n` and `p` move between them.
- `c` connects, `j` joins a channel, `d` disconnects, `r` connects again, `D` forgets a network.

A channel opens in the same window, its topic beside the buttons; **Back** returns to the list
and **Leave** parts the channel.  The window's bottom shows the network, your nickname and how
many are in the channel.

- `RET` sends what you typed; `TAB` completes a nickname or a command.
- `M-p` and `M-n` bring back the lines typed before.
- `C-c C-j` joins another channel; `C-c C-p` leaves this one.
- Commands follow a slash: `/join #emacs`, `/query` and a nickname to talk with one person, `/me`
  to say what you are doing, `/quit` to disconnect.

## Where it comes from

Alexander L. Belikoff and Sergey Berezin wrote ERC in the late 1990s and stopped at version 2.0 in
1999.  Mario Lang and Alex Schroeder took it up in 2001.  ERC 5.1 went into Emacs 22, released in
2007, and since about 2009 it has been developed as part of Emacs itself.  The channels of Emacs
and ERC moved to Libera.Chat in 2021.  The [ERC page](https://www.gnu.org/software/emacs/erc.html)
has its manual.
