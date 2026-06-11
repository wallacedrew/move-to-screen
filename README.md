# MoveToScreen

A tiny macOS menu bar utility that moves **every open window of an app** to the display you choose — in two clicks.

If your Terminal windows (or Chrome, or VS Code…) end up scattered across two or three displays and you want them all on one screen, this is for you.

![MoveToScreen menu open showing Terminal selected and three displays in the submenu](docs/menu.png)

---

## How it works

1. Click the **MoveToScreen** icon in your menu bar.
2. Pick an app from the list (only apps with movable windows show up).
3. Pick a display.

Every eligible window of that app moves to that display, each landing in roughly the same relative position it occupied on its old screen.

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

You'll need [Xcode command-line tools](https://developer.apple.com/xcode/) (run `xcode-select --install` if you don't have them). Then:

```bash
git clone https://github.com/wallacedrew/move-to-screen.git
cd move-to-screen
./script/install
```

The script builds the app, installs it to `~/Applications/MoveToScreen.app`, and launches it. You should see a menu bar icon (three stacked squares) appear within a second or two — no Dock icon, no window.

To update later: `git pull && ./script/install`.

To uninstall: `./script/uninstall`.

---

## First launch — granting Accessibility access

MoveToScreen uses macOS's Accessibility API to move windows. The first time you launch it, you'll see a prompt asking you to grant access:

1. Click **Open Settings** in the prompt.
2. In **System Settings → Privacy & Security → Accessibility**, flip the switch next to `MoveToScreen`.
3. Quit and relaunch the app (click the menu bar icon → Quit, then run `open ~/Applications/MoveToScreen.app` or open it from Finder).

This is the same permission required by Rectangle, Magnet, BetterTouchTool, and every other window-management tool on macOS. The app can't move windows without it.

---

## Auto-start at login

The install script doesn't add MoveToScreen to your Login Items — that's a choice you make once. To have it come back automatically after reboot:

1. **System Settings → General → Login Items**.
2. Under **Open at Login**, click `+`.
3. Navigate to `~/Applications/` and pick `MoveToScreen.app`.

Remove it the same way (select the row → `−`).

---

## Quitting

Click the menu bar icon → **Quit MoveToScreen**.

---

## Limitations

- Windows on other Spaces are left alone. Switch to that Space first if you want to move them.
- Fullscreen windows can't be moved (macOS owns the geometry).
- Not yet code-signed or notarized. The install script launches the app via `open` from your terminal, which sidesteps the "unidentified developer" warning — but if you ever double-click the bundle straight out of Finder before the first script-launch, you'll get that warning. Right-click the bundle → **Open** to bypass it once.

---

## License

MIT.
