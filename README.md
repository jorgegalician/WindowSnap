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

## Download

Get `WindowSnap-<version>.zip` from the [Releases page](https://github.com/jorgegalician/WindowSnap/releases), unzip it and move `WindowSnap.app` to `/Applications`. The first launch needs extra approval because the app is not notarized (see below).

## Requirements

macOS 11 or later.

## Accessibility permission

WindowSnap moves other apps' windows, so macOS requires **System Settings → Privacy & Security → Accessibility** access. It prompts on first launch. The hotkeys themselves need no permission.

The app is signed ad hoc (no developer certificate), so macOS treats every rebuild as a new app. If shortcuts stop working after you rebuild, remove WindowSnap from the Accessibility list with the − button, then add it again. Toggling the switch is not enough.

## Not notarized

WindowSnap is not notarized by Apple, so macOS may block it the first time you open it ("WindowSnap can't be opened" or "Apple could not verify..."). To allow it:

1. Try to open the app once, then dismiss the warning.
2. Go to **System Settings → Privacy & Security**, scroll down to the Security section, and click **Open Anyway** next to the WindowSnap message.
3. Confirm, and enter your password if asked.

Alternatively, right-click the app and choose **Open**.

---

MIT, see [LICENSE](LICENSE).
