import Foundation

enum RefreshState {
    case idle
    case pulling(progress: CGFloat)
    case refreshing
    case willRefresh
    case finishing
    
    var localizedDescription: String {
        switch self {
        case .idle:
            return "下拉刷新"
        case .pulling:
            return "释放立即刷新"
        case .refreshing:
            return "正在刷新..."
        case .willRefresh:
            return "即将刷新..."
        case .finishing:
            return "刷新完成"
        }
    }
} 