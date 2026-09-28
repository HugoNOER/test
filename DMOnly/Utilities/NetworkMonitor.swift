import Foundation
import Network
import Combine

/// Real-time network reachability monitor using Apple's Network framework.
final class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()
    
    @Published private(set) var isConnected: Bool = true
    @Published private(set) var isCellular: Bool = false
    
    private let monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "com.personal.dmonly.networkmonitor")
    
    private init() {
        monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = (path.status == .satisfied)
                self?.isCellular = path.usesInterfaceType(.cellular)
            }
        }
        monitor.start(queue: queue)
    }
    
    deinit {
        monitor.cancel()
    }
}
