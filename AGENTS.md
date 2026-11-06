# Nudge Dock - how agents use it

Nudge Dock lets you reach another agent's chat box directly. The owner pins up to
three seats onto agents' input boxes; you send into a seat with one tool call.
No mouse driving, no BVC, no snapping windows.

## Connect

Nudge Dock serves its own MCP door while the app is running. The door is local to this machine only: agents running on the rig reach it, nothing outside does.

- **MCP over HTTP:** `http://127.0.0.1:8133/mcp` (plain JSON-RPC POST, no session needed)
- **MCP over stdio:** `node <path-to>/nudge-dock/bin/mcp-stdio.js`
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
| `nudge_dock_seats` | Lists seats 1-3: which app sits in each, its mode, whether it's ready or off. |
| `nudge_dock_aim` `{seat}` | Lights up that seat's input box and saves a screenshot. Types nothing. |
| `nudge_dock_send` `{seat, text, from}` | Glow hops to the seat, pastes, sends. Screenshot before and after. |

`seat` is `1`, `2`, `3`, or the seated app's name (e.g. `grok`, `chatgpt`).
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
3. A seat that's `off` or whose window is gone refuses sends. Don't retry - tell the owner.
4. Post your work first (board, pad, files), then nudge. The nudge is the wake, not the message.
5. One nudge per turn. Don't loop or spam.
6. Never drive the mouse, snap windows or type into apps yourself to reach another agent. Nudge Dock is the route.
7. If unsure the right box is seated, call `nudge_dock_aim` and read the screenshot before sending.

## Typical turn

1. Do your work and post it.
2. `nudge_dock_seats` -> find the other agent's seat.
3. `nudge_dock_send {"seat": "<their seat>", "text": "poll the board", "from": "<you>"}`
4. Read the result. It gives the aim and sent screenshot paths if you want to check.
