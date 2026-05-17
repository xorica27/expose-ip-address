import AppKit
import LocalIPCore

@main
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private let ipMenuItem = NSMenuItem(title: "Local IP: Checking...", action: nil, keyEquivalent: "")
    private let copyMenuItem = NSMenuItem(title: "Copy IP Address", action: #selector(copyIPAddress), keyEquivalent: "c")
    private var currentIPAddress: String?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        configureStatusItem()
        refreshIPAddress()
    }

    private func configureStatusItem() {
        let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        self.statusItem = statusItem

        if let button = statusItem.button {
            button.title = StatusDisplay.menuBarTitle(for: nil)
            button.toolTip = "Local IP Address"
        }

        let menu = NSMenu()
        ipMenuItem.isEnabled = false
        menu.addItem(ipMenuItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(copyMenuItem)
        menu.addItem(NSMenuItem(title: "Refresh", action: #selector(refreshIPAddress), keyEquivalent: "r"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))

        for item in menu.items where item.action != nil {
            item.target = self
        }

        statusItem.menu = menu
    }

    @objc
    private func refreshIPAddress() {
        currentIPAddress = IPAddressProvider.currentPreferredIPv4Address()

        let displayAddress = currentIPAddress ?? "Unavailable"
        statusItem?.button?.title = StatusDisplay.menuBarTitle(for: currentIPAddress)
        statusItem?.button?.toolTip = "Local IP: \(displayAddress)"
        ipMenuItem.title = "Local IP: \(displayAddress)"
        copyMenuItem.isEnabled = currentIPAddress != nil
    }

    @objc
    private func copyIPAddress() {
        guard let currentIPAddress else {
            return
        }

        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(currentIPAddress, forType: .string)
    }

    @objc
    private func quit() {
        NSApp.terminate(nil)
    }
}
