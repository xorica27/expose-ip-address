import AppKit
import LocalIPCore

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
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
    }

    @objc
    private func refreshIPAddress() {
        let interfaces = IPAddressProvider.currentInterfaces()
        let primaryInterfaceName = IPAddressProvider.currentPrimaryInterfaceName()
        let activeInterfaces = IPAddressProvider.activeLocalIPv4Interfaces(from: interfaces)

        currentIPAddress = IPAddressProvider.preferredIPv4Address(
            from: interfaces,
            primaryInterfaceName: primaryInterfaceName
        )

        let displayAddress = currentIPAddress ?? "Unavailable"
        statusItem?.button?.title = StatusDisplay.menuBarTitle(for: currentIPAddress)
        statusItem?.button?.toolTip = "Local IP: \(displayAddress)"
        statusItem?.menu = makeMenu(
            displayAddress: displayAddress,
            activeInterfaces: activeInterfaces,
            primaryInterfaceName: primaryInterfaceName
        )
    }

    private func makeMenu(
        displayAddress: String,
        activeInterfaces: [NetworkInterface],
        primaryInterfaceName: String?
    ) -> NSMenu {
        let menu = NSMenu()
        let primaryItem = NSMenuItem(title: "Primary: \(displayAddress)", action: nil, keyEquivalent: "")
        primaryItem.isEnabled = false
        menu.addItem(primaryItem)
        menu.addItem(NSMenuItem.separator())

        if activeInterfaces.isEmpty {
            let unavailableItem = NSMenuItem(title: "No active local IPv4 addresses", action: nil, keyEquivalent: "")
            unavailableItem.isEnabled = false
            menu.addItem(unavailableItem)
        } else {
            for networkInterface in activeInterfaces {
                menu.addItem(makeInterfaceMenuItem(
                    for: networkInterface,
                    isPrimary: networkInterface.name == primaryInterfaceName
                ))
            }
        }

        menu.addItem(NSMenuItem.separator())

        let copyMenuItem = NSMenuItem(title: "Copy Primary IP", action: #selector(copyIPAddress), keyEquivalent: "c")
        copyMenuItem.target = self
        copyMenuItem.isEnabled = currentIPAddress != nil
        menu.addItem(copyMenuItem)

        let refreshItem = NSMenuItem(title: "Refresh", action: #selector(refreshIPAddress), keyEquivalent: "r")
        refreshItem.target = self
        menu.addItem(refreshItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        return menu
    }

    private func makeInterfaceMenuItem(for networkInterface: NetworkInterface, isPrimary: Bool) -> NSMenuItem {
        let titlePrefix: String
        switch networkInterface.kind {
        case .wifi:
            titlePrefix = "Wi-Fi"
        case .wired:
            titlePrefix = "LAN"
        case .other:
            titlePrefix = "Network"
        }

        let primarySuffix = isPrimary ? " (Primary)" : ""
        let item = NSMenuItem(
            title: "\(titlePrefix) \(networkInterface.name): \(networkInterface.address)\(primarySuffix)",
            action: #selector(copyInterfaceIPAddress(_:)),
            keyEquivalent: ""
        )
        item.target = self
        item.representedObject = networkInterface.address
        item.image = NSImage(
            systemSymbolName: StatusDisplay.symbolName(for: networkInterface.kind),
            accessibilityDescription: titlePrefix
        )
        return item
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
    private func copyInterfaceIPAddress(_ sender: NSMenuItem) {
        guard let ipAddress = sender.representedObject as? String else {
            return
        }

        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(ipAddress, forType: .string)
    }

    @objc
    private func quit() {
        NSApp.terminate(nil)
    }
}

let application = NSApplication.shared
let delegate = AppDelegate()
application.delegate = delegate
application.run()
