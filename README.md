# MoveToScreen

A tiny macOS menu bar utility that moves **every open window of an app** to the display you choose — in two clicks.

If your Terminal windows (or Chrome, or VS Code…) end up scattered across two or three displays and you want them all on one screen, this is for you.

---

## How it works

1. Click the **MoveToScreen** icon in your menu bar.
2. Pick an app from the list (only apps with movable windows show up).
3. Pick a display.

Every eligible window of that app moves to that display, each landing in roughly the same relative position it occupied on its old screen.

```
[icon]  ▾  Move windows of…
           ├─ Terminal              ▶  ┌─ Built-in Retina Display
           ├─ Visual Studio Code    ▶  ├─ Studio Display
           ├─ Google Chrome         ▶  └─ DELL U2723QE
           ├─ Slack                 ▶
           ╶─────────────────────────
           └─ Quit
```

### "Which display is which?"

External displays often show up with cryptic model names like `H24T27 (1)`. Hover any display row in the submenu and a big black-and-white badge appears on the matching physical screen — so you can map the name to the screen before you click.

---

## What gets moved

- Normal visible windows on the current Space.
- Minimized windows (they get un-minimized first).

## What gets skipped

- Fullscreen windows.
- Windows on other Spaces (Mission Control desktops).
- Apps with no movable windows (they won't appear in the menu at all).

---

## Requirements

- **macOS 13 (Ventura) or later**
- Apple Silicon or Intel Mac
- Multiple displays connected (it works with one display too, but that's not the point)

---

## Installing

There's no installer yet. To build from source:

```bash
git clone https://github.com/wallacedrew/move-to-screen.git
cd move-to-screen
swift build -c release
.build/release/MoveToScreen
```

The app runs as a menu bar item with no Dock icon and no main window.

---

## First launch — granting Accessibility access

MoveToScreen uses macOS's Accessibility API to move windows. The first time you launch it, you'll see a prompt asking you to grant access:

1. Click **Open Settings** in the prompt.
2. In **System Settings → Privacy & Security → Accessibility**, flip the switch next to `MoveToScreen`.
3. Relaunch the app.

This is the same permission required by Rectangle, Magnet, BetterTouchTool, and every other window-management tool on macOS. The app can't move windows without it.

---

## Quitting

Click the menu bar icon → **Quit MoveToScreen**.

---

## Limitations

- Windows on other Spaces are left alone. Switch to that Space first if you want to move them.
- Fullscreen windows can't be moved (macOS owns the geometry).
- The app doesn't currently launch at login automatically. (Coming.)
- Not yet code-signed or notarized — on first run, macOS may complain about an "unidentified developer". Right-click the binary → **Open** to bypass.

---

## License

MIT.
