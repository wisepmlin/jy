//
//  MarkupEditorView.swift
//  MarkupEditor
//
//  Created by Steven Harris on 2/28/21.
//  Copyright © 2021 Steven Harris. All rights reserved.
//

import SwiftUI
import WebKit

/// MarkupEditorView是一个SwiftUI视图，包含一个MarkupWKWebView和（可选的）MarkupToolbar。
/// MarkupWKWebView被包含在MarkupWKWebViewRepresentable中以供SwiftUI使用。
///
/// 可以使用MarkupEditor.toolbarLocation单独指定MarkupToolbar的位置。默认情况下，MarkupEditorView在所有设备的顶部都有一个工具栏，
/// 并在触摸设备上显示键盘时在inputAccessoryView中显示撤销/重做按钮。
/// 如果在应用程序中有多个MarkupWKWebView，则应该只有一个MarkupToolbar。在这种情况下，
/// 你应该将MarkupEditor.toolbarLocation设置为.none，然后直接使用MarkupToolbar SwiftUI视图。
///
/// 通常，我们不希望WebKit的抽象泄漏到MarkupEditor世界中。当实例化MarkupEditorView时，
/// 你可以根据需要选择性地指定WKUIDelegate和WKNavigationDelegate，它们将被分配给底层的MarkupWKWebView。
public struct MarkupEditorView: View, MarkupDelegate {
    @Environment(\.theme) private var theme
    // Markup代理对象
    private var markupDelegate: MarkupDelegate?
    // WebKit导航代理
    private var wkNavigationDelegate: WKNavigationDelegate?
    // WebKit UI代理
    private var wkUIDelegate: WKUIDelegate?
    // 用户脚本数组
    private var userScripts: [String]?
    // Markup配置对象
    private var markupConfiguration: MarkupWKWebViewConfiguration?
    // 资源URL
    private var resourcesUrl: URL?
    // 标识符
    private var id: String?
    // HTML绑定
    private var html: Binding<String>?
    // 加载后是否选中
    private var selectAfterLoad: Bool = true
    /// 当没有用户输入时显示的占位符文本
    public var placeholder: String?
    
    public var body: some View {
        VStack(spacing: 0) {
            // 如果工具栏位置在顶部
            if MarkupEditor.toolbarLocation == .top {
                MarkupToolbar(markupDelegate: markupDelegate).makeManaged()
                Divider()
            }
            // 创建WebView表示层
            MarkupWKWebViewRepresentable(markupDelegate: markupDelegate,
                                         wkNavigationDelegate: wkNavigationDelegate,
                                         wkUIDelegate: wkUIDelegate,
                                         userScripts: userScripts,
                                         configuration: markupConfiguration,
                                         html: html,
                                         placeholder: placeholder,
                                         selectAfterLoad: selectAfterLoad,
                                         resourcesUrl: resourcesUrl, id: id)
            // 如果工具栏位置在底部
            if MarkupEditor.toolbarLocation == .bottom {
                Divider()
                MarkupToolbar(markupDelegate: markupDelegate).makeManaged()
            }
        }
        .tint(theme.jyxqPrimary)
    }
    
    // 初始化方法
    public init(
        markupDelegate: MarkupDelegate? = nil,
        wkNavigationDelegate: WKNavigationDelegate? = nil,
        wkUIDelegate: WKUIDelegate? = nil,
        userScripts: [String]? = nil,
        configuration: MarkupWKWebViewConfiguration? = nil,
        html: Binding<String>? = nil,
        placeholder: String? = nil,
        selectAfterLoad: Bool = true,
        resourcesUrl: URL? = nil,
        id: String? = nil) {
            self.markupDelegate = markupDelegate ?? self
            self.wkNavigationDelegate = wkNavigationDelegate
            self.wkUIDelegate = wkUIDelegate
            self.userScripts = userScripts
            self.markupConfiguration = configuration
            self.html = html
            self.selectAfterLoad = selectAfterLoad
            self.resourcesUrl = resourcesUrl
            self.id = id
            self.placeholder = placeholder
        }

}

// 预览提供者结构体
struct MarkupEditorView_Previews: PreviewProvider {
    static var previews: some View {
            MarkupEditorView()
    }
}
