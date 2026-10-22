[Rotom](https://github.com/RyanKung/rotom) is a small gateway on your Mac: sign in once to the
accounts you have, OpenAI's Codex, xAI's Grok, Kiro or Vercel's AI Gateway, and any program that
speaks OpenAI's API or Anthropic's reaches all their models at one address,
`http://127.0.0.1:14550`.  LispM's agents are such programs, and so are Claude Code and the
official SDKs.  This application is Rotom's window in LispM: its daemon, its accounts, its models,
and the model LispM's agents use.

## Using it

`M-x lispm-rotom` shows the daemon, the accounts and the models, with the buttons **Start** or
**Stop**, **Restart**, **Sign In…**, **Refresh Tokens** and **Use for LispM…**.

- `RET` on an account signs in to it; on a model, has LispM's agents use it; on the daemon,
  starts or stops it.
- `s` starts the daemon, installing it as a service the first time, or stops it; `r` restarts it.
- `l` signs in to an account.  Codex, Grok and Kiro open in your browser; when you are signed in,
  the browser comes back to Emacs by itself and Rotom has what it needs.  Vercel takes its key,
  typed in the minibuffer.
- `R` renews the accounts' tokens; `v` shows the daemon's log of errors.
- `u` has LispM's agents use the model on the line, saved for the conversations you start next;
  `x` stops them using Rotom.
- `w` copies a model's name or the daemon's address; `U` updates Rotom itself.

The first time it opens, Rotom's program is installed with Cargo, Rust's package manager, which
the Installer brings with it if it is missing.

## For agents

The *Use Rotom* skill lets LispM's agents read where Rotom stands, list its models, read its log,
renew its tokens, start or restart its daemon and, once you approve, choose the model they use.
Signing in stays yours.

## Privacy

Rotom keeps your accounts' credentials in `~/.rotom/`; this application never reads them.  A key
you type is handed to Rotom on its standard input and forgotten.  Nothing leaves your Mac but what
Rotom itself sends to the accounts you signed in to.  Rotom is RyanKung's, free software under
the GNU LGPL.
