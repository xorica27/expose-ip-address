import Foundation

#if canImport(Darwin)
import Darwin
#endif

#if canImport(SystemConfiguration)
import SystemConfiguration
#endif

public enum AddressFamily: Equatable {
    case ipv4
    case ipv6
}

public enum NetworkInterfaceKind: Equatable {
    case wifi
    case wired
    case other
}

public struct NetworkInterface: Equatable {
    public let name: String
    public let address: String
    public let family: AddressFamily
    public let isLoopback: Bool
    public let isActive: Bool
    public let kind: NetworkInterfaceKind

    public init(
        name: String,
        address: String,
        family: AddressFamily,
        isLoopback: Bool,
        isActive: Bool,
        kind: NetworkInterfaceKind = .other
    ) {
        self.name = name
        self.address = address
        self.family = family
        self.isLoopback = isLoopback
        self.isActive = isActive
        self.kind = kind
    }
}

public enum IPAddressProvider {
    public static func currentPreferredIPv4Address() -> String? {
        preferredIPv4Address(from: currentInterfaces(), primaryInterfaceName: currentPrimaryInterfaceName())
    }

    public static func preferredIPv4Address(
        from interfaces: [NetworkInterface],
        primaryInterfaceName: String? = nil
    ) -> String? {
        let activeInterfaces = activeLocalIPv4Interfaces(from: interfaces)

        if let primaryInterfaceName,
           let primaryInterface = activeInterfaces.first(where: { $0.name == primaryInterfaceName }) {
            return primaryInterface.address
        }

        return activeInterfaces.first?.address
    }

    public static func activeLocalIPv4Interfaces(from interfaces: [NetworkInterface]) -> [NetworkInterface] {
        interfaces.filter { networkInterface in
            networkInterface.family == .ipv4 &&
            networkInterface.isActive &&
            !networkInterface.isLoopback &&
            !networkInterface.address.hasPrefix("169.254.")
        }
    }

    public static func currentActiveLocalIPv4Interfaces() -> [NetworkInterface] {
        activeLocalIPv4Interfaces(from: currentInterfaces())
    }

    public static func currentInterfaces() -> [NetworkInterface] {
        #if canImport(Darwin)
        var interfacePointer: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&interfacePointer) == 0, let firstInterface = interfacePointer else {
            return []
        }

        defer { freeifaddrs(interfacePointer) }

        let interfaceKinds = currentInterfaceKinds()

        return sequence(first: firstInterface, next: { $0.pointee.ifa_next }).compactMap { pointer in
            let interface = pointer.pointee
            guard let socketAddress = interface.ifa_addr else {
                return nil
            }

            let socketFamily = Int32(socketAddress.pointee.sa_family)
            let family: AddressFamily
            switch socketFamily {
            case AF_INET:
                family = .ipv4
            case AF_INET6:
                family = .ipv6
            default:
                return nil
            }

            var hostBuffer = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            let result = getnameinfo(
                socketAddress,
                socklen_t(socketAddress.pointee.sa_len),
                &hostBuffer,
                socklen_t(hostBuffer.count),
                nil,
                0,
                NI_NUMERICHOST
            )

            guard result == 0 else {
                return nil
            }

            let flags = interface.ifa_flags
            let address = hostBuffer.withUnsafeBufferPointer { buffer in
                String(cString: buffer.baseAddress!)
            }

            return NetworkInterface(
                name: String(cString: interface.ifa_name),
                address: address,
                family: family,
                isLoopback: (flags & UInt32(IFF_LOOPBACK)) != 0,
                isActive: (flags & UInt32(IFF_UP)) != 0,
                kind: interfaceKinds[String(cString: interface.ifa_name)] ?? .other
            )
        }
        #else
        return []
        #endif
    }

    public static func currentPrimaryInterfaceName() -> String? {
        #if canImport(SystemConfiguration)
        guard
            let dictionary = SCDynamicStoreCopyValue(nil, "State:/Network/Global/IPv4" as CFString)
                as? [String: Any],
            let primaryInterfaceName = dictionary["PrimaryInterface"] as? String
        else {
            return nil
        }

        return primaryInterfaceName
        #else
        return nil
        #endif
    }

    private static func currentInterfaceKinds() -> [String: NetworkInterfaceKind] {
        #if canImport(SystemConfiguration)
        guard let interfaces = SCNetworkInterfaceCopyAll() as? [SCNetworkInterface] else {
            return [:]
        }

        return interfaces.reduce(into: [:]) { result, interface in
            guard let bsdName = SCNetworkInterfaceGetBSDName(interface) as String? else {
                return
            }

            let interfaceType = SCNetworkInterfaceGetInterfaceType(interface).map { $0 as NSString as String }
            if interfaceType == (kSCNetworkInterfaceTypeIEEE80211 as NSString as String) {
                result[bsdName] = .wifi
            } else if interfaceType == (kSCNetworkInterfaceTypeEthernet as NSString as String) {
                result[bsdName] = .wired
            } else {
                result[bsdName] = .other
            }
        }
        #else
        return [:]
        #endif
    }
}
