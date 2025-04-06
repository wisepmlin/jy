import SwiftUI
import MonkeyKing

struct ShareOverlayView: View {
    @Environment(\.theme) private var theme
    @Binding var showShareMenu: Bool
    @Binding var ideaText: String
    
    let article: ArticleContent
    let friends: [Friend]
    
    var body: some View {
        shareContent
            .ignoresSafeArea()
    }
    
    private var shareContent: some View {
        ScrollView {
            VStack(spacing: 12) {
                HStack {
                    Text("分享到")
                        .themeFont(theme.fonts.title3.bold())
                        .foregroundColor(theme.primaryText)
                    Spacer()
                    Button(action: {
                        showShareMenu = false
                    }, label: {
                        Image(systemName: "xmark")
                            .themeFont(theme.fonts.body)
                            .foregroundColor(theme.primaryText)
                    })
                }
                .padding(EdgeInsets(top: 16, leading: 16, bottom: 0, trailing: 16))
                
                shareList.frame(height: ShareButtonStyle.default.size + 24)
                shareFriendList.frame(height: ShareButtonStyle.default.size + 24)
                
                VStack {
                    HStack {
                        Text("转发到金圈")
                            .themeFont(theme.fonts.small)
                            .foregroundColor(theme.primaryText)
                        Spacer()
                        Text("立即转发")
                            .themeFont(theme.fonts.small)
                            .foregroundColor(theme.jyxqPrimary)
                    }
                    
                    TextField("说说你的想法", text: $ideaText)
                        .themeFont(theme.fonts.small.bold())
                        .foregroundColor(theme.subText)
                    
                    HStack {
                        KFImage(URL(string: article.imageUrl))
                            .resizable()
                            .placeholder {
                                ProgressView()
                            }
                            .fade(duration: 0.35)
                            .scaledToFill()
                            .frame(width: 24, height: 24)
                            .cornerRadius(12)
                        
                        Text(article.title)
                            .themeFont(theme.fonts.body)
                            .foregroundColor(theme.subText2)
                            .lineLimit(1)
                        
                        Spacer()
                    }
                    .padding(8)
                    .background {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(theme.background.opacity(0.7))
                    }
                }
                .padding(theme.defaultCornerRadius)
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.bar)
                }
                .padding(.horizontal, 16)
                
                ArticlePosterGenerator(article: article)
            }
        }
    }
    
    private var shareFriendList: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 24) {
                ForEach(friends) { friend in
                    shareHumanButton(title: friend.name, image: friend.avatar)
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    private var shareList: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 24) {
                ForEach(ShareOverlayView.platforms) { platform in
                    shareButton(
                        title: platform.title,
                        image: platform.image,
                        action: {
                            switch platform.type {
                            case "share_image":
                                // 分享图片
                                break
                            case "wechat_friend":
                                // 分享到微信好友
                                print("分享到微信好友")
                                shareInfo(MonkeyKing.Message.weChat(.session(info: ShareOverlayView.infoText)))
                                break
                            case "wechat_moments":
                                // 分享到朋友圈
                                shareInfo(MonkeyKing.Message.weChat(.timeline(info: ShareOverlayView.infoText)))
                                break
                            case "wechat_favorite":
                                // 分享到微信收藏
                                shareInfo(MonkeyKing.Message.weChat(.favorite(info: ShareOverlayView.infoText)))
                                break
                            case "qq_friend":
                                // 分享到QQ好友
                                shareInfo(MonkeyKing.Message.qq(.friends(info: ShareOverlayView.infoText)))
                                break
                            case "qq_zone":
                                // 分享到QQ空间
                                shareInfo(MonkeyKing.Message.qq(.zone(info: ShareOverlayView.infoText)))
                                break
                            case "qq_dataline":
                                // 分享到QQ空间
                                shareInfo(MonkeyKing.Message.qq(.dataline(info: ShareOverlayView.infoText)))
                                break
                            case "qq_favorites":
                                // 分享到QQ空间
                                shareInfo(MonkeyKing.Message.qq(.favorites(info: ShareOverlayView.infoText)))
                                break
                            case "weibo":
                                // 分享到微博
                                
                                break
                            case "system":
                                // 系统分享
                                systemShare()
                                break
                            default:
                                break
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 16)
        }
        .trackLifecycle(onAppear: {
            apperAccount()
        }, onDisappear: {
            
        })
    }
    
    private func shareButton(
        title: String,
        image: String,
        style: ShareButtonStyle = .default,
        action: (() -> Void)? = nil
    ) -> some View {
        Button(action: { action?() }) {
            VStack(spacing: 8) {
                Image(image)
                    .frame(width: style.size, height: style.size)
                    .background(.bar)
                    .cornerRadius(style.size / 2)
                
                Text(title)
                    .themeFont(theme.fonts.caption)
                    .foregroundColor(style.titleColor ?? theme.primaryText)
            }
            .frame(height: style.size + 24)
        }
        .buttonStyle(.plain)
    }
    
    private func shareHumanButton(
        title: String,
        image: String,
        style: ShareButtonStyle = .default,
        action: (() -> Void)? = nil
    ) -> some View {
        Button(action: { action?() }) {
            VStack(spacing: 8) {
                KFImage(URL(string: image))
                    .resizable()
                    .placeholder {
                        ProgressView()
                    }
                    .fade(duration: 0.2)
                    .scaledToFit()
                    .cornerRadius(style.size / 2)
                    .padding(theme.minCornerRadius)
                    .frame(width: style.size, height: style.size)
                    .background(.bar)
                    .cornerRadius(style.size / 2)
                
                Text(title)
                    .themeFont(theme.fonts.caption)
                    .foregroundColor(style.titleColor ?? theme.primaryText)
            }
            .frame(height: style.size + 24)
        }
        .buttonStyle(.plain)
    }
}

private struct ShareButtonStyle {
    var backgroundColor: Color = .red
    var size: CGFloat = 52
    var cornerRadius: CGFloat = 26
    var iconColor: Color = .white
    var titleColor: Color?
    
    static let `default` = ShareButtonStyle()
}

extension ShareOverlayView {
    // 启动微信小程序
    func launchMiniApp() {
        MonkeyKing.launch(.weChat(.miniApp(username: Configs.WeChat.miniAppID, path: nil, type: .test))) { result in
            print("result: \(result)")
        }
    }
    
    // 实现微信的OAuth授权功能
    func oauthWeChat() {
        MonkeyKing.oauth(for: .weChat) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let dictionary):
                    fetchUserInfo(dictionary)
                case .failure(let error):
                    print("error \(String(describing: error))")
                }
            }
        }
    }
    
    // 获取用户信息
    func oauthWithoutAppKey() {
        // 不应该在这里注册账号
        let accountWithoutAppKey = MonkeyKing.Account.weChat(
            appID: Configs.WeChat.appID,
            appKey: nil,
            miniAppID: nil,
            universalLink: Configs.WeChat.universalLink)
        MonkeyKing.registerAccount(accountWithoutAppKey)

        // 使用微信OAuth授权
        MonkeyKing.oauth(for: .weChat) { result in
            // 如果不想在客户端保存微信AppKey,可以使用此代码进行OAuth授权
            switch result {
            case .success(let dictionary):
                print("dictionary \(String(describing: dictionary))")
            case .failure(let error):
                print("error \(String(describing: error))")
            }
        }
    }

    /// 获取微信授权码
    /// 通过授权码可以获取用户的访问令牌和其他信息
    func oauthForCode() {
        MonkeyKing.weChatOAuthForCode { result in
            switch result {
            case .success(let code):
                fetchWeChatOAuthInfoByCode(code: code)
            case .failure(let error):
                print("error \(String(describing: error))")
            }
        }
    }
    
    /// 微信支付方法
    func pay() {
        // 创建支付请求
        let request = URLRequest(url: URL(string: "http://www.example.com/pay.php?payType=weixin")!)
        
        // 发起网络请求获取支付参数
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                // 处理网络请求错误
                print(error)
            } else {
                // 解析返回数据
                guard let data = data else { return }
                guard let urlString = String(data: data, encoding: .utf8) else { return }
                guard let url = URL(string: urlString) else { return }

                // 调用微信支付SDK
                MonkeyKing.deliver(.weChat(url: url)) { result in
                    print("result:", result)
                }
            }
        }
        task.resume()
    }
    
    /// 系统分享功能
    /// - 注册微信账号
    /// - 创建分享信息
    /// - 配置微信会话和朋友圈分享活动
