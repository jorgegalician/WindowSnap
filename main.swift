import Cocoa
import Carbon.HIToolbox

// MARK: - Actions

struct Action {
    let id: String
    let title: String
    let rect: (CGFloat, CGFloat, CGFloat, CGFloat) // x,y,w,h as fractions, origin top-left
    let defKey: Int
}

let ctrlOpt = UInt32(controlKey | optionKey)
let actions: [Action] = [
    Action(id: "left",   title: "Left Half",   rect: (0, 0, 0.5, 1), defKey: kVK_LeftArrow),
    Action(id: "right",  title: "Right Half",  rect: (0.5, 0, 0.5, 1), defKey: kVK_RightArrow),
    Action(id: "top",    title: "Top Half",    rect: (0, 0, 1, 0.5), defKey: kVK_UpArrow),
    Action(id: "bottom", title: "Bottom Half", rect: (0, 0.5, 1, 0.5), defKey: kVK_DownArrow),
    Action(id: "tl", title: "Top Left",     rect: (0, 0, 0.5, 0.5), defKey: kVK_ANSI_O),
    Action(id: "tr", title: "Top Right",    rect: (0.5, 0, 0.5, 0.5), defKey: kVK_ANSI_P),
    Action(id: "bl", title: "Bottom Left",  rect: (0, 0.5, 0.5, 0.5), defKey: kVK_ANSI_L),
    Action(id: "br", title: "Bottom Right", rect: (0.5, 0.5, 0.5, 0.5), defKey: kVK_ANSI_Semicolon), // Ñ on Spanish layouts
    Action(id: "v1", title: "Left Third",   rect: (0, 0, 1.0/3, 1), defKey: kVK_ANSI_H),
    Action(id: "v2", title: "Center Third", rect: (1.0/3, 0, 1.0/3, 1), defKey: kVK_ANSI_J),
    Action(id: "v3", title: "Right Third",  rect: (2.0/3, 0, 1.0/3, 1), defKey: kVK_ANSI_K),
    Action(id: "h1", title: "Top Third",    rect: (0, 0, 1, 1.0/3), defKey: kVK_ANSI_Y),
    Action(id: "h2", title: "Middle Third", rect: (0, 1.0/3, 1, 1.0/3), defKey: kVK_ANSI_U),
    Action(id: "h3", title: "Bottom Third", rect: (0, 2.0/3, 1, 1.0/3), defKey: kVK_ANSI_I),
    Action(id: "full", title: "Full Screen", rect: (0, 0, 1, 1), defKey: kVK_Return),
]
let groups: [(String, ClosedRange<Int>)] = [("Halves", 0...3), ("Quadrants", 4...7), ("Vertical Thirds (left → right)", 8...10), ("Horizontal Thirds (top → bottom)", 11...13), ("Maximize", 14...14)]

// MARK: - Shortcut storage

struct Shortcut: Equatable { var key: Int; var mods: UInt32 }

var shortcuts: [Shortcut] = []
let defaults = UserDefaults.standard

func loadShortcuts() {
    let saved = defaults.dictionary(forKey: "shortcuts") as? [String: [Int]] ?? [:]
    shortcuts = actions.map { a in
        if let s = saved[a.id], s.count == 2 { return Shortcut(key: s[0], mods: UInt32(s[1])) }
        return Shortcut(key: a.defKey, mods: ctrlOpt)
    }
}
func saveShortcuts() {
    var d: [String: [Int]] = [:]
    for (i, a) in actions.enumerated() { d[a.id] = [shortcuts[i].key, Int(shortcuts[i].mods)] }
    defaults.set(d, forKey: "shortcuts")
}

// MARK: - Key display

func keyName(_ code: Int) -> String {
    switch code {
    case kVK_LeftArrow: return "←"; case kVK_RightArrow: return "→"
    case kVK_UpArrow: return "↑"; case kVK_DownArrow: return "↓"
    case kVK_Return: return "↩"; case kVK_Space: return "Space"; case kVK_Tab: return "⇥"
    case kVK_Delete: return "⌫"; case kVK_Escape: return "⎋"
    default: break
    }
    let fmap: [Int: String] = [kVK_F1:"F1",kVK_F2:"F2",kVK_F3:"F3",kVK_F4:"F4",kVK_F5:"F5",kVK_F6:"F6",kVK_F7:"F7",kVK_F8:"F8",kVK_F9:"F9",kVK_F10:"F10",kVK_F11:"F11",kVK_F12:"F12"]
    if let f = fmap[code] { return f }
    guard let src = TISCopyCurrentKeyboardLayoutInputSource()?.takeRetainedValue(),
          let ptr = TISGetInputSourceProperty(src, kTISPropertyUnicodeKeyLayoutData) else { return "#\(code)" }
    let data = Unmanaged<CFData>.fromOpaque(ptr).takeUnretainedValue() as Data
    var dead: UInt32 = 0
    var len = 0
    var chars = [UniChar](repeating: 0, count: 4)
    let status = data.withUnsafeBytes { raw -> OSStatus in
        let layout = raw.baseAddress!.assumingMemoryBound(to: UCKeyboardLayout.self)
        return UCKeyTranslate(layout, UInt16(code), UInt16(kUCKeyActionDisplay), 0,
                              UInt32(LMGetKbdType()), OptionBits(kUCKeyTranslateNoDeadKeysBit),
                              &dead, 4, &len, &chars)
    }
    if status != noErr || len == 0 { return "#\(code)" }
    return String(utf16CodeUnits: chars, count: len).uppercased()
}

