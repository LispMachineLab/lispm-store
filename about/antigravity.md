Adds Antigravity (`agy`), Google's coding agent, to the editor's agents, alongside LispM Agent,
Claude Code and Codex.  Antigravity runs in a terminal at your project, its sessions and subagents
sit in the same lists as the others, and it can see Emacs's state and work with the other agents.

## What it does

- Start Antigravity with `C-c a y`, with `y` or its button in the agents sidebar, or with
  **New Antigravity Session** in the λ menu.  It opens in a terminal at the root of the current
  project.
- Past sessions appear by project in the agents sidebar and under `C-c a s`, with subagent
  conversations nested under the session that started them, and reopen in the directory they ran
  in with `agy --conversation ID`.  They come from Antigravity's summary database,
  `~/.gemini/antigravity/conversation_summaries.db`, its custom title annotations in
  `~/.gemini/antigravity/annotations/`, and its JSONL transcripts in
  `~/.gemini/antigravity/brain/`.
- Renaming a session updates both its annotation file and the summary database; deleting one
  removes it from the database and deletes its local transcript and session files.  Viewing a
  session's transcript opens its JSONL log in the main window.
- `C-c a r` pastes the region, with its file and position, into the prompt of a running
  Antigravity, without sending it.
- Over MCP, Antigravity can see what only Emacs knows: the selection, which files are open or
  unsaved, Flymake's diagnostics, and LispM's tools and peer messaging.  Every terminal gets a
  server of its own, which Antigravity reaches through the bridge `bin/emacs-mcp` that comes with
  this extension.

## Using it

Run `M-x lispm-antigravity-setup` once.  It runs `agy mcp add emacs` to register the bridge in
`~/.gemini/config/mcp_config.json`.  Every Antigravity session started from the editor afterwards
sees Emacs's state and can message and collaborate with the other agents.

Removing the extension in the App Store takes Antigravity out of the editor straight away; its
sessions remain in Antigravity's store.

## What it needs

The `agy` command on `PATH`.  The App Store does not install Antigravity itself: until the
command is found, it shows the extension greyed out, with the command that configures `agy` on
`PATH`:

```
agy install
```

If `agy` is no longer there later, the extension hides itself.

## Where it comes from

Antigravity is developed by Google; see [antigravity.google](https://antigravity.google).  This
extension, which connects it to the editor, is LispMachineLab's and is not made by Google.
