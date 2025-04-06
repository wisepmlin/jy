//
//  AuthorAvatarView.swift
//  jy
//
//  Created by 林晓彬 on 2025/2/16.
//
import SwiftUI

// MARK: - Supporting Views
struct AuthorAvatarView: View {
    let avatar: String
    @Environment(\.theme) private var theme
    
    var body: some View {
        KFImage(URL(string: "https://img0.baidu.com/it/u=3033927961,683661730&fm=253&fmt=auto&app=120&f=JPEG?w=800&h=800"))
            .resizable()
            .cacheOriginalImage()
            .memoryCacheExpiration(.days(14))
            .diskCacheExpiration(.days(60))
            .cancelOnDisappear(true)
            .loadDiskFileSynchronously()
            .setProcessor(DownsamplingImageProcessor(size: CGSize(width: theme.articleDetail.avatarSize*2, height: theme.articleDetail.avatarSize*2)))
            .frame(width: theme.articleDetail.avatarSize, height: theme.articleDetail.avatarSize)
            .clipShape(Circle())
    }
}
