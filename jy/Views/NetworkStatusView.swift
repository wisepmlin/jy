import SwiftUI

struct NetworkStatusView: View {
    @Environment(\.theme) private var theme
    @StateObject private var networkMonitor = NetworkMonitor.shared
    
    var body: some View {
        ZStack {
            if !networkMonitor.isConnected {
                HStack(spacing: 8) {
                    Image(systemName: "wifi.slash")
                        .foregroundColor(theme.background)
                    Text("网络连接已断开")
                        .foregroundColor(theme.background)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(theme.jyxqPrimary)
                .cornerRadius(theme.minCornerRadius)
                .shadow(color: Color.black.opacity(0.35), radius: 12)
                .transition(
                    .asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity).combined(with: .scale(scale: 1.05)),
                        removal: .move(edge: .top).combined(with: .opacity).combined(with: .scale(scale: 1))
                    )
                )
            }
        }
        .animation(.smooth, value: networkMonitor.isConnected)
    }
}

#Preview {
    NetworkStatusView()
}
