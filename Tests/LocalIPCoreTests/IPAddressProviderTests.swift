import Testing
@testable import LocalIPCore

@Test("selects the first active non-loopback IPv4 address")
func selectsFirstActiveNonLoopbackIPv4Address() {
    let interfaces = [
        NetworkInterface(name: "lo0", address: "127.0.0.1", family: .ipv4, isLoopback: true, isActive: true),
        NetworkInterface(name: "en0", address: "192.168.1.42", family: .ipv4, isLoopback: false, isActive: true),
        NetworkInterface(name: "en1", address: "10.0.0.8", family: .ipv4, isLoopback: false, isActive: true)
    ]

    #expect(IPAddressProvider.preferredIPv4Address(from: interfaces) == "192.168.1.42")
}

@Test("prefers the primary interface address when Wi-Fi and LAN are both active")
func prefersPrimaryInterfaceAddressWhenMultipleNetworksAreActive() {
    let interfaces = [
        NetworkInterface(name: "en0", address: "192.168.1.42", family: .ipv4, isLoopback: false, isActive: true, kind: .wifi),
        NetworkInterface(name: "en7", address: "10.0.0.8", family: .ipv4, isLoopback: false, isActive: true, kind: .wired)
    ]

    #expect(IPAddressProvider.preferredIPv4Address(from: interfaces, primaryInterfaceName: "en7") == "10.0.0.8")
}

@Test("ignores inactive, loopback, IPv6, and self-assigned IPv4 addresses")
func ignoresAddressesThatShouldNotBeShownInTheMenuBar() {
    let interfaces = [
        NetworkInterface(name: "en0", address: "169.254.10.20", family: .ipv4, isLoopback: false, isActive: true),
        NetworkInterface(name: "en1", address: "fe80::1", family: .ipv6, isLoopback: false, isActive: true),
        NetworkInterface(name: "lo0", address: "127.0.0.1", family: .ipv4, isLoopback: true, isActive: true),
        NetworkInterface(name: "en2", address: "10.0.0.5", family: .ipv4, isLoopback: false, isActive: false)
    ]

    #expect(IPAddressProvider.preferredIPv4Address(from: interfaces) == nil)
}

@Test("returns every active local IPv4 interface for the dropdown")
func returnsEveryActiveLocalIPv4InterfaceForTheDropdown() {
    let interfaces = [
        NetworkInterface(name: "lo0", address: "127.0.0.1", family: .ipv4, isLoopback: true, isActive: true),
        NetworkInterface(name: "en0", address: "192.168.1.42", family: .ipv4, isLoopback: false, isActive: true, kind: .wifi),
        NetworkInterface(name: "en7", address: "10.0.0.8", family: .ipv4, isLoopback: false, isActive: true, kind: .wired),
        NetworkInterface(name: "en8", address: "169.254.10.20", family: .ipv4, isLoopback: false, isActive: true),
        NetworkInterface(name: "en9", address: "fe80::1", family: .ipv6, isLoopback: false, isActive: true),
        NetworkInterface(name: "en10", address: "172.16.0.4", family: .ipv4, isLoopback: false, isActive: false)
    ]

    #expect(IPAddressProvider.activeLocalIPv4Interfaces(from: interfaces).map(\.address) == [
        "192.168.1.42",
        "10.0.0.8"
    ])
}

@Test("uses the IP address as the visible menu bar title")
func usesIPAddressAsVisibleMenuBarTitle() {
    #expect(StatusDisplay.menuBarTitle(for: "192.168.1.42") == "192.168.1.42")
    #expect(StatusDisplay.menuBarTitle(for: nil) == "No IP")
}

@Test("uses Wi-Fi and wired symbols for interface menu items")
func usesSymbolsForInterfaceMenuItems() {
    #expect(StatusDisplay.symbolName(for: .wifi) == "wifi")
    #expect(StatusDisplay.symbolName(for: .wired) == "cable.connector")
    #expect(StatusDisplay.symbolName(for: .other) == "network")
}
