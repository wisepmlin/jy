//
//  HotView.swift
//  jy
//
//  Created by 林晓彬 on 2025/2/17.
//
import SwiftUI

struct HotView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.theme) private var theme
    @State private var currentIndex = 0
    @State private var timer: Timer?
    @Binding var navigationPath: [NavigationType]
    let carouselItems = [
        Column(
            title: "企业财务管理实战指南：从入门到精通的系统课程",
            coverImage: "https://p7.itc.cn/q_70/images03/20231121/755817c8f19c429fb8870df1e4e28e6d.jpeg",
            articleCount: 25,
            subscriberCount: 12800,
            description: "深入解析企业财务管理的核心要素，从实战角度剖析财务决策与风险控制",
            category: "财务管理",
            price: 299.0,
            author: ColumnAuthor(
                name: "张明",
                avatar: "https://q8.itc.cn/q_70/images03/20241001/524544d2aa004b8892b4ed45c5f65231.jpeg",
                title: "资深财务顾问",
                description: "前某500强企业财务总监，20年企业财务管理经验"
            ),
            articles: [
                ColumnArticle(title: "现金流管理的艺术", publishDate: Date(), readCount: 3500, likeCount: 286, commentCount: 45, isPaid: true),
                ColumnArticle(title: "预算控制实战技巧", publishDate: Date().addingTimeInterval(-86400*2), readCount: 2800, likeCount: 195, commentCount: 32, isPaid: false)
            ],
            hot: "34563"
        ),
        Column(
            title: "企业税务筹划精讲：合法节税与风险防控完整指南",
            coverImage: "https://5b0988e595225.cdn.sohucs.com/images/20200513/8f64cec17b1d454fb46bcddc6072eb24.jpeg",
            articleCount: 28,
            subscriberCount: 11600,
            description: "系统讲解企业税务筹划方法，助力企业合法节税",
            category: "税务管理", 
            price: 399.0,
            author: ColumnAuthor(
                name: "李华",
                avatar: "https://iknow-pic.cdn.bcebos.com/023b5bb5c9ea15cebe696b97a4003af33b87b2ad",
                title: "税务专家",
                description: "注册税务师，为上百家企业提供税务咨询服务"
            ),
            articles: [
                ColumnArticle(title: "企业所得税筹划技巧", publishDate: Date(), readCount: 3100, likeCount: 268, commentCount: 38, isPaid: true),
                ColumnArticle(title: "增值税优化方案", publishDate: Date().addingTimeInterval(-86400*3), readCount: 2800, likeCount: 245, commentCount: 35, isPaid: true)
            ],
            hot: "43645"
        ),
        Column(
            title: "企业财务管理实战指南：从财务分析到决策优化的全流程",
            coverImage: "https://img1.baidu.com/it/u=1336521671,1852635305&fm=253&fmt=auto&app=138&f=JPEG?w=800&h=1200",
            articleCount: 25,
            subscriberCount: 12800,
            description: "深入解析企业财务管理的核心要素，从实战角度剖析财务决策与风险控制",    
            category: "财务管理",
            price: 299.0,
            author: ColumnAuthor(
                name: "张明",
                avatar: "https://q8.itc.cn/q_70/images03/20241001/524544d2aa004b8892b4ed45c5f65231.jpeg",
                title: "资深财务顾问",
                description: "前某500强企业财务总监，20年企业财务管理经验"
            ),          
            articles: [
                ColumnArticle(title: "现金流管理的艺术", publishDate: Date(), readCount: 3500, likeCount: 286, commentCount: 45, isPaid: true),
                ColumnArticle(title: "预算控制实战技巧", publishDate: Date().addingTimeInterval(-86400*2), readCount: 2800, likeCount: 195, commentCount: 32, isPaid: false)
            ],
            hot: "34563"
        ),
        Column(
            title: "企业税务筹划精讲：从税收政策解读到实操案例分析",
            coverImage: "https://photo.tuchong.com/1870556/f/289393737.jpg",
            articleCount: 28,
            subscriberCount: 11600,
            description: "系统讲解企业税务筹划方法，助力企业合法节税",
            category: "税务管理",
            price: 399.0,
            author: ColumnAuthor(
                name: "李华",
                avatar: "https://iknow-pic.cdn.bcebos.com/023b5bb5c9ea15cebe696b97a4003af33b87b2ad",
                title: "税务专家",  
                description: "注册税务师，为上百家企业提供税务咨询服务"
            ),
            articles: [
                ColumnArticle(title: "企业所得税筹划技巧", publishDate: Date(), readCount: 3100, likeCount: 268, commentCount: 38, isPaid: true),
                ColumnArticle(title: "增值税优化方案", publishDate: Date().addingTimeInterval(-86400*3), readCount: 2800, likeCount: 245, commentCount: 35, isPaid: true)
            ],
            hot: "43645"
        ),
        Column(
            title: "内部控制体系建设：从框架设计到持续改进的实践指南",
            coverImage: "https://img.zcool.cn/community/0190525ca72afda801208f8b187b44.jpg?x-oss-process=image/auto-orient,1/resize,m_lfit,w_1280,limit_1/sharpen,100",
            articleCount: 32,
            subscriberCount: 9600,
            description: "企业内控体系搭建与优化指南，提升企业管理水平",    
            category: "内控管理",
            price: 499.0,
            author: ColumnAuthor(
                name: "王芳",
                avatar: "https://ww2.sinaimg.cn/mw690/006fLFOwgy1hszbx5ykafj30u00u0tu1.jpg",
                title: "内控专家",
                description: "资深内控顾问，参与过多家上市公司内控体系建设"
            ),
            articles: [
                ColumnArticle(title: "内控体系框架设计", publishDate: Date(), readCount: 2200, likeCount: 186, commentCount: 42, isPaid: true),
                ColumnArticle(title: "内控缺陷整改方案", publishDate: Date().addingTimeInterval(-86400*1), readCount: 1800, likeCount: 155, commentCount: 38, isPaid: true)
            ],
            hot: "32567"    
        ),
        Column(
            title: "内部控制体系建设：企业管理升级与风险防范的系统方案",
            coverImage: "https://img1.baidu.com/it/u=3145103595,3291430997&fm=253&fmt=auto&app=138&f=JPEG?w=800&h=1200",
            articleCount: 32,
            subscriberCount: 9600,
            description: "企业内控体系搭建与优化指南，提升企业管理水平",
            category: "内控管理",
            price: 499.0,
            author: ColumnAuthor(
                name: "王芳",
                avatar: "https://ww2.sinaimg.cn/mw690/006fLFOwgy1hszbx5ykafj30u00u0tu1.jpg",
                title: "内控专家",
                description: "资深内控顾问，参与过多家上市公司内控体系建设"
            ),
            articles: [
                ColumnArticle(title: "内控体系框架设计", publishDate: Date(), readCount: 2200, likeCount: 186, commentCount: 42, isPaid: true),
                ColumnArticle(title: "内控缺陷整改方案", publishDate: Date().addingTimeInterval(-86400*1), readCount: 1800, likeCount: 155, commentCount: 38, isPaid: true)
            ],
            hot: "32567"
        )
    ]
    
    let config = BannerConfig(
        autoScrollInterval: 5.0,  // 5秒切换一次
        showIndicator: true,      // 显示指示器
        cornerRadius: 8,         // 圆角大小
        height: 200,             // Banner 高度
        indicatorPadding: EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12),
        titleFont: .system(size: 17, weight: .bold)  // 标题字体
    )
    
    var body: some View {
        VStack(spacing: 12) {
            ExtractedView(count: carouselItems.count, index: currentIndex)
                .padding(EdgeInsets(top: 12, leading: 12, bottom: 0, trailing: 12))
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 8) {
                    ForEach(Array(carouselItems.enumerated()), id: \.1.id) { index, item in
                        HotRow(item: item, index: index)
                            .onTapGesture {
                                navigationPath.append(NavigationType.news(title: "5个关键财务比率，快速诊断企业健康状况"))
                            }
                    }
                }
                .padding(EdgeInsets(top: 0, leading: 12, bottom: 12, trailing: 12))
            }
            .scrollViewPreload(distance: 100)
        }
        .background(alignment: .topLeading) {
            Circle()
                .fill(theme.jyxqPrimary)
                .frame(width: 120, height: 120, alignment: .center)
                .offset(x: -50, y: -80)
                .blur(radius: 44)
                .opacity(colorScheme == .dark ? 0.35 : 0.5)
        }
        .background(theme.background)
        .compositingGroup()
        .clipShape(RoundedRectangle(cornerRadius: theme.defaultCornerRadius))
        .standardListRowStyle()
    }
}

