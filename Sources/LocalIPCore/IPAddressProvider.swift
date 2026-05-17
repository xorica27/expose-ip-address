import Foundation

#if canImport(Darwin)
import Darwin
#endif

public enum AddressFamily: Equatable {
    case ipv4
    case ipv6
}

public struct NetworkInterface: Equatable {
    public let name: String
    public let address: String
    public let family: AddressFamily
    public let isLoopback: Bool
    public let isActive: Bool

    public init(
        name: String,
        address: String,
        family: AddressFamily,
        isLoopback: Bool,
        isActive: Bool
    ) {
        self.name = name
        self.address = address
        self.family = family
        self.isLoopback = isLoopback
        self.isActive = isActive
    }
}

public enum IPAddressProvider {
    public static func currentPreferredIPv4Address() -> String? {
        preferredIPv4Address(from: currentInterfaces())
    }

    public static func preferredIPv4Address(from interfaces: [NetworkInterface]) -> String? {
        interfaces.first { networkInterface in
            networkInterface.family == .ipv4 &&
                networkInterface.isActive &&
                !networkInterface.isLoopback &&
                !networkInterface.address.hasPrefix("169.254.")
        }?.address
    }

    public static func currentInterfaces() -> [NetworkInterface] {
        #if canImport(Darwin)
        var interfacePointer: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&interfacePointer) == 0, let firstInterface = interfacePointer else {
            return []
        }

        defer { freeifaddrs(interfacePointer) }

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
                isActive: (flags & UInt32(IFF_UP)) != 0
            )
        }
        #else
        return []
        #endif
    }
}
