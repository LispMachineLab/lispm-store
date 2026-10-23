LispM, from your phone or another computer, wherever you are, for as long as Emacs runs.  You
pair a device once by scanning a QR code; after that it opens **lispm.ai/remote** to talk to
LispM's agents, answer what they wait on, and work in LispM's windows.

## What it does

- **Agents.** The page lists LispM's agents and what each is doing.  Each agent is a chat: what you
  type goes to it, and its answers come back as it writes them.
- **Approvals.** A call that waits for you shows on the phone.  Allow it, always allow it, or deny
  it, as you would at the desk.  You can also stop an agent's turn.
- **Windows.** The Windows view shows LispM's buffers, redrawn on the device with its own fonts,
  not streamed as video.  You can type in them and click in them.
- **Back by itself.** When the phone's network drops and comes back, the page joins the network
  again and reopens its session without a new scan, and shows the latest state.

## Private by design

- **No server of ours.** LispM and the device find each other on Rings Network, a peer-to-peer
  network, by their addresses.  No server of LispM's sits in between.
- **End-to-end keys.** Pairing agrees keys that only the two devices hold, using Noise handshakes.
  Every message is sealed with them, so the nodes relaying it see who talks to whom and nothing of
  what is said.
- **You approve each device.** The QR code works once, for two minutes.  Both screens show the same
  fingerprint, and the device is paired only when you approve that fingerprint in LispM.  A second
  device using the same code cancels it.

## Using it

1. Open **LispM Remote**.  It says whether devices can reach LispM; turn it on with **Turn on**
   (`t`).
2. Choose **Pair a device** (`p`).  LispM shows a QR code and a bar counting down its two minutes.
3. On the phone, open lispm.ai/remote and scan the code.  Both screens walk through the same steps:
   **Join**, **Scan**, **Reach**, **Confirm**, **Connected**.
4. When the phone asks, check that it shows the fingerprint LispM shows, and press **Approve**
   (`a`).  **Refuse** (`r`) turns it away.

LispM Remote's window lists the paired devices, each marked connected while it is, with a
**Forget** button that takes a device's access away.

## Where things are kept

LispM Remote keeps its Rings account, this LispM's key and the paired devices in
`~/.emacs.d/lispm-remote/`, readable only by you.  Its Rings node runs inside Emacs as a native
module, which is downloaded for your computer and kept only if its checksum is the one pinned in
LispM Remote's signed source.
