Adds OpenClaw, the open-source personal assistant that answers wherever you chat with it, to the
editor's agents, alongside LispM Agent, Claude Code and Codex.  OpenClaw keeps its conversations
in its Gateway, a service on this computer or on another, which its terminal UI, its web UI and
its chat channels share.  Here your conversations with it sit in the same lists as the other
agents' sessions, and open in OpenClaw's own terminal UI.

## What it does

- Start OpenClaw with `C-c a k`, with `k` or its button in the agents sidebar, or with
  **New OpenClaw Session** in the λ menu.  The Gateway makes a session working in the current
  project, and OpenClaw's terminal UI opens on it.  Outside a project the session is a chat.  A
  Gateway that cannot work in the project, as one before OpenClaw 2026.10, or one on another
  computer that lacks it, makes a chat instead, and says so.
- Your conversations with OpenClaw appear in the agents sidebar and under `C-c a s`: those begun
  in the editor, in OpenClaw's web UI, or in a chat app such as Telegram, by the project each
  works in, else as chats.  Group chats, OpenClaw's subagents and its scheduled jobs are left out.
  Opening one brings up the terminal UI on it, where the conversation goes on.
- The list is asked of the Gateway in the background, again after OpenClaw's sessions change on
  this computer, or after half a minute, so a Gateway on another computer serves as well.
- Renaming a session gives it a label, which OpenClaw keeps unique.  Deleting one has the Gateway
  delete it with its transcript; OpenClaw refuses to delete an agent's main session.  Viewing a
  transcript shows what you wrote and what OpenClaw answered.
- `C-c a r` pastes the region, with its file and position, into the prompt of a running OpenClaw,
  without sending it.

## Using it

OpenClaw needs a model provider and a running Gateway before it starts a session.  Run
`M-x lispm-openclaw-setup` once: it opens `openclaw onboard` in a terminal, which asks for a
provider and its credentials and sets the Gateway up as a service of this computer, or connects
to one elsewhere.  If the Gateway is not running when you start a session, the editor says so;
`openclaw gateway start` starts it.

`lispm-openclaw-agent` names the OpenClaw agent new sessions are made for; by default they are
for the Gateway's default agent.

Removing the extension in the App Store takes OpenClaw out of the editor straight away; your
conversations remain in the Gateway.

## With the other agents

With LispM Agent 0.8.0 or later, an OpenClaw session open in a terminal works with the other
agents: LispM's own, and Claude Code, Codex, Hermes and Holon.

- What they send it, as `[Message from codex]` or `[Request R1 from claude]`, reaches it through
  the Gateway as your next message, after what it is doing.  The terminal UI shows it.
- With the Gateway on this computer, the session lists the others, messages them, asks them for
  things and answers their requests, and finds and uses LispM's skills and tools.  They come to
  it as an MCP server of its own among the Gateway's, `lispm_…`, which is on for that session
  alone and taken away when the terminal closes.  A LispM tool that changes something waits for
  your approval in the editor.
- With the Gateway on another computer, which cannot reach the editor, the session gets no tools.
  It still takes messages, and its final reply to a request is its answer.

## What it needs

The `openclaw` command on `PATH`.  The App Store does not install OpenClaw itself: until the
command is found, it shows the extension greyed out, with the command OpenClaw's authors publish:

```
curl -fsSL https://openclaw.ai/install.sh | bash
```

OpenClaw also comes from npm, as the package `openclaw`.  If `openclaw` is no longer there later,
the extension hides itself.

## Where it comes from

OpenClaw is developed by its authors and published under the MIT License at
[github.com/openclaw/openclaw](https://github.com/openclaw/openclaw); see
[openclaw.ai](https://openclaw.ai).  This extension, which connects it to the editor, is
LispMachineLab's and is not made by OpenClaw's authors.
