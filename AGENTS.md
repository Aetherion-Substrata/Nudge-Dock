# Nudge Dock — how agents use it

Nudge Dock lets you reach another agent's chat box directly. The owner pins up to
ten seats onto agents' input boxes; you send into a seat with one tool call.
Under each seat the owner can hang steps: click targets such as one chat in a
sidebar, so one seat can reach the right conversation in a busy app.
No mouse driving, no BVC, no snapping windows.

## Connect

Nudge Dock serves its own MCP door while the app is running. The door is local to this machine only: agents running on the rig reach it, nothing outside does.

- **MCP over HTTP:** `http://127.0.0.1:8133/mcp` (plain JSON-RPC POST, no session needed)
- **MCP over stdio:** `node bin/mcp-stdio.js` (bridges any stdio MCP client to the door above)
- **Shell, no MCP client:** POST JSON-RPC straight to the door:

```powershell
$b = '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"nudge_dock_send","arguments":{"seat":"2","text":"poll the board","from":"gpt"}}}'
(Invoke-WebRequest -UseBasicParsing -Uri http://127.0.0.1:8133/mcp -Method Post -ContentType 'application/json' -Body $b).Content
```

```bash
curl -s http://127.0.0.1:8133/mcp -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"nudge_dock_seats","arguments":{}}}'
```

## Tools

| Tool | What it does |
|---|---|
| `nudge_dock_seats` | Lists the seats (1-10): which app sits in each, its mode, ready or off, and its steps. |
| `nudge_dock_aim` `{seat}` | Lights up that seat's input box and returns a screenshot. Types nothing. |
| `nudge_dock_step` `{seat, step}` | Clicks one of the seat's steps (number or name) and returns a screenshot. Types nothing. |
| `nudge_dock_send` `{seat, text, from, steps}` | Runs the listed steps in order, then the glow hops to the seat, pastes, sends. Returns the screenshots. |

Screenshots come back in the tool result as images, so you can confirm you landed in the right window and the right chat before you go on.

`seat` is `1` to `10`, or the seated app's name (e.g. `grok`, `chatgpt`).
`steps` is a list of step numbers or names, e.g. `["BVC #4"]`, run in order before the text goes in.
`from` is your agent name, for the log.

## Seat modes (set by the owner, per seat)

| Mode | Icon | What you can send |
|---|---|---|
| nudge | bell | Only `nudge` or `poll the board`. Anything else is refused. Leave `text` out to send `nudge`. |
| own | pen | The seat's own preset text. Your `text` is ignored. |
| free | bubble | Any text you pass. |

## Rules

1. Call `nudge_dock_seats` first. Only send to a seat that shows `ready: true`.
2. Send to the **other** agent's seat, never your own.
3. A seat that's `off` or whose window is gone refuses sends. Don't retry — tell the owner.
4. Post your work first (board, pad, files), then nudge. The nudge is the wake, not the message.
5. One nudge per turn. Don't loop or spam.
6. Never drive the mouse, snap windows or type into apps yourself to reach another agent. Nudge Dock is the route.
7. If unsure the right box is seated, call `nudge_dock_aim` and read the screenshot before sending.

## Typical turn

1. Do your work and post it.
2. `nudge_dock_seats` → find the other agent's seat.
3. `nudge_dock_send {"seat": "<their seat>", "steps": ["<their chat>"], "text": "poll the board", "from": "<you>"}`
4. Look at the screenshots in the result: right window, right chat, message sent.
