import SwiftUI
import SwiftUIX

struct NewsCarouselView: View {
    @Environment(\.theme) private var theme
    @State private var currentIndex = 0
    @State private var timer: Timer?
    @State private var isDragging = false
    @State private var isAutoScrolling = false
    @Binding var navigationPath: [NavigationType]
    let newsItems = [
        BannerItem(id: 0, title:  "5个关键财务比率，快速诊断企业健康状况", imageUrl: "https://img2.baidu.com/it/u=3279699622,3947882563&fm=253&fmt=auto&app=138&f=JPEG?w=1600&h=500"),
        BannerItem(id: 1, title:  "财务小白入门指南：5分钟看懂三大财务报表", imageUrl: "https://img1.baidu.com/it/u=122744084,2797501716&fm=253&fmt=auto&app=138&f=JPEG?w=980&h=500"),
        BannerItem(id: 2, title:  "现金流管理秘籍：如何避免企业资金链断裂", imageUrl: "https://q1.itc.cn/q_70/images01/20241120/21cf5f93f9cf4bcfb3be018e84a0fe4b.jpeg")
    ]
    
    let config = BannerConfig(
        autoScrollInterval: 5.0,  // 5秒切换一次
        showIndicator: true,      // 显示指示器
        cornerRadius: 12,         // 圆角大小
        height: 134,             // Banner 高度
        indicatorPadding: EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8),
        titleFont: .system(size: 17, weight: .bold)  // 标题字体
    )
    
    private func startTimer() {
        stopTimer()
        guard !isDragging else { return }
        
        DispatchQueue.main.async {
            timer = Timer.scheduledTimer(withTimeInterval: config.autoScrollInterval, repeats: true) { _ in
                withAnimation(.smooth) {
                    currentIndex = (currentIndex + 1) % newsItems.count
                }
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            PageViewController(pages: newsItems.map { item in
                BannerItemView(item: item, config: config)
                    .onTapGesture {
                        navigationPath.append(NavigationType.news(title: "5个关键财务比率，快速诊断企业健康状况"))
                    }
            }, currentPage: $currentIndex)
            
            pageIndicator
        }
        .frame(height: config.height)
        .cornerRadius(config.cornerRadius)
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
        .standardListRowStyle()
    }
    // MARK: - Private Views
    @ViewBuilder
    private var pageIndicator: some View {
        HStack(spacing: 3) {
            ForEach(0..<newsItems.count, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(currentIndex == index ? theme.jyxqPrimary : Color.white.opacity(0.5))
                    .frame(width: 5, height: 2)
            }
        }
        .padding(config.indicatorPadding / 2)
        .background(Material.ultraThin)
        .cornerRadius(12)
        .padding(config.indicatorPadding)
    }
}

#Preview {
    NewsCarouselView(navigationPath: .constant([]))
}
