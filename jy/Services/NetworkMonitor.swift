import SwiftUI
import Foundation
import Network

@MainActor
class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()
    private let monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    @Published var isConnected = true
    @Published var isExpensive = false
    @Published var connectionType = ConnectionType.unknown
    
    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown
    }
    
    private init() {
        monitor = NWPathMonitor()
        startMonitoring()
    }
    
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            withAnimation(.smooth) {
                DispatchQueue.main.async {
                    // 首先检查网络接口类型
                    let interfaces = path.availableInterfaces
                    let interfaceTypes = interfaces.map { $0.type }
                    
                    // 根据可用接口确定连接类型
                    let connectionType: ConnectionType = {
                        if interfaces.contains(where: { $0.type == .wifi }) {
                            return .wifi
                        } else if interfaces.contains(where: { $0.type == .cellular }) {
                            return .cellular
                        } else if interfaces.contains(where: { $0.type == .wiredEthernet }) {
                            return .ethernet
                        } else {
                            return .unknown
                        }
                    }()
                    
                    // 更新连接状态
                    let isConnected = connectionType != .unknown && path.status == .satisfied
                    let isExpensive = path.isExpensive
                    
                    // 记录详细的状态变化
                    print("网络状态变化:")
                    print("- 连接状态: \(isConnected ? "已连接" : "未连接")")
                    print("- 连接类型: \(connectionType)")
                    print("- 网络接口: \(interfaceTypes)")
                    print("- 是否计费网络: \(isExpensive ? "是" : "否")")
                    print("- 连接质量: \(path.isConstrained ? "受限" : "正常")")
                    
                    // 更新状态
                    self?.connectionType = connectionType
                    self?.isConnected = isConnected
                    self?.isExpensive = isExpensive
                }
            }
        }
        
        monitor.start(queue: queue)
    }
    
    deinit {
        monitor.cancel()
    }
}