private func systemShare() {
    MonkeyKing.registerAccount(
        .weChat(
            appID: Configs.WeChat.appID,
            appKey: Configs.WeChat.appKey,
            miniAppID: nil,
            universalLink: Configs.WeChat.universalLink
        )
    )
    
    let shareURL = URL(string: "http://www.apple.com/cn/iphone/compare/")!
    let info = MonkeyKing.Info(
        title: "iPhone Compare",
        description: "iPhone 机型比较", 
        thumbnail: UIImage(named: "rabbit"),
        media: .url(shareURL)
    )
    
    let sessionMessage = MonkeyKing.Message.weChat(.session(info: info))
    let weChatSessionActivity = AnyActivity(
        type: UIActivity.ActivityType(rawValue: "com.nixWork.China.WeChat.Session"),
        title: NSLocalizedString("WeChat Session", comment: ""),
        image: UIImage(named: "wechat_session") ?? UIImage(), // 使用空图片作为默认值避免强制解包
        message: sessionMessage,
        completionHandler: { success in
            print("Session success: \(success)")
        }
    )
    
    let timelineMessage = MonkeyKing.Message.weChat(.timeline(info: info))
    let weChatTimelineActivity = AnyActivity(
        type: UIActivity.ActivityType(rawValue: "com.nixWork.China.WeChat.Timeline"),
        title: NSLocalizedString("WeChat Timeline", comment: ""),
        image: UIImage(named: "wechat_timeline") ?? UIImage(), // 使用空图片作为默认值避免强制解包
        message: timelineMessage,
        completionHandler: { success in
            print("Timeline success: \(success)")
        }
    )
    
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
       let rootViewController = windowScene.windows.first?.rootViewController {
        let activityViewController = UIActivityViewController(
            activityItems: [shareURL],
            applicationActivities: [weChatSessionActivity, weChatTimelineActivity]
        )
        
        // 在 iPad 上需要设置 popoverPresentationController
        if UIDevice.current.userInterfaceIdiom == .pad {
            activityViewController.popoverPresentationController?.sourceView = rootViewController.view
            activityViewController.popoverPresentationController?.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
            activityViewController.popoverPresentationController?.permittedArrowDirections = []
        }
        
        rootViewController.present(activityViewController, animated: true)
    }
}
    
    /// QQ OAuth授权登录
    /// - 支持的权限列表:
    /// - get_user_info: 获取用户信息
    /// - get_simple_userinfo: 获取简单用户信息
    /// - add_album: 添加相册
    /// - add_idol: 添加偶像
    /// - add_one_blog: 发表说说
    /// - add_pic_t: 发表带图片的说说
    /// - add_share: 发表分享
    /// - add_topic: 发表话题
    /// - check_page_fans: 验证是否为粉丝
    /// - del_idol: 删除偶像
    /// - del_t: 删除说说
    /// - get_fanslist: 获取粉丝列表
    /// - get_idollist: 获取偶像列表
    /// - get_info: 获取个人信息
    /// - get_other_info: 获取其他用户信息
    /// - get_repost_list: 获取转发列表
    /// - list_album: 获取相册列表
    /// - upload_pic: 上传图片
    /// - get_vip_info: 获取会员信息
    /// - get_vip_rich_info: 获取会员详细信息
    /// - get_intimate_friends_weibo: 获取密友说说
    /// - match_nick_tips_weibo: 获取昵称推荐
    func OAuth() {
        // "get_user_info,get_simple_userinfo,add_album,add_idol,add_one_blog,add_pic_t,add_share,add_topic,check_page_fans,del_idol,del_t,get_fanslist,get_idollist,get_info,get_other_info,get_repost_list,list_album,upload_pic,get_vip_info,get_vip_rich_info,get_intimate_friends_weibo,match_nick_tips_weibo"
        
        MonkeyKing.oauth(for: .qq, scope: "get_user_info") { result in
            switch result {
            case .success(let info):
                guard
                    let unwrappedInfo = info,
                    let token = unwrappedInfo["access_token"] as? String,
                    let openID = unwrappedInfo["openid"] as? String else {
                    return
                }
                let query = "get_user_info"
                let userInfoAPI = "https://graph.qq.com/user/\(query)"
                let parameters = [
                    "openid": openID,
                    "access_token": token,
                    "oauth_consumer_key": Configs.QQ.appID,
                ]
                // fetch UserInfo by userInfoAPI
                SimpleNetworking.sharedInstance.request(userInfoAPI, method: .get, parameters: parameters) { userInfo, _, _ in
                    print("userInfo \(String(describing: userInfo))")
                }
            case .failure:
                break
            }
            // More API
            // http://wiki.open.qq.com/wiki/website/API%E5%88%97%E8%A1%A8
        }
    }
    
    static let platforms: [ShareType] = [
        ShareType(type: "share_image", title: "分享图", image: "si"),
        ShareType(type: "wechat_friend", title: "微信好友", image: "wc"),
        ShareType(type: "wechat_moments", title: "朋友圈", image: "wc_p"),
        ShareType(type: "wechat_favorite", title: "微信收藏", image: "wc_sc"),
        ShareType(type: "qq_friend", title: "QQ好友", image: "qq"),
        ShareType(type: "qq_zone", title: "QQ空间", image: "wc_sc"),
        ShareType(type: "qq_dataline", title: "QQ文件", image: "wc_sc"),
        ShareType(type: "qq_favorites", title: "QQ收藏", image: "wc_sc"),
        ShareType(type: "weibo", title: "微博", image: "wb"),
        ShareType(type: "system", title: "系统", image: "sy"),
    ]
    
    // 纯文本分享信息
    static let infoText = MonkeyKing.Info(
        title: "Text, \(UUID().uuidString)",
        description: nil,
        thumbnail: nil,
        media: nil
    )
    
    // URL链接分享信息
    static let infoUrl = MonkeyKing.Info(
        title: "URL, \(UUID().uuidString)",
        description: "Description URL, \(UUID().uuidString)", 
        thumbnail: UIImage(named: "rabbit"),
        media: .url(URL(string: "http://soyep.com")!)
    )
    
    // 图片分享信息
    static let infoImage = MonkeyKing.Info(
        title: nil,
        description: nil,
        thumbnail: UIImage(named: "rabbit"),
        media: .image(UIImage(named: "rabbit")!)
    )
    
    // 视频分享信息
    static let infoVideo = MonkeyKing.Info(
        title: "Video, \(UUID().uuidString)",
        description: "Description Video, \(UUID().uuidString)",
        thumbnail: UIImage(named: "rabbit"),
        media: .video(URL(string: "http://v.youku.com/v_show/id_XNTUxNDY1NDY4.html")!)
    )
    
    // 小程序分享信息
    static let infoApp = MonkeyKing.Info(
        title: "Mini App, \(UUID().uuidString)",
        description: nil,
        thumbnail: UIImage(named: "rabbit"),
        media: .miniApp(
            url: URL(string: "http://soyep.com")!,
            path: "",
            withShareTicket: true,
            type: .release,
            userName: nil
        )
    )

    /// 分享文件
    /// - 从Bundle中读取gif文件并分享到微信会话
    func shareFile() {
        do {
            let fileData = try Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "gif", ofType: "gif")!))
            let info = MonkeyKing.Info(
                title: "File, \(UUID().uuidString)", 
                description: "Description File, \(UUID().uuidString)",
                thumbnail: nil,
                media: .file(fileData, fileExt: "gif")
            )
            shareInfo(MonkeyKing.Message.weChat(.session(info: info)))
        } catch {
            print(error.localizedDescription)
        }
    }

    /// 分享信息
    /// - Parameter message: MonkeyKing消息对象
    func shareInfo(_ message: MonkeyKing.Message?) {
        if let message {
            MonkeyKing.deliver(message) { result in
                print("result: \(result)")
            }
        }
    }
    
    // 微信账号配置
    static let weChatAccount = MonkeyKing.Account.weChat(appID: Configs.WeChat.appID, appKey: Configs.WeChat.appKey, miniAppID: Configs.WeChat.miniAppID, universalLink: Configs.WeChat.universalLink)
    
    // 微博账号配置
    static let weiboAccount = MonkeyKing.Account.weibo(appID: Configs.Weibo.appID, appKey: Configs.Weibo.appKey, redirectURL: Configs.Weibo.redirectURL, universalLink: Configs.Weibo.universalLink)
    
    // QQ账号配置
    static let qqAccount = MonkeyKing.Account.qq(appID: Configs.QQ.appID, universalLink: Configs.QQ.universalLink)
    
    // Pocket账号配置
    static let pocketAccount = MonkeyKing.Account.pocket(appID: Configs.Pocket.appID)
    
    // 注册社交平台账号
    func apperAccount() {
        MonkeyKing.registerAccount(ShareOverlayView.weChatAccount)
        MonkeyKing.registerAccount(ShareOverlayView.weiboAccount)
        MonkeyKing.registerAccount(ShareOverlayView.qqAccount)
        MonkeyKing.registerAccount(ShareOverlayView.pocketAccount)
    }
}

