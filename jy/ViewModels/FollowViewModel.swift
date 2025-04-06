import Foundation

struct Author: Identifiable, Equatable, Hashable {
    let id = UUID()
    let name: String
    let avatar: String
    let role: String
}

struct FollowedPost: Identifiable, Equatable, Hashable {
    let id = UUID()
    let authorName: String
    let authorAvatar: String
    let cover: String
    let title: String
    let date: Date
}

struct RecommendedAuthor: Identifiable, Equatable, Hashable {
    let id = UUID()
    let name: String
    let avatar: String
    let role: String
    var isFollowing: Bool
}

class FollowViewModel: ObservableObject {
    @Published var authors: [Author] = []
    @Published var followedPosts: [FollowedPost] = []
    @Published var recommendedAuthors: [RecommendedAuthor] = []
    
    init() {
        // Mock data
        authors = [
            Author(name: "卫夕", avatar: "https://iknow-pic.cdn.bcebos.com/9825bc315c6034a8b67b2f1cd913495408237696", role: "首席执行官"),
            Author(name: "刘志远", avatar: "https://img0.baidu.com/it/u=1569874305,273254068&fm=253&fmt=auto&app=120&f=JPEG?w=800&h=800", role: "财务总监"),
            Author(name: "柯南", avatar: "https://ww2.sinaimg.cn/mw690/006fLFOwgy1hszbx5ykafj30u00u0tu1.jpg", role: "首席财务官"),
            Author(name: "卫夕", avatar: "https://iknow-pic.cdn.bcebos.com/9825bc315c6034a8b67b2f1cd913495408237696", role: "董事长"),
            Author(name: "刘志远", avatar: "https://img0.baidu.com/it/u=1569874305,273254068&fm=253&fmt=auto&app=120&f=JPEG?w=800&h=800", role: "财务经理"),
            Author(name: "柯南", avatar: "https://ww2.sinaimg.cn/mw690/006fLFOwgy1hszbx5ykafj30u00u0tu1.jpg", role: "总裁"),
            Author(name: "卫夕", avatar: "https://iknow-pic.cdn.bcebos.com/9825bc315c6034a8b67b2f1cd913495408237696", role: "财务主管"),
            Author(name: "刘志远", avatar: "https://img0.baidu.com/it/u=1569874305,273254068&fm=253&fmt=auto&app=120&f=JPEG?w=800&h=800", role: "副总裁"),
            Author(name: "柯南", avatar: "https://ww2.sinaimg.cn/mw690/006fLFOwgy1hszbx5ykafj30u00u0tu1.jpg", role: "财务分析师")
        ]
        followedPosts = [
            FollowedPost(
                authorName: "卫夕",
                authorAvatar: "https://iknow-pic.cdn.bcebos.com/9825bc315c6034a8b67b2f1cd913495408237696",
                cover: "https://img1.baidu.com/it/u=3743625788,1008742374&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=717",
                title: "变天！——由一个惊艳例子引发对DeepSeek的10条思考",
                date: Date()
            ),
            FollowedPost(
                authorName: "刘志远",
                authorAvatar: "https://img0.baidu.com/it/u=1569874305,273254068&fm=253&fmt=auto&app=120&f=JPEG?w=800&h=800",
                cover: "https://bpic.wotucdn.com//third58ku/templet/05/22/38/53565cb52a7e725f8c84a4c335ed8e60.jpg%21/fw/1024/quality/80/unsharp/true/compress/true/watermark/url/bG9nby53YXRlci52NS5wbmc=/repeat/true/align/center/format/jpg",
                title: "跨境电商的税务合规：如何避免税务风险？",
                date: Date().addingTimeInterval(-7*24*60*60)
            ),
            FollowedPost(
                authorName: "柯南",
                authorAvatar: "https://ww2.sinaimg.cn/mw690/006fLFOwgy1hszbx5ykafj30u00u0tu1.jpg",
                cover: "https://img.tukuppt.com/preview/00/41/14/58/411458628601413ea21show.jpg",
                title: "跨境电商的税务合规：如何避免税务风险？",
                date: Date().addingTimeInterval(-7*24*60*60)
            ),
            FollowedPost(
                authorName: "卫夕",
                authorAvatar: "https://iknow-pic.cdn.bcebos.com/9825bc315c6034a8b67b2f1cd913495408237696",
                cover: "https://www.phei.com.cn/covers/9787121207990.jpg",
                title: "跨境电商的税务合规：如何避免税务风险？",
                date: Date().addingTimeInterval(-7*24*60*60)
            ),
            FollowedPost(
                authorName: "卫夕",
                authorAvatar: "https://iknow-pic.cdn.bcebos.com/9825bc315c6034a8b67b2f1cd913495408237696",
                cover: "https://file4.renrendoc.com/view/aea8e891294259548f600da1744eccf2/aea8e891294259548f600da1744eccf21.gif",
                title: "跨境电商的税务合规：如何避免税务风险？",
                date: Date().addingTimeInterval(-7*24*60*60)
            ),
            FollowedPost(
                authorName: "卫夕",
                authorAvatar: "https://iknow-pic.cdn.bcebos.com/9825bc315c6034a8b67b2f1cd913495408237696",
                cover: "https://img0.baidu.com/it/u=2619779625,1195772266&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=667",
                title: "跨境电商的税务合规：如何避免税务风险？",
                date: Date().addingTimeInterval(-7*24*60*60)
            )
        ]
        
        recommendedAuthors = [
            RecommendedAuthor(name: "张明", avatar: "https://q8.itc.cn/q_70/images03/20241001/524544d2aa004b8892b4ed45c5f65231.jpeg", role: "首席执行官", isFollowing: false),
            RecommendedAuthor(name: "李华", avatar: "https://iknow-pic.cdn.bcebos.com/023b5bb5c9ea15cebe696b97a4003af33b87b2ad", role: "财务总监", isFollowing: false),
            RecommendedAuthor(name: "王芳", avatar: "https://ww2.sinaimg.cn/mw690/006fLFOwgy1hszbx5ykafj30u00u0tu1.jpg", role: "财务分析师", isFollowing: false),
            RecommendedAuthor(name: "刘强", avatar: "https://ww2.sinaimg.cn/mw690/006fLFOwgy1hszbx5ykafj30u00u0tu1.jpg", role: "董事长", isFollowing: false),
            RecommendedAuthor(name: "陈静", avatar: "https://ww2.sinaimg.cn/mw690/006fLFOwgy1hszbx5ykafj30u00u0tu1.jpg", role: "财务经理", isFollowing: false),
            RecommendedAuthor(name: "赵伟", avatar: "https://ww2.sinaimg.cn/mw690/006fLFOwgy1hszbx5ykafj30u00u0tu1.jpg", role: "总裁", isFollowing: false),
            RecommendedAuthor(name: "孙琳", avatar: "https://ww2.sinaimg.cn/mw690/006fLFOwgy1hszbx5ykafj30u00u0tu1.jpg", role: "财务主管", isFollowing: false)
        ]
    }
    
    func toggleFollow(for author: RecommendedAuthor) {
        if let index = recommendedAuthors.firstIndex(where: { $0.id == author.id }) {
            recommendedAuthors[index].isFollowing.toggle()
        }
    }
    
    func fetchMorePosts() {
        // TODO: Implement API call to fetch more posts
    }
    
    func fetchMoreRecommendedAuthors() {
        // TODO: Implement API call to fetch more recommended authors
    }
} 
