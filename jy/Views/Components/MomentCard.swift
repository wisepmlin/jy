import SwiftUI

struct MomentCard: View {
    @Environment(\.theme) private var theme
    let moment: MomentItem
    @State var showShareMenu = false
    @State var ideaText = ""
    let article = ArticleContent.article
    let friends: [Friend] = [
        Friend(name: "财务总监", avatar: "https://img2.baidu.com/it/u=2919443825,85323390&fm=253&fmt=auto&app=120&f=JPEG?w=800&h=800"),
        Friend(name: "会计主管", avatar: "https://img2.baidu.com/it/u=278246514,3170436431&fm=253&fmt=auto&app=120&f=JPEG?w=800&h=800"),
        Friend(name: "税务专员", avatar: "https://img2.baidu.com/it/u=1567480039,3605884834&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=500"),
        Friend(name: "成本会计", avatar: "https://img1.baidu.com/it/u=3513841559,2892662125&fm=253&fmt=auto&app=120&f=JPEG?w=800&h=800"),
        Friend(name: "审计经理", avatar: "https://img0.baidu.com/it/u=4233203734,1642094654&fm=253&fmt=auto&app=138&f=JPEG?w=800&h=800"),
        Friend(name: "财务分析师", avatar: "https://img1.baidu.com/it/u=3201861296,3147953300&fm=253&fmt=auto&app=120&f=JPEG?w=800&h=800"),
        Friend(name: "出纳主管", avatar: "https://img0.baidu.com/it/u=1740280333,3850630008&fm=253&fmt=auto&app=120&f=JPEG?w=800&h=800"),
        Friend(name: "预算专员", avatar: "https://img0.baidu.com/it/u=2626860580,3349748790&fm=253&fmt=auto?w=500&h=500"),
        Friend(name: "资金主管", avatar: "https://img0.baidu.com/it/u=2176787830,3321947122&fm=253&fmt=auto?w=500&h=500")
    ]
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            MomentUserInfoView(moment: moment)
            
            MomentContentView(content: moment.content)
            
            ImageGridView(moment: moment)
            
            MomentLinkedContentView(moment: moment)
            MomentRecommendationsView(moment: moment)
            
            Divider().opacity(0.7)
            MomentInteractionView(moment: moment, showShareMenu: $showShareMenu)
        }
        .padding(.vertical, 12)
        .background(theme.background.cornerRadius(theme.defaultCornerRadius))
        .standardListRowStyle()
        .buttonStyle(.borderless)
        .sheet(isPresented: $showShareMenu) {
            ShareOverlayView(
                showShareMenu: $showShareMenu,
                ideaText: $ideaText,
                article: article,
                friends: friends
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .background(theme.background)
        }
    }
} 
