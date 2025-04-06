import SwiftUI
import SwiftUIX

struct NotificationView: View {
    @EnvironmentObject private var stackDepth: StackDepthManager
    @Environment(\.theme) private var theme
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab: TabItem?
    
    // 通知类型标签
    let tabs = TabItem.notificationTopAllTabs
    
    var body: some View {
        VStack(spacing: 0) {
            // 标签栏
            ScrollableTabBar(selectedTab: $selectedTab,
                           tabs: tabs)
            
            // 通知列表
            TabView(selection: Binding(
                get: { tabs.firstIndex(where: { $0 == selectedTab }) ?? 0 },
                set: { selectedTab = tabs[$0] }
            )) {
                ForEach(enumerating: tabs) { index, tab in
                    NotificationListView(type: tab.id)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .navigationBarTitleDisplayMode(.inline)
        .background(theme.gray6Background)
        .navigationBarBackground()
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("通知")
                    .themeFont(theme.fonts.title3)
                    .foregroundColor(theme.primaryText)
            }
        }
        .onAppear {
            withAnimation(.interactiveSpring()) {
                stackDepth.depth = 1
            }
            print("HotTopicDetailView - 当前导航栈深度: \(stackDepth.depth)")
        }
        .onDisappear {
            withAnimation(.interactiveSpring()) {
                stackDepth.depth = 0
            }
            print("HotTopicDetailView - 当前导航栈深度: \(stackDepth.depth)")
        }
    }
}

// 通知列表视图
struct NotificationListView: View {
    let type: String
    @StateObject private var viewModel = NotificationViewModel()
    
    var body: some View {
        List(viewModel.notifications) { notification in
            NotificationCell(notification: notification)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
        }
        .contentMargins(.top, 8, for: .scrollContent)
        .listStyle(.plain)
        .listRowSpacing(8)
        .refreshable {
            
        }
        .onAppear {
            viewModel.loadNotifications(type: type)
        }
    }
}

// 通知单元格视图
struct NotificationCell: View {
    @Environment(\.theme) private var theme
    let notification: NotificationItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 头部信息
            HStack(spacing: 12) {
                // 通知图标
                Image(systemName: notification.icon)
                    .font(.system(size: 20))
                    .foregroundColor(theme.jyxqPrimary)
                    .frame(width: 40, height: 40)
                    .background(theme.jyxqPrimary.opacity(0.1))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(notification.title)
                        .themeFont(theme.fonts.body)
                        .foregroundColor(theme.primaryText)
                    
                    Text(notification.time)
                        .themeFont(theme.fonts.caption)
                        .foregroundColor(theme.subText2)
                }
                
                Spacer()
                
                // 未读标记
                if !notification.isRead {
                    Circle()
                        .fill(theme.jyxqPrimary)
                        .frame(width: 8, height: 8)
                }
            }
            
            // 通知内容
            Text(notification.content)
                .themeFont(theme.fonts.body)
                .foregroundColor(theme.primaryText)
                .lineLimit(3)
                .padding(.leading, 52)
            
            // 相关内容预览（如果有）
            if let preview = notification.preview {
                NotificationPreview(preview: preview)
                    .padding(.leading, 52)
            }
        }
        .padding(12)
        .background(theme.background)
        .cornerRadius(theme.defaultCornerRadius)
    }
}

// 通知预览视图
struct NotificationPreview: View {
    @Environment(\.theme) private var theme
    let preview: NotificationPreviewItem
    
    var body: some View {
        HStack(spacing: 12) {
            // 预览图片
//            if let imageUrl = preview.imageUrl {
                Rectangle()
                    .fill(theme.gray6Background)
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
//            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(preview.title)
                    .themeFont(theme.fonts.small)
                    .foregroundColor(theme.primaryText)
                    .lineLimit(2)
                
                if let subtitle = preview.subtitle {
                    Text(subtitle)
                        .themeFont(theme.fonts.caption)
                        .foregroundColor(theme.subText2)
                        .lineLimit(1)
                }
            }
        }
        .padding(8)
        .background(theme.gray6Background)
        .cornerRadius(8)
    }
}

#Preview {
    NotificationView()
}