extension ShareOverlayView {

    /// 获取微信用户信息
    /// - Parameter oauthInfo: OAuth认证信息字典
    private func fetchUserInfo(_ oauthInfo: [String: Any]?) {
        // 从OAuth信息中提取必要参数
        guard
            let token = oauthInfo?["access_token"] as? String,
            let openID = oauthInfo?["openid"] as? String,
            let refreshToken = oauthInfo?["refresh_token"] as? String,
            let expiresIn = oauthInfo?["expires_in"] as? Int else {
            return
        }
        
        // 微信用户信息接口地址
        let userInfoAPI = "https://api.weixin.qq.com/sns/userinfo"
        
        // 请求参数
        let parameters = [
            "openid": openID,
            "access_token": token,
        ]
        
        // fetch UserInfo by userInfoAPI
        SimpleNetworking.sharedInstance.request(userInfoAPI, method: .get, parameters: parameters, completionHandler: { userInfo, _, _ in

            guard var userInfo = userInfo else {
                return
            }

            // 将OAuth信息添加到用户信息中
            userInfo["access_token"] = token
            userInfo["openid"] = openID
            userInfo["refresh_token"] = refreshToken
            userInfo["expires_in"] = expiresIn

            print("userInfo \(userInfo)")
        })
        // More API
        // http://mp.weixin.qq.com/wiki/home/index.html
    }

    /// 通过授权码获取微信OAuth信息
    /// - Parameter code: 授权码
    private func fetchWeChatOAuthInfoByCode(code: String) {
        // 从配置中获取应用ID和密钥
        let appID = Configs.WeChat.appID // fetch appID from server
        let appKey = Configs.WeChat.appKey // fetch appKey from server

        // 构建访问令牌接口URL
        var accessTokenAPI = "https://api.weixin.qq.com/sns/oauth2/access_token?"
        accessTokenAPI += "appid=" + appID
        accessTokenAPI += "&secret=" + appKey
        accessTokenAPI += "&code=" + code + "&grant_type=authorization_code"

        // OAuth
        SimpleNetworking.sharedInstance.request(accessTokenAPI, method: .get) { OAuthJSON, _, _ in
            print("OAuthJSON \(String(describing: OAuthJSON))")
        }
    }
}
