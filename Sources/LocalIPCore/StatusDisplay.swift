public enum StatusDisplay {
    public static func menuBarTitle(for ipAddress: String?) -> String {
        ipAddress ?? "No IP"
    }
}
