public enum StatusDisplay {
    public static func menuBarTitle(for ipAddress: String?) -> String {
        ipAddress ?? "No IP"
    }

    public static func symbolName(for interfaceKind: NetworkInterfaceKind) -> String {
        switch interfaceKind {
        case .wifi:
            "wifi"
        case .wired:
            "cable.connector"
        case .other:
            "network"
        }
    }

    public static func launchAtLoginTitle(isEnabled: Bool) -> String {
        isEnabled ? "Launch at Login: On" : "Launch at Login: Off"
    }

    public static func copyFeedbackTitle() -> String {
        "Copied"
    }

    public static func aboutInformativeText(version: String, build: String) -> String {
        """
        Version \(version) (\(build))

        Exposé IP Address shows your primary local IP in the menu bar and lists active Wi-Fi/LAN IPv4 addresses for quick copying.

        Privacy: No data leaves your Mac. The app reads local network interface information only.

        GitHub: https://github.com/xorica27/expose-ip-address
        """
    }
}
