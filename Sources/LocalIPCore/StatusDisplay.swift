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
}
