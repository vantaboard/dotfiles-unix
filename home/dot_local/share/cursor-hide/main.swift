import AppKit
import CoreGraphics
import Darwin
import Foundation

// CGDisplayHideCursor only affects the cursor while this process is frontmost.
// SetsCursorInBackground is the undocumented connection flag that lets a
// background helper hide it anyway. Same approach as CursorIdleHider.
@_silgen_name("CGSMainConnectionID")
private func CGSMainConnectionID() -> Int32

@_silgen_name("CGSSetConnectionProperty")
private func CGSSetConnectionProperty(
    _ cid: Int32,
    _ targetCID: Int32,
    _ key: CFString,
    _ value: CFTypeRef
) -> Int32

private func enableBackgroundCursorHiding() {
    let cid = CGSMainConnectionID()
    let key = "SetsCursorInBackground" as CFString
    let result = CGSSetConnectionProperty(cid, cid, key, kCFBooleanTrue)
    if result != 0 {
        fputs("cursor-hide: SetsCursorInBackground failed (\(result))\n", stderr)
    }
}

/// Hide the pointer after it has been still for this long. Matches Sway
/// `seat * hide_cursor 500`.
private let idleLimit: TimeInterval = 0.5
private let tick: TimeInterval = 0.05

private let pointerEvents: NSEvent.EventTypeMask = [
    .mouseMoved,
    .leftMouseDragged,
    .rightMouseDragged,
    .otherMouseDragged,
    .scrollWheel,
]

/// CGDisplayHideCursor is reference-counted and ignores which display you
/// pass, so hide and show must stay paired one-to-one.
private var pointerHidden = false

/// Uptime of the last pointer move, drag, or scroll we observed ourselves.
///
/// Do not replace this with CGEventSource.secondsSinceLastEventType: on
/// macOS 26+ the HID system state only refreshes about once a second, so it
/// reports 0.5-1.5s of idle while the mouse is actively moving. With a 500ms
/// threshold that kept the pointer hidden mid-movement.
private var lastPointerActivity = ProcessInfo.processInfo.systemUptime
private var lastPointerLocation = NSEvent.mouseLocation

private func notePointerActivity() {
    lastPointerActivity = ProcessInfo.processInfo.systemUptime
    showPointer()
}

private func pointerIdle() -> TimeInterval {
    ProcessInfo.processInfo.systemUptime - lastPointerActivity
}

private func hidePointer() {
    guard !pointerHidden else { return }
    CGDisplayHideCursor(CGMainDisplayID())
    pointerHidden = true
}

private func showPointer() {
    guard pointerHidden else { return }
    CGDisplayShowCursor(CGMainDisplayID())
    pointerHidden = false
}

private func acquireSingleInstance() {
    let dir = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent(".local/share/cursor-hide", isDirectory: true)
    try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    let path = dir.appendingPathComponent("cursor-hide.lock").path
    let fd = open(path, O_CREAT | O_RDWR, 0o644)
    if fd < 0 || flock(fd, LOCK_EX | LOCK_NB) != 0 {
        exit(0)
    }
}

private final class App: NSObject, NSApplicationDelegate {
    private var termSource: DispatchSourceSignal?
    private var intSource: DispatchSourceSignal?
    private var pointerMonitor: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        enableBackgroundCursorHiding()
        termSource = signalSource(SIGTERM)
        intSource = signalSource(SIGINT)
        // Global mouse monitors need no Accessibility grant (only keyboard
        // monitors do) and fire for every pointer event in other apps.
        pointerMonitor = NSEvent.addGlobalMonitorForEvents(matching: pointerEvents) { _ in
            notePointerActivity()
        }
        Timer.scheduledTimer(withTimeInterval: tick, repeats: true) { _ in
            // Position polling backs up the monitor for pointer motion that
            // does not reach it (e.g. apps that swallow events).
            let location = NSEvent.mouseLocation
            if location != lastPointerLocation {
                lastPointerLocation = location
                notePointerActivity()
            }
            if pointerIdle() >= idleLimit {
                hidePointer()
            } else {
                showPointer()
            }
        }
    }

    private func signalSource(_ sig: Int32) -> DispatchSourceSignal {
        signal(sig, SIG_IGN)
        let source = DispatchSource.makeSignalSource(signal: sig, queue: .main)
        source.setEventHandler {
            showPointer()
            exit(0)
        }
        source.resume()
        return source
    }
}

acquireSingleInstance()
let app = NSApplication.shared
private let delegate = App()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
