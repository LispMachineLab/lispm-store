[ComfyUI](https://github.com/comfyanonymous/ComfyUI) makes images, video and sound with
workflows: a model loaded, a prompt encoded, a sampler run, an image decoded, each node's outputs
linked to the next ones' inputs.  This application draws your ComfyUI server's workflows as
ComfyUI itself does, and lets you build and run them from the keyboard: every node lights up
while it runs, and the image it makes appears inside it.

## Using it

`M-x lispm-comfyui` opens the workflow you had open, or a new one, with the buttons **Open**,
**Save**, **Run**, **Stop** and **Add Node**.

- The arrow keys move from node to node, the way they point; `n` and `p` move through a node's
  inputs, outputs and settings.
- `RET` changes the setting chosen, a number, a text, a choice from a list, or links the socket
  chosen to another node.  A long prompt opens in its own buffer.
- `a` adds a node.  On an output, it offers only the nodes that take what it gives, and links
  them; on an input, the nodes that give what it takes.
- `r` runs the workflow; `x` stops it.  `i` shows the image a node made, full size.
- `o` opens a workflow from your server's library, `s` saves it back, where ComfyUI's own page
  finds it too.  `u` undoes any change.

The mouse works too: drag nodes to move them, drag the canvas to look around, and pinch or
Control-scroll to zoom.

## Your server

Set `lispm-comfyui-url` to your ComfyUI server, `http://127.0.0.1:8188` if it runs on this Mac.
A server elsewhere on your network is reached at its address; behind a proxy that asks for a
password, `lispm-comfyui-headers` sends it.

## For agents

LispM's agents can read the workflow you see, look up the node types your server has, add and
link nodes, change settings and run it, seeing the images it makes.  Each change an agent makes
is one step you can undo.
