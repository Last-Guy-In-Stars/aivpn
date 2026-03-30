import SwiftUI

@main
struct AivpnApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var vpnManager = VPNManager()
    @StateObject private var localization = LocalizationManager()

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    var eventMonitor: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide dock icon — menu bar only
        NSApp.setActivationPolicy(.accessory)

        // Create status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "circle", accessibilityDescription: "Disconnected")
            button.action = #selector(togglePopover(_:))
        }

        // Create popover
        let contentView = ContentView()
            .environmentObject(VPNManager.shared)
            .environmentObject(LocalizationManager.shared)

        popover = NSPopover()
        popover?.contentSize = NSSize(width: 340, height: 300)
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(rootView: contentView)

        // Event monitor to close popover on outside click
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            if let popover = self?.popover, popover.isShown {
                popover.performClose(nil)
            }
        }

        // Check helper daemon on launch
        VPNManager.shared.checkHelperAvailable()
    }

    @objc func togglePopover(_ sender: Any?) {
        guard let popover = popover, let button = statusItem?.button else { return }
        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    func updateStatusIcon(connected: Bool) {
        DispatchQueue.main.async {
            if let button = self.statusItem?.button {
                let iconName = connected ? "circle.fill" : "circle"
                let color: NSColor = connected ? .systemGreen : .systemGray
                let image = NSImage(systemSymbolName: iconName, accessibilityDescription: connected ? "Connected" : "Disconnected")
                image?.isTemplate = true
                button.image = image
                button.contentTintColor = color
            }
        }
    }
}
