Adds Hermes, the open-source agent by Nous Research, to the editor's agents, alongside LispM
Agent, Claude Code and Codex.  Hermes runs in a terminal at your project, its sessions sit in the
same lists as the others, and it can see Emacs's state.

## What it does

- Start Hermes with `C-c a h`, with `h` or its button in the agents sidebar, or with
  **New Hermes Session** in the λ menu.  It opens in a terminal at the root of the current
  project.
- Past sessions appear by project in the agents sidebar and under `C-c a s`, and reopen in the
  directory they ran in.  They come from Hermes's own database, `~/.hermes/state.db`, read again
  only after it changes.  Sessions started in a terminal or in Hermes's desktop app are listed;
  those of its messaging gateways are left out.
- Renaming or deleting a session, and viewing its transcript, are done by the `hermes` command,
  since the database belongs to Hermes.
- `C-c a r` pastes the region, with its file and position, into the prompt of a running Hermes,
  without sending it.
- Over MCP, Hermes can see what only Emacs knows: the selection, which files are open or
  unsaved, and Flymake's diagnostics.  Every terminal gets a server of its own, which Hermes
  reaches through the bridge `bin/emacs-mcp` that comes with this extension.

## Using it

Run `M-x lispm-hermes-setup` once.  It asks Hermes to register the bridge as an MCP server named
`emacs`.  Hermes notices that the server offers no tools outside a terminal and asks whether to
keep it: say yes.  Every Hermes started from the editor afterwards sees Emacs's state.

Removing the extension in the App Store takes Hermes out of the editor straight away; its sessions
remain in Hermes's database.

## What it needs

The `hermes` command on `PATH`.  The App Store does not install Hermes itself: until the command
is found, it shows the extension greyed out, with the installer command Nous Research publishes:

```
curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash
```

If `hermes` is no longer there later, the extension hides itself.

## Where it comes from

Hermes Agent is developed by Nous Research and published under the MIT licence at
[github.com/NousResearch/hermes-agent](https://github.com/NousResearch/hermes-agent).  This
extension, which connects it to the editor, is LispMachineLab's and is not made by Nous Research.
