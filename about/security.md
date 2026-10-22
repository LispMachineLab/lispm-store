Security inspects what your Emacs's agents may run: the MCP servers and skills of LispM Agent,
Claude Code and Codex, and Emacs's installed packages, and lists what it finds, the most serious
first.  A scan only reads: it launches no server, evaluates no code and sends nothing over the
network.

## What it checks

- **MCP servers**: packages npx or uvx launch without an exact version, images named by a tag,
  commands run through a shell, remote servers on plain HTTP, secrets in configuration files,
  packages with install scripts.
- **Text the model will read**, in skills and tools' descriptions: invisible characters, hidden
  comments, encoded blobs, downloads piped to a shell, orders to ignore earlier instructions or
  keep something from you.
- **The code of LispM's skills**, parsed as Lisp and never run: what it calls, touches and
  modifies, and whether each tool's permission class fits what it does.
- **Tool pinning**: trusting a running MCP server records a hash of its tools; if they change
  later, a finding says what changed.
- **Known vulnerabilities and malicious packages**, checked against [OSV](https://osv.dev).  This
  sends package names and versions to osv.dev, so it runs only when you ask and agree.
- **Permissions granted up front**: LispM's default policy, Claude Code bypassing
  permissions, Codex without its sandbox.

## While agents work

With LispM Agent 0.3.0 or later, Security also vets each tool call of LispM's agents.  Tools of a
server you have not trusted always ask; tools changed since you trusted them are hidden and their
calls denied; and once a session has read both untrusted content and private data, any call that
could send data out asks first.  Security can only make a decision stricter, never looser.

## Using it

`M-x lispm-security` opens its window, with the buttons **Scan**, **Look Up**, **Trust**,
**Set Aside** and **Inventory**.

- `RET` explains the finding and what to do about it.
- `g` scans again; `l` queries OSV for the packages the servers run.
- `t` trusts the finding's MCP server, pinning its tools as they are.
- `x` sets a finding aside, or brings it back; `a` shows those set aside.
- `o` opens the file concerned at its line; `i` shows what each agent is given.

Agents read the findings through the *Check security* skill; only you can trust a server or set
a finding aside.  Security keeps its state in `~/.emacs.d/lispm-security/`.
