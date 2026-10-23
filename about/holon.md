Adds Holon, open-source software that keeps AI agents at work on your own computer, to the
editor's agents, alongside LispM Agent, Claude Code and Codex.  Holon's agents are long-lived:
each has a role, a memory and work it follows through, and picks up the same conversation every
time you come back to it.  Here each agent sits in the same lists as the other agents' sessions,
and opens in Holon's own terminal UI.

## What it does

- Start Holon with `C-c a o`, with `o` or its button in the agents sidebar, or with
  **New Holon Session** in the λ menu.  It makes a Holon agent named after the current project,
  attaches the project to it as its workspace, and opens Holon's terminal UI on it.  Outside a
  project the agent is a chat, named `chat`.
- Holon's agents appear by project in the agents sidebar and under `C-c a s`, under the project
  each works in, or the one attached to it.  Opening one brings up Holon's terminal UI on that
  agent, where its conversation goes on.  The list comes from Holon's background service, asked
  over its local socket, and is asked again only after Holon's database changes.
- Renaming an agent, deleting one, and viewing its conversation as a transcript are done through
  Holon.  Deleting removes everything Holon keeps of the agent; Holon refuses to delete its
  default agent.
- `C-c a r` pastes the region, with its file and position, into the prompt of a running Holon,
  without sending it.

## Using it

Holon needs a model provider before it starts an agent.  Run `M-x lispm-holon-setup` once: it
opens `holon onboard` in a terminal, which asks for a provider, its credentials and a default
model.

Holon's background service is started when you start or open an agent and it is not running.
It keeps your agents working, waiting and following up after Emacs exits; `holon daemon stop`
stops it.  Holon's web interface, at `http://localhost:7878`, shows the same agents.

`lispm-holon-template` names the Holon template new agents are made from, such as
`code-reviewer`; by default they are Holon's own coding assistant.

Removing the extension in the App Store takes Holon out of the editor straight away; its agents
remain in Holon.

## In LispM's sandbox

Holon runs its agents' commands as you, with nothing confining them.  LispM can run Holon's
daemon in its own sandbox instead: in Control Panels, Startup, choose **Add…**, then **Service of
an installed package**, **Holon**, and a sandbox level.  LispM then starts Holon's daemon at every
start, in place of Holon's own, and every command of Holon's agents runs in the sandbox too.

On top of the level's rules, the daemon may read and write Holon's home and the projects you
started Holon agents in, use its own socket and local port, and reach the model providers Holon
has credentials for.  It cannot read your secrets, such as `~/.ssh`, nor write elsewhere.  A new
project starts the daemon again first, so that it may write there.  The daemon in the sandbox
runs while LispM runs, and stops with it.

## What it needs

The `holon` command on `PATH`.  The App Store does not install Holon itself: until the command is
found, it shows the extension greyed out, with the command Holon's authors publish:

```
brew tap holon-run/tap && brew install holon
```

Holon also comes as binaries for macOS and Linux from its releases page.  If `holon` is no longer
there later, the extension hides itself.

## Where it comes from

Holon is developed by its authors and published under the Apache License 2.0 at
[github.com/holon-run/holon](https://github.com/holon-run/holon); see
[holon.run](https://holon.run).  This extension, which connects it to the editor, is
LispMachineLab's and is not made by Holon's authors.
