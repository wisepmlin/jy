import SwiftUI

// MARK: - Banner Configuration
public struct BannerConfig {
    let autoScrollInterval: TimeInterval
    let showIndicator: Bool
    let cornerRadius: CGFloat
    let height: CGFloat
    let indicatorSpacing: CGFloat
    let indicatorPadding: EdgeInsets
    let titleFont: Font
    let titlePadding: EdgeInsets
    
    public init(
        autoScrollInterval: TimeInterval = 3.0,
        showIndicator: Bool = true,
        cornerRadius: CGFloat = 10,
        height: CGFloat = 134,
        indicatorSpacing: CGFloat = 4,
        indicatorPadding: EdgeInsets = .init(top: 0, leading: 0, bottom: 8, trailing: 0),
        titleFont: Font = .system(size: 16, weight: .bold),
        titlePadding: EdgeInsets = .init(top: 6, leading: 12, bottom: 6, trailing: 12)
    ) {
        self.autoScrollInterval = autoScrollInterval
        self.showIndicator = showIndicator
        self.cornerRadius = cornerRadius
        self.height = height
        self.indicatorSpacing = indicatorSpacing
        self.indicatorPadding = indicatorPadding
        self.titleFont = titleFont
        self.titlePadding = titlePadding
    }
    
    public static let `default` = BannerConfig()
}

// MARK: - Banner Item Model
public struct BannerItem: Identifiable, Equatable, Hashable {
    public let id: Int
    public let title: String
    public let imageUrl: String
    
    public init(id: Int, title: String, imageUrl: String) {
        self.id = id
        self.title = title
        self.imageUrl = imageUrl
    }
}

// MARK: - Banner Item View
struct BannerItemView: View {
    @Environment(\.theme) private var theme
    let item: BannerItem
    let config: BannerConfig
    
    var body: some View {
        KFImage(URL(string: item.imageUrl))
            .resizable()
            .placeholder {
                ProgressView() // 加载中显示进度条
            }
            .fade(duration: 0.2) // 加载完成后的动画
            .cacheOriginalImage()
            .memoryCacheExpiration(.days(14))
            .diskCacheExpiration(.days(60))
            .cancelOnDisappear(true)
            .loadDiskFileSynchronously()
            .setProcessor(DownsamplingImageProcessor(size: CGSize(width: (UIScreen.main.bounds.width - 16) * 2, height: 134 * 2)))
            .scaledToFill()
            .frame(height: 134)
            .frame(width: UIScreen.main.bounds.width - 16)
            .overlay(alignment: .bottomLeading) {
                LinearGradient(
                    gradient: Gradient(colors: [.clear, .black.opacity(0.35)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 36)
                .blendMode(.darken)
            }
            .overlay(alignment: .bottomLeading) {
                Text(item.title)
                    .font(config.titleFont)
                    .foregroundColor(Color.white)
                    .lineLimit(1)
                    .shadow(color: Color.black.opacity(0.5), radius: 2)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    }
            .overlay(alignment: .topLeading) {
                HStack {
                    MyIcon()
                        .fill(Color.white)
                        .frame(width: 14, height: 14)
                    Text("金鹰星球")
                        .customFont(fontSize: 12)
                        .baselineOffset(-1)
                        .foregroundColor(Color.white)
                }
                .padding(12)
                }
            .compositingGroup()
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Page Indicator
private struct PageIndicator: View {
    @Environment(\.theme) private var theme
    let totalPages: Int
    let currentPage: Int
    let spacing: CGFloat
    
    var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<totalPages, id: \.self) { index in
                Rectangle()
                    .fill(currentPage == index ? theme.background : theme.background.opacity(0.35))
                    .frame(width: 8, height: 2)
            }
        }
    }
}