func modString(_ m: UInt32) -> String {
    var s = ""
    if m & UInt32(controlKey) != 0 { s += "⌃" }
    if m & UInt32(optionKey) != 0 { s += "⌥" }
    if m & UInt32(shiftKey) != 0 { s += "⇧" }
    if m & UInt32(cmdKey) != 0 { s += "⌘" }
    return s
}
func describe(_ s: Shortcut) -> String { modString(s.mods) + keyName(s.key) }

func carbonMods(_ f: NSEvent.ModifierFlags) -> UInt32 {
    var m: UInt32 = 0
    if f.contains(.control) { m |= UInt32(controlKey) }
    if f.contains(.option) { m |= UInt32(optionKey) }
    if f.contains(.shift) { m |= UInt32(shiftKey) }
    if f.contains(.command) { m |= UInt32(cmdKey) }
    return m
}

// MARK: - Window manipulation (Accessibility)

func axValue<T>(_ el: AXUIElement, _ attr: String) -> T? {
    var v: CFTypeRef?
    guard AXUIElementCopyAttributeValue(el, attr as CFString, &v) == .success else { return nil }
    return v as? T
}

func place(_ a: Action) {
    if ProcessInfo.processInfo.environment["WINDOWSNAP_DEBUG"] != nil { NSLog("WindowSnap place %@ trusted=%d front=%@", a.id, AXIsProcessTrusted() ? 1 : 0, NSWorkspace.shared.frontmostApplication?.localizedName ?? "nil") }
    guard AXIsProcessTrusted() else { requestAccessibility(); return }
    guard let app = NSWorkspace.shared.frontmostApplication,
          app.processIdentifier != ProcessInfo.processInfo.processIdentifier else { return }
    let axApp = AXUIElementCreateApplication(app.processIdentifier)
    guard let win: AXUIElement = axValue(axApp, kAXFocusedWindowAttribute) ?? axValue(axApp, kAXMainWindowAttribute) else { return }

    var pos = CGPoint.zero, size = CGSize.zero
    if let pv: AXValue = axValue(win, kAXPositionAttribute) { AXValueGetValue(pv, .cgPoint, &pos) }
    if let sv: AXValue = axValue(win, kAXSizeAttribute) { AXValueGetValue(sv, .cgSize, &size) }

    // AX uses top-left origin relative to the primary screen; Cocoa uses bottom-left.
    let primaryH = NSScreen.screens.first?.frame.height ?? 0
    let center = CGPoint(x: pos.x + size.width / 2, y: primaryH - (pos.y + size.height / 2))
    let screen = NSScreen.screens.first(where: { $0.frame.contains(center) }) ?? NSScreen.main ?? NSScreen.screens[0]
    let vf = screen.visibleFrame
    let topY = primaryH - vf.maxY // top of visible frame in AX coords

    let (fx, fy, fw, fh) = a.rect
    var newPos = CGPoint(x: (vf.minX + vf.width * fx).rounded(), y: (topY + vf.height * fy).rounded())
    var newSize = CGSize(width: (vf.width * fw).rounded(), height: (vf.height * fh).rounded())

    func setSize() { if let v = AXValueCreate(.cgSize, &newSize) { AXUIElementSetAttributeValue(win, kAXSizeAttribute as CFString, v) } }
    func setPos() { if let v = AXValueCreate(.cgPoint, &newPos) { AXUIElementSetAttributeValue(win, kAXPositionAttribute as CFString, v) } }
    setSize(); setPos(); setSize() // size→pos→size handles cross-screen moves
}

var axPromptShown = false
func requestAccessibility() {
    let opts = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
    _ = AXIsProcessTrustedWithOptions(opts)
}

// MARK: - Hotkeys (Carbon; needs no extra permission, near-zero CPU)

var hotKeyRefs: [EventHotKeyRef?] = []

func registerHotKeys() {
    unregisterHotKeys()
    for (i, s) in shortcuts.enumerated() {
        var ref: EventHotKeyRef?
        let id = EventHotKeyID(signature: OSType(0x534E4150), id: UInt32(i))
        let st = RegisterEventHotKey(UInt32(s.key), s.mods, id, GetApplicationEventTarget(), 0, &ref)
        if ProcessInfo.processInfo.environment["WINDOWSNAP_DEBUG"] != nil { NSLog("WindowSnap reg %d key=%d mods=%d st=%d", i, s.key, s.mods, st) }
        hotKeyRefs.append(ref)
    }
}
func unregisterHotKeys() {
    for r in hotKeyRefs { if let r = r { UnregisterEventHotKey(r) } }
    hotKeyRefs.removeAll()
}

