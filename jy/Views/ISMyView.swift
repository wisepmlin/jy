//
//  ISMyView.swift
//  jy
//
//  Created by 林晓彬 on 2025/2/19.
//
import SwiftUI

struct ISMyView: View {
    @Environment(\.theme) private var theme
    @Binding var isMy: Bool
    @Binding var organization: String
    let userName: String
    
    // MARK: - 子视图
    private var userInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Text(organization)
                    .themeFont(theme.fonts.small.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(theme.subText)
                Spacer()
                KFImage(URL(string: "https://iknow-pic.cdn.bcebos.com/fcfaaf51f3deb48f8332e543e21f3a292cf578d7"))
                    .resizable()
                    .placeholder {
                        ProgressView()
                    }
                    .fade(duration: 0.35)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 64, height: 64)
                    .cornerRadius(theme.defaultCornerRadius)
            }
            .padding(.bottom, 52)
            Spacer()
            Text(userName)
                .themeFont(theme.fonts.title2.bold())
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Divider().opacity(0.7)
            userTags
        }
        .padding(EdgeInsets(top: 16, leading: 16, bottom: 12, trailing: 16))
        .background(theme.background)
        .cornerRadius(theme.defaultCornerRadius)
    }
    
    private var userTags: some View {
        HStack(spacing: 8) {
            Text("Lv.5")
                .themeFont(theme.fonts.caption)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(theme.jyxqPrimary)
                .cornerRadius(12)
            
            Text("资深专家")
                .themeFont(theme.fonts.caption)
                .foregroundColor(theme.jyxqPrimary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(theme.jyxqPrimary, lineWidth: 1)
                )
            
            Text("合伙人")
                .themeFont(theme.fonts.caption)
                .foregroundColor(theme.subText)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(theme.subText, lineWidth: 1)
                )
        }
        .padding(.vertical, 8)
    }
    
    private var gridButtons: some View {
        Grid(horizontalSpacing: 8, verticalSpacing: 8) {
            GridRow {
                resourceButton(image: "star.fill", title: "潜在客户", subText: "客户池：233人")
                resourceButton(image: "creditcard.fill", title: "积分", subText: "余额币：246,234")
            }
            GridRow {
                resourceButton(image: "person.fill", title: "激活客户", subText: "已开发：92人")
                resourceButton(image: "doc.text.fill", title: "进件", subText: "状态：未进件")
            }
        }
    }
    
    private func resourceButton(image: String, title: String, subText: String) -> some View {
        Button(action: {}) {
            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 8) {
                    Image(systemName: image)
                        .themeFont(theme.fonts.small)
                        .foregroundColor(theme.primaryText)
                        .frame(width: 24, height: 24)
                        .background(theme.jyxqPrimary)
                        .cornerRadius(theme.minCornerRadius)
                    Text(title)
                        .themeFont(theme.fonts.title3)
                        .foregroundColor(theme.primaryText)
                }
                Text(subText)
                    .themeFont(theme.fonts.small)
                    .foregroundColor(theme.subText)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(theme.background)
            .cornerRadius(theme.defaultCornerRadius)
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack {
                    userInfoSection
                    gridButtons
                }
            }
            .contentMargins(8, for: .scrollContent)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        isMy.toggle()
                    }, label: {
                        Image(systemName: "chevron.down")
                            .foregroundColor(theme.primaryText)
                    })
                }
            }
            .background(theme.gray6Background)
        }
    }
}
