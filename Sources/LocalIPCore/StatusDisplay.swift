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
}