func installHandler() {
    var spec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
    InstallEventHandler(GetApplicationEventTarget(), { _, ev, _ in
        var id = EventHotKeyID()
        GetEventParameter(ev, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID), nil, MemoryLayout<EventHotKeyID>.size, nil, &id)
        if Int(id.id) < actions.count { place(actions[Int(id.id)]) }
        return noErr
    }, 1, &spec, nil, nil)
}

// MARK: - App

final class Delegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    var statusItem: NSStatusItem!
    var recorderWindow: NSWindow?
    var monitor: Any?

    func applicationDidFinishLaunching(_ n: Notification) {
        loadShortcuts()
        installHandler()
        registerHotKeys()
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let img = NSImage(systemSymbolName: "rectangle.split.2x2", accessibilityDescription: "WindowSnap") {
            img.isTemplate = true
            statusItem.button?.image = img
        } else { statusItem.button?.title = "▦" }
        statusItem.menu = buildMenu()
        NSApp.mainMenu = mainMenu()
        if !AXIsProcessTrusted() { requestAccessibility() }
    }

    func mainMenu() -> NSMenu {
        let m = NSMenu(), app = NSMenuItem(), sub = NSMenu()
        sub.addItem(withTitle: "Quit WindowSnap", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        app.submenu = sub; m.addItem(app); return m
    }

    func buildMenu() -> NSMenu {
        let menu = NSMenu()
        for (gi, g) in groups.enumerated() {
            if gi > 0 { menu.addItem(.separator()) }
            let h = NSMenuItem(title: g.0, action: nil, keyEquivalent: ""); h.isEnabled = false
            menu.addItem(h)
            for i in g.1 {
                let it = NSMenuItem(title: "\(actions[i].title)\t\(describe(shortcuts[i]))", action: #selector(change(_:)), keyEquivalent: "")
                it.target = self; it.tag = i
                it.toolTip = "Click to change shortcut"
                menu.addItem(it)
            }
        }
        menu.addItem(.separator())
        let hint = NSMenuItem(title: "Click an item to change its shortcut", action: nil, keyEquivalent: ""); hint.isEnabled = false
        menu.addItem(hint)
        let reset = NSMenuItem(title: "Reset Shortcuts to Defaults", action: #selector(resetAll), keyEquivalent: ""); reset.target = self
        menu.addItem(reset)
        let ax = NSMenuItem(title: "Accessibility Permission…", action: #selector(openAX), keyEquivalent: ""); ax.target = self
        menu.addItem(ax)
        menu.addItem(.separator())
        let q = NSMenuItem(title: "Quit WindowSnap", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "")
        menu.addItem(q)
        return menu
    }

    func refresh() { statusItem.menu = buildMenu() }

    func applicationShouldTerminateAfterLastWindowClosed(_ s: NSApplication) -> Bool { false }

    @objc func resetAll() {
        defaults.removeObject(forKey: "shortcuts"); loadShortcuts(); registerHotKeys(); refresh()
    }
    @objc func openAX() {
        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
        requestAccessibility()
    }

    // Shortcut recorder
    @objc func change(_ item: NSMenuItem) {
        let idx = item.tag
        unregisterHotKeys() // so existing combos reach our key monitor
        let panel = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 360, height: 110),
                            styleMask: [.titled], backing: .buffered, defer: false)
        panel.isReleasedWhenClosed = false
        panel.title = "Change Shortcut"
        panel.level = .floating
        let label = NSTextField(wrappingLabelWithString: "Press the new shortcut for “\(actions[idx].title)”.\nInclude ⌃, ⌥ or ⌘. Esc to cancel.")
        label.alignment = .center
        label.frame = NSRect(x: 20, y: 25, width: 320, height: 60)
        panel.contentView?.addSubview(label)
        panel.center()
        recorderWindow = panel
        NSApp.activate(ignoringOtherApps: true)
        panel.makeKeyAndOrderFront(nil)

        monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] e in
            guard let self = self else { return e }
            if ProcessInfo.processInfo.environment["WINDOWSNAP_DEBUG"] != nil { NSLog("WindowSnap rec key=%d flags=%lu", e.keyCode, e.modifierFlags.rawValue) }
            if e.keyCode == UInt16(kVK_Escape) { self.endRecording(); return nil }
            let mods = carbonMods(e.modifierFlags.intersection(.deviceIndependentFlagsMask))
            if mods & UInt32(controlKey | optionKey | cmdKey) == 0 { NSSound.beep(); return nil }
            let new = Shortcut(key: Int(e.keyCode), mods: mods)
            if let other = shortcuts.firstIndex(of: new), other != idx {
                label.stringValue = "\(describe(new)) is already used by “\(actions[other].title)”.\nPress another shortcut, or Esc to cancel."
                NSSound.beep(); return nil
            }
            shortcuts[idx] = new
            saveShortcuts()
            self.endRecording()
            return nil
        }
    }

    func endRecording() {
        if let m = monitor { NSEvent.removeMonitor(m); monitor = nil }
        recorderWindow?.orderOut(nil); recorderWindow = nil
        registerHotKeys(); refresh()
    }
}

let app = NSApplication.shared
let delegate = Delegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
