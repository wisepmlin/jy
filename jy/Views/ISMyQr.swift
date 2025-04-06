//
//  ISMyQr.swift
//  jy
//
//  Created by 林晓彬 on 2025/2/19.
//
import SwiftUI

struct ISMyQr: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.theme) private var theme
    @Binding var isQr: Bool
    @Binding var organization: String
    let userName: String
    let width = UIScreen.main.bounds.width - 64
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 0) {
                    LazyVStack(spacing: 0) {
                        ProfileCard(
                            organization: organization,
                            userName: userName,
                            width: width
                        )
                        
                        QRCodeCard(width: width)
                    }
                    .background(theme.background)
                    .cornerRadius(theme.defaultCornerRadius)
                    .padding(32)
                    HStack(spacing: 24) {
                        // 分享到微信按钮
                        Button(action: {
                            // TODO: 实现分享到微信功能
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundColor(theme.jyxqPrimary)
                                Text("微信")
                                    .themeFont(theme.fonts.small)
                                    .foregroundColor(theme.primaryText)
                            }
                        }
                        Spacer()
                        // 保存到相册按钮
                        Button(action: {
                            // TODO: 实现保存到相册功能
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.down")
                                    .foregroundColor(theme.jyxqPrimary)
                                Text("相册")
                                    .themeFont(theme.fonts.small)
                                    .foregroundColor(theme.primaryText)
                            }
                        }
                        Spacer()
                        // 发送邮件按钮
                        Button(action: {
                            // TODO: 实现发送邮件功能
                        }) {
                            HStack {
                                Image(systemName: "envelope")
                                    .foregroundColor(theme.jyxqPrimary)
                                Text("邮件")
                                    .themeFont(theme.fonts.small)
                                    .foregroundColor(theme.primaryText)
                            }
                        }
                    }
                    .padding(.horizontal, 52)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("我的名片")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    CloseButton(isQr: $isQr)
                }
            }
            .background(theme.gray6Background)
            .safeAreaInset(edge: .bottom) {
                Button(action: {
                    
                }, label: {
                    Text("名片美化")
                        .themeFont(theme.fonts.small)
                        .foregroundColor(theme.jyxqPrimary)
                })
            }
        }
    }
}

// MARK: - 子视图
private struct ProfileCard: View {
    @Environment(\.theme) private var theme
    let organization: String
    let userName: String
    let width: CGFloat
    
    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 8) {
                Text(organization)
                    .themeFont(theme.fonts.small.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(theme.primaryText)
                    .opacity(0.6)
                Text(userName)
                    .themeFont(theme.fonts.title1.bold())
                    .foregroundColor(theme.primaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            Spacer()
            ProfileImage()
        }
        .padding(.top, 100)
        .overlay(alignment: .topLeading) {
            HStack {
                MyIcon()
                    .fill(theme.primaryText)
                    .frame(width: 14, height: 14)
                Text("金鹰星球")
                    .customFont(fontSize: 12)
                    .baselineOffset(-1)
                    .foregroundColor(theme.primaryText)
            }
        }
        .padding(16)
        .background {
            KFImage(URL(string: "https://www.2008php.com/2018_Website_appreciate/2018-05-17/201805170956333XjBi.jpg"))
                .resizable()
                .placeholder {
                    ProgressView()
                }
                .fade(duration: 0.2)
                .aspectRatio(contentMode: .fill)
                .cornerRadius(theme.defaultCornerRadius)
                .blendMode(.hardLight)
        }
        .cornerRadius(theme.defaultCornerRadius)
    }
}

private struct ProfileImage: View {
    @Environment(\.theme) private var theme
    
    var body: some View {
        KFImage(URL(string: "https://iknow-pic.cdn.bcebos.com/fcfaaf51f3deb48f8332e543e21f3a292cf578d7"))
            .resizable()
            .placeholder {
                ProgressView()
            }
            .fade(duration: 0.2)
            .aspectRatio(contentMode: .fill)
            .frame(width: 64, height: 64)
            .cornerRadius(theme.defaultCornerRadius)
    }
}

private struct QRCodeCard: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.theme) private var theme
    let width: CGFloat
    
    var body: some View {
        ZStack {
            Image("qr")
                .resizable()
                .frame(width: 200, height: 200)
                .cornerRadius(theme.defaultCornerRadius)
                .opacity(colorScheme == .dark ? 0.75 : 1)
        }
        .frame(width: width, height: width)
        .background(theme.background)
        .cornerRadius(theme.defaultCornerRadius)
    }
}

private struct CloseButton: View {
    @Environment(\.theme) private var theme
    @Binding var isQr: Bool
    
    var body: some View {
        Button(action: {
            isQr.toggle()
        }, label: {
            Image(systemName: "chevron.down")
                .foregroundColor(theme.primaryText)
        })
    }
}
