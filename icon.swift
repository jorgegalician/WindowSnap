import Cocoa
let s: CGFloat = 1024
let img = NSImage(size: NSSize(width: s, height: s))
img.lockFocus()
NSColor(calibratedRed: 0.13, green: 0.16, blue: 0.24, alpha: 1).setFill()
NSBezierPath(roundedRect: NSRect(x: 60, y: 60, width: 904, height: 904), xRadius: 200, yRadius: 200).fill()
let cols = [NSColor(calibratedRed: 0.35, green: 0.65, blue: 1, alpha: 1), NSColor(calibratedRed: 0.5, green: 0.85, blue: 0.7, alpha: 1)]
let r = [NSRect(x: 180, y: 520, width: 320, height: 320), NSRect(x: 524, y: 520, width: 320, height: 320), NSRect(x: 180, y: 184, width: 320, height: 320), NSRect(x: 524, y: 184, width: 320, height: 320)]
for (i, b) in r.enumerated() { (i == 1 ? cols[1] : cols[0].withAlphaComponent(i == 0 ? 1 : 0.35)).setFill(); NSBezierPath(roundedRect: b, xRadius: 40, yRadius: 40).fill() }
img.unlockFocus()
let rep = NSBitmapImageRep(data: img.tiffRepresentation!)!
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: CommandLine.arguments[1]))