struct HotRow: View {
    @Environment(\.theme) private var theme
    let item: Column
    let index: Int
    private let imageCache = NSCache<NSString, UIImage>()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            coverImageView
            titleView
        }
        .frame(width: 90)
        .containerShape(Rectangle())
    }
    
    // MARK: - Subviews
    
    private var coverImageView: some View {
        KFImage(URL(string: item.coverImage))
            .resizable()
            .placeholder {
                ProgressView()
            }
            .fade(duration: 0.2)
            .cacheOriginalImage()
            .memoryCacheExpiration(.days(14))
            .diskCacheExpiration(.days(60))
            .cancelOnDisappear(true)
            .loadDiskFileSynchronously()
            .setProcessor(DownsamplingImageProcessor(size: CGSize(width: 90 * 2, height: 120 * 2)))
            .scaledToFill()
            .frame(width: 90, height: 120)
            .overlay(alignment: .topLeading) {
                overlayContent
            }
            .compositingGroup()
            .clipShape(RoundedRectangle(cornerRadius: theme.minCornerRadius))
    }
    
    private var overlayContent: some View {
        ZStack {
            gradientBackground
            VStack(alignment: .leading) {
                indexBadge
                Spacer()
                columnLabel
            }
        }
    }
    
    private var gradientBackground: some View {
        LinearGradient(
            stops: [
                .init(color: .clear, location: 0),
                .init(color: Color.black.opacity(0.35), location: 1)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private var indexBadge: some View {
        ShieldIcon(cornerRadius: theme.minCornerRadius - 1)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        theme.jyxqPrimary,
                        theme.jyxqPrimary.opacity(0.5)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .stroke(theme.jyxqPrimary, lineWidth: 2)
            .frame(width: 20, height: 24.5)
            .padding(1)
            .overlay {
                Text("\(index)")
                    .themeFont(theme.fonts.small.bold())
                    .foregroundColor(theme.background)
            }
    }
    
    private var columnLabel: some View {
        Text("栏目")
            .customFont(fontSize: 10)
            .baselineOffset(-1)
            .foregroundColor(theme.background)
            .padding(.vertical, 2)
            .padding(.horizontal, 4)
            .background {
                RoundedRectangle(cornerRadius: 3)
                    .fill(theme.primaryText.opacity(0.75))
            }
            .padding(4)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var titleView: some View {
        Text(item.title)
            .themeFont(theme.fonts.small.bold())
            .foregroundColor(theme.primaryText)
            .kerning(0.5)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
    }
}

extension ScrollView {
    func scrollViewPreload(distance: CGFloat = 50) -> some View {
        self.onAppear {
            UICollectionView.appearance().isPrefetchingEnabled = true
        }
    }
}
