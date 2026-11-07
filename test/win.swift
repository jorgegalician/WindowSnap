import Cocoa
let app = NSApplication.shared
app.setActivationPolicy(.regular)
let w = NSWindow(contentRect: NSRect(x: 300, y: 300, width: 500, height: 400), styleMask: [.titled, .resizable, .closable], backing: .buffered, defer: false)
w.title = "WindowSnapTestWindow"
w.makeKeyAndOrderFront(nil)
app.activate(ignoringOtherApps: true)
// print frame in AX coords (top-left origin) of the primary screen, plus visible area
Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
    let f = w.frame, vf = NSScreen.screens[0].visibleFrame, h = NSScreen.screens[0].frame.height
    let s = String(format: "%.0f %.0f %.0f %.0f | vis %.0f %.0f %.0f %.0f", f.minX, h - f.maxY, f.width, f.height, vf.minX, h - vf.maxY, vf.width, vf.height)
    try? s.write(toFile: "/tmp/windowsnaptest_frame.txt", atomically: true, encoding: .utf8)
}
app.run()
