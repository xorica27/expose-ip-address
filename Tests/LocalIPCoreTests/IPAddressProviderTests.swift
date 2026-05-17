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

@Test("uses a compact menu bar title so the item stays visible")
func usesCompactMenuBarTitle() {
    #expect(StatusDisplay.menuBarTitle(for: "192.168.1.42") == "IP")
    #expect(StatusDisplay.menuBarTitle(for: nil) == "IP")
}
