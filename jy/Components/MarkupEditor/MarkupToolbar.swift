//
//  MarkupToolbar.swift
//  MarkupEditor
//
//  Created by Steven Harris on 2/28/21.
//  Copyright © 2021 Steven Harris. All rights reserved.
//

import SwiftUI

/// MarkupToolbar显示当前的选择状态，并对observedWebView持有的selectedWebView进行操作
///
/// MarkupToolbar观察selectionState以使其显示反映当前状态
/// 例如，当selectedWebView为nil时，工具栏被禁用，当selectionState显示
/// 选择在粗体元素内时，粗体(B)按钮处于激活和填充状态
/// MarkupToolbar包含多个其他工具栏，如StyleToolbar和FormatToolbar
/// 它们调用selectedWebView(MarkupWKWebView实例)中的方法
public struct MarkupToolbar: View {
    @Environment(\.theme) private var theme
    // 使用MarkupEditorView或MarkupEditorUIView时创建的工具栏
    public static var managed: MarkupToolbar?   
    // 工具栏样式
    public let toolbarStyle: ToolbarStyle
    // 是否显示键盘按钮
    private let withKeyboardButton: Bool
    // 观察WebView对象
    @ObservedObject private var observedWebView = MarkupEditor.observedWebView
    // 观察选择状态
    @ObservedObject private var selectionState = MarkupEditor.selectionState
    // 观察搜索状态
    @ObservedObject private var searchActive = MarkupEditor.searchActive
    // 工具栏内容配置
    private var contents: ToolbarContents
    // 标记代理
    public var markupDelegate: MarkupDelegate?
    
    public var body: some View {
        ZStack(alignment: .topLeading) {
            HStack(spacing: 0) {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 12, pinnedViews: .sectionHeaders) {
                        Section(content: {
                            HStack {
                                // 左侧工具栏
                                if contents.leftToolbar, let leftToolbar = MarkupEditor.leftToolbar {
                                    leftToolbar
                                }
                                
                                // 插入工具栏
                                if contents.insert {
                                    if contents.leftToolbar || contents.correction { Divider().frame(height: 20) }
                                    InsertToolbar()
                                }
                                // 样式工具栏
                                if contents.style {
                                    if contents.leftToolbar || contents.correction  || contents.insert { Divider().frame(height: 20) }
                                    StyleToolbar()
                                }
                                // 格式工具栏
                                if contents.format {
                                    if contents.leftToolbar || contents.correction  || contents.insert || contents.style { Divider().frame(height: 20) }
                                    FormatToolbar()
                                }
                                // 右侧工具栏
                                if contents.rightToolbar {
                                    if contents.leftToolbar || contents.correction  || contents.insert || contents.style || contents.format { Divider().frame(height: 20) }
                                    MarkupEditor.rightToolbar!
                                }
                            }
                        }, header: {
                            HStack(spacing: 10) {
                                // 校正工具栏
                                if contents.correction {
                                    CorrectionToolbar()
                                        .padding(.leading, 10)
                                    if contents.leftToolbar { Divider() }
                                }
                            }
                            .background(theme.background)
                        })
                    }
                    .environmentObject(toolbarStyle)
                    .padding(EdgeInsets(top: 2, leading: 0, bottom: 2, trailing: 12))
                    // 当没有选中WebView或选择状态无效或搜索激活时禁用工具栏
                    .disabled(observedWebView.selectedWebView == nil || !selectionState.isValid || searchActive.value)
                }
                .onTapGesture {
                    
                }    // 使ScrollView内的按钮响应
                // 显示键盘按钮
                if withKeyboardButton {
                    Divider()
                    Button(action: {
                        _ = MarkupEditor.selectedWebView?.resignFirstResponder()
                    }, label: {
                        Image(systemName: "keyboard.chevron.compact.down")
                            .themeFont(theme.fonts.title3)
                            .foregroundColor(theme.subText2)
                            .frame(width: 44, height: 44)
                    })
                }
            }
        }
        // 因为工具栏中的图标大小基于字体，我们需要限制其动态类型大小
        // 否则在很大的尺寸下会变得难以辨认
        .dynamicTypeSize(.small ... .xLarge)
        .frame(height: MarkupEditor.toolbarStyle.height())
        .background(theme.background)
        .zIndex(999)
    }
    
    // 初始化方法
    public init(_ style: ToolbarStyle.Style? = nil, contents: ToolbarContents? = nil, markupDelegate: MarkupDelegate? = nil, withKeyboardButton: Bool = false) {
        let toolbarStyle = style == nil ? MarkupEditor.toolbarStyle : ToolbarStyle(style!)
        self.toolbarStyle = toolbarStyle
        let toolbarContents = contents == nil ? MarkupEditor.toolbarContents : contents!
        self.contents = toolbarContents
        self.withKeyboardButton = withKeyboardButton
        self.markupDelegate = markupDelegate
    }
    
    // 将工具栏设置为托管状态
    public func makeManaged() -> MarkupToolbar {
        MarkupToolbar.managed = self
        return self
    }

}

//MARK: Previews

// 预览提供者
struct MarkupToolbar_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack(alignment: .leading) {
            MarkupToolbar(.compact)
            MarkupToolbar(.labeled)
            Spacer()
        }
        .onAppear {
            MarkupEditor.selectedWebView = MarkupWKWebView()
            MarkupEditor.selectionState.valid = true
        }
    }
}
