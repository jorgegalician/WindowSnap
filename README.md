# WindowSnap

A tiny, free MacOS app that snaps your windows to halves, quarters, thirds or full screen with simple shortcuts. No dependencies or network access. 

## Default shortcuts

All use **⌃⌥** (Control + Option).

| Action | Key | Action | Key |
|---|---|---|---|
| Left half | ← | Left third | H |
| Right half | → | Center third | J |
| Top half | ↑ | Right third | K |
| Bottom half | ↓ | Top third | Y |
| Top left | O | Middle third | U |
| Top right | P | Bottom third | I |
| Bottom left | L | **Full screen** | ↩ |
| Bottom right | ; (Ñ on Spanish layouts) | | |

Click on the menu bar icon to switch any of these defaults.

## Requirements

macOS 11 or later.

## Accessibility permission

WindowSnap moves other apps' windows, so macOS requires **System Settings → Privacy & Security → Accessibility** access. It prompts on first launch. The hotkeys themselves need no permission.

The app is signed ad hoc (no developer certificate), so macOS treats every rebuild as a new app. If shortcuts stop working after you rebuild, remove WindowSnap from the Accessibility list with the − button, then add it again. Toggling the switch is not enough.

Because it is not notarized, a downloaded copy may need right-click → Open the first time.

---

MIT, see [LICENSE](LICENSE).
