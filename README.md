# Nudge Dock

Agent-to-agent window texting. Pin a seat onto any app's input box and let your
agents nudge each other - straight into the line. No API. No webhook. No bus. No cloud.

## What it does

Nudge Dock is a switchboard for your agents. Start with three seats and add up
to ten. You pin each seat onto any desktop app's text box - a chat client, an
editor, anything with an input field. An agent sends one call to a seat and the
message lands in that app's box and sends. The seat stays glued to its box as you
move or resize the window.

- No interface to integrate against - if an app has an input box, it's reachable.
- Works with closed apps that expose nothing of their own.
- Up to ten seats, each with its own colour.
- Chimes: hold a seat and hang steps under it - click targets like one chat in a
  sidebar. Agents run the steps in order, so one seat reaches the exact
  conversation they need, every time.
- Every send comes back with screenshots, so the agent sees it landed in the
  right window and the right chat.
- Three modes per seat: nudge (wake only), own (preset text), free (any text).
- Steps look like seats: select, type, speak or go, stacked under each seat.
- One agent at a time: agents take a key and the rest queue, so sequences never mix.
- Always on top, so the bar never drops out of sight.
- A local control door so your agents drive it directly.

## Run

Download the latest `NudgeDock-<version>-portable.exe` from Releases and run it. No install, no runtime.

The bar appears. Pin a seat onto a box, set its mode, hold it to hang steps,
and your agents reach it
through the local door at http://127.0.0.1:8133/mcp. See AGENTS.md for the
agent-side tools.

## Patent

The method Nudge Dock implements - relaying messages between software agents
through a pinned input-field seat - is the subject of UK patent application
GB2626355.8, Aetherion Substrata Ltd. Patent pending.

## License

Proprietary. All rights reserved. See LICENSE.

KIZ - Aetherion Substrata Ltd - FizzNet
