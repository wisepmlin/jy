//
//  MarkupDelegate.swift
//  MarkupEditor
//
//  Created by Steven Harris on 4/16/21.
//  Copyright © 2021 Steven Harris. All rights reserved.
//

import UIKit
import OSLog

/// MarkupDelegate 定义了随着 MarkupWKWebView 状态变化而调用的应用程序特定功能。
///
/// MarkupDelegate 方法提供了默认实现，因此所有方法都是可选的。
/// 大多数默认方法不执行任何操作，尽管有些方法会处理简单的行为。
/// 在您的 MarkupDelegate 中实现这些方法来自定义应用程序的行为。
@MainActor
public protocol MarkupDelegate {
    
    /// 当在视图的可编辑编辑器元素中接收到输入时调用（例如，输入文字）
    func markupInput(_ view: MarkupWKWebView)
    
    /// 当在视图中除"editor"之外的可编辑元素中接收到输入时调用（例如，输入文字）
    func markupInput(_ view: MarkupWKWebView, divId: String)
    
    /// 当显示的文本的内部高度发生变化时调用
    /// 可用于更新UI
    func markup(_ view: MarkupWKWebView, heightDidChange height: Int)
    
    /// 当MarkupWKWebView开始编辑时调用
    func markupTookFocus(_ view: MarkupWKWebView)
    
    /// 当MarkupWKWebView停止编辑或失去焦点时调用
    func markupLostFocus(_ view: MarkupWKWebView)
    
    /// 在加载初始HTML之前调用，允许执行任何预加载活动
    ///
    /// 当进行此调用时，根文件、userCSS和userScripts已经加载完成
    func markupWillLoad(_ view: MarkupWKWebView)
    
    /// 当MarkupWKWebView准备好接收输入时调用
    /// 具体来说，是在内部WKWebView首次加载且contentHtml设置完成时调用
    ///
    /// 默认行为是设置selectedWebView并执行处理程序
    func markupDidLoad(_ view: MarkupWKWebView, handler: (()->Void)?)
    
    /// 当JS中的回调调用自定义操作时调用
    /// 默认情况下，除非通过添加的自定义JS调用，否则不使用此方法
    func markup(_ view: MarkupWKWebView, handle action: String)
    
    /// 当webView中的选择发生变化时调用
    func markupSelectionChanged(_ view: MarkupWKWebView)
    
    /// 当用户点击视图时调用
    /// 用于区分点击链接、图像、表格与选择变化
    func markupClicked(_ view: MarkupWKWebView)
    
    /// 当视图上的操作将内容推送到由Undoer管理的撤销栈时调用
    func markupUndoSet(_ view: MarkupWKWebView)
    
    /// 当用户选择链接时采取行动
    func markupLinkSelected(_ view: MarkupWKWebView?, selectionState: SelectionState)
    
    /// 当用户选择图像时采取行动
    func markupImageSelected(_ view: MarkupWKWebView?, selectionState: SelectionState)
    
    /// 当用户选择表格时采取行动
    func markupTableSelected(_ view: MarkupWKWebView?, selectionState: SelectionState)
    
    /// 当MarkupWKWebView正在设置时采取行动
    ///
    /// 在web视图setupForEditing之前调用
    func markupSetup(_ view: MarkupWKWebView?)
    
    /// 当不再需要MarkupWKWebView时采取行动
    func markupTeardown(_ view: MarkupWKWebView?)
    
    /// 在url处添加了图像/资源。url是从文档中的图像/资源src参数派生的
    func markupImageAdded(url: URL)
    
    /// 在url处添加了图像/资源。url是从指定divId（默认为"editor"）的文档中的图像/资源src参数派生的
    func markupImageAdded(_ view: MarkupWKWebView?, url: URL, divId: String)
    
    /// 文档中删除了图像/资源。该图像/资源具有指定的url，该url是从文档中的src参数派生的
    func markupImageDeleted(url: URL)
    
    /// 文档中删除了图像/资源。该图像/资源具有指定的url，该url是从指定divId（默认为"editor"）的文档中的src参数派生的
    func markupImageDeleted(_ view: MarkupWKWebView?, url: URL, divId: String)
    
    /// 已识别要添加到视图中的本地图像
    func markupImageToAdd(_ view: MarkupWKWebView, url: URL)
    
    /// 响应是否可以处理拖放交互
    ///
    /// *注意:* 拖放交互当前已禁用
    ///
    /// 返回 false 意味着 markupDropInteraction(\_, sessionDidUpdate) 和
    /// markupDropInteraction(\_, performDrop) 方法都不会被调用
    ///
    /// 在 SwiftUI 中使用 MarkupEditorView 时,返回 false 以在该视图上使用 .onDrop
    /// 这也是默认行为,所以不实现 markupDropInteraction(\_, canHandle)
    /// 意味着你可以像预期那样使用带有 MarkupEditorView 的 .onDrop
    /// 如果在这里返回 true,.onDrop 将永远不会执行。在这种情况下,你应该重写
    /// markupDropInteraction(\_, sessionDidUpdate) 和 markupDropInteraction(\_, performDrop)
    /// 方法
    func markupDropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool
    
    /// 响应拖放提案
    func markupDropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal
    
    /// 执行拖放操作
    func markupDropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession)
    
    /// JavaScript端发生错误时调用
    func markupError(code: String, message: String, info: String?, alert: Bool)
    
    /// 响应菜单选择或按钮点击时显示链接弹出框
    /// 详见默认实现
    func markupShowLinkPopover(_ view: MarkupWKWebView)
    
    /// 响应菜单选择或按钮点击时显示图片弹出框
    /// 详见默认实现
    func markupShowImagePopover(_ view: MarkupWKWebView)
    
    /// 响应菜单选择或按钮点击时显示表格弹出框
    /// 详见默认实现
    func markupShowTablePopover(_ view: MarkupWKWebView)
    
    /// 添加到视图中的HTML按钮被点击时调用
    /// 返回按钮的id和其矩形位置
    func markupButtonClicked(_ view: MarkupWKWebView, id: String, rect: CGRect)
    
    /// 视图激活"搜索模式",此时Enter/Shift+Enter被解释为向前搜索/向后搜索
    /// 工具栏应该被禁用,因为在搜索模式下不应进行编辑
    func markupActivateSearch(_ view: MarkupWKWebView)
    
    /// 视图停用"搜索模式",此时Enter/Shift+Enter不再被解释为搜索操作
    /// 工具栏应该被重新启用
    func markupDeactivateSearch(_ view: MarkupWKWebView)
    
}

extension MarkupDelegate {
    public func markupInput(_ view: MarkupWKWebView) {}
    public func markupInput(_ view: MarkupWKWebView, divId: String) {}
    public func markup(_ view: MarkupWKWebView, heightDidChange height: Int) {}
    public func markupTookFocus(_ view: MarkupWKWebView) {}
    public func markupLostFocus(_ view: MarkupWKWebView) {}
    
    /// MarkupWKWebView已加载JavaScript和CSS,但编辑器html尚未加载
    public func markupWillLoad(_ view: MarkupWKWebView) {}
    
    /// MarkupWKWebView已加载JavaScript和所有html内容
    ///
    /// 默认情况下让MarkupEditor知道这是selectedWebView。如果有多个
    /// MarkupWKWebViews,你可能需要重写此方法
    public func markupDidLoad(_ view: MarkupWKWebView, handler: (()->Void)?) {
        MarkupEditor.selectedWebView = view
        handler?()
    }
    
    public func markup(_ view: MarkupWKWebView, handle action: String) {}
    public func markupSelectionChanged(_ view: MarkupWKWebView) {}
    
    /// 用户点击了某个内容
    ///
    /// 此默认行为检查selectionState并根据选中的内容调用更具体的方法
    /// 注意图片可以被链接,因此delegate可能收到多个消息
    public func markupClicked(_ view: MarkupWKWebView) {
        view.getSelectionState() { selectionState in
            // 如果选中的是可点击链接,让delegate决定如何处理
            // delegate的默认行为是打开selectionState中的href
            if selectionState.isFollowable {
                self.markupLinkSelected(view, selectionState: selectionState)
            }
            // 如果选中的是图片,让delegate决定如何处理
            if selectionState.isInImage {
                self.markupImageSelected(view, selectionState: selectionState)
            }
            // 如果选中的是表格,让delegate决定如何处理
            if selectionState.isInTable {
                self.markupTableSelected(view, selectionState: selectionState)
            }
        }
    }
    
    /// 一个操作(如加粗或列表输入)将数据推送到Undoer的撤销栈中
    ///
    /// 默认不执行任何操作,但我们在测试中使用它,它可能对Swift端的其他集成有用
    public func markupUndoSet(_ view: MarkupWKWebView) {}
    
    /// 选中了一个链接,selectionState包含相关信息
    ///
    /// 此函数被UIKit和SwiftUI应用程序使用,但为简单起见我们只使用UIApplication.shared
    /// 这确实强制我们导入UIKit
    public func markupLinkSelected(_ view: MarkupWKWebView?, selectionState: SelectionState) {
        // 如果没有提供处理程序,默认操作是打开href处的url(如果可以打开)
        guard
            let href = selectionState.href,
            let url = URL(string: href),
            UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }
    
    /// 选中了一个图片,selectionState包含相关信息
    public func markupImageSelected(_ view: MarkupWKWebView?, selectionState: SelectionState) {}
    
    /// 选中了一个表格,selectionState包含相关信息
    public func markupTableSelected(_ view: MarkupWKWebView?, selectionState: SelectionState) {}

    /// 默认使用MarkupWKWebView的setup方法填充缓存目录资源
    ///
    /// 如果需要自定义行为可以重写。例如,你可能想要刷新缓存目录
    /// 的资源,而不是每次都完全重新填充(这是view.setup()的行为)
    public func markupSetup(_ view: MarkupWKWebView?) {
        view?.setup()
    }
    
    /// 默认使用MarkupWKWebView的teardown方法删除整个缓存目录
    ///
    /// 如果需要自定义行为可以重写。例如,你可能想要将缓存目录
    /// 作为缓存保留而不是每次都清理。如果这样,你也应该实现
    /// markupSetup
    public func markupTeardown(_ view: MarkupWKWebView?) {
        view?.teardown()
    }
    
    /// 在添加图片后执行操作(如果需要);默认不执行任何操作
    ///
    /// 例如,你可能想要将图片复制到其他位置,因为传入的url
    /// 将位于缓存中
    public func markupImageAdded(url: URL) {}

    /// 在view的divId中添加图片后执行操作(如果需要);默认不执行任何操作
    ///
    /// 此方法仅在使用"editor"div以外的可编辑div时调用
    ///
    /// 例如,你可能想要将图片复制到其他位置,因为传入的url
    /// 将位于缓存中,可以从view.baseUrl找到
    public func markupImageAdded(_ view: MarkupWKWebView?, url: URL, divId: String) {}
    
    /// 在删除图片后执行操作(如果需要);默认不执行任何操作
    ///
    /// 例如,你可能想要删除你放在其他位置的图片副本。如果这样,你
    /// 需要使用相同的名称(默认为UUID),以便容易找到,或者你需要维护
    /// MarkupEditor使用的url和你保存的本地副本之间的映射
    ///
    /// 无论url表示本地图片还是远程图片,通知都会到达。你的代码
    /// 需要区分这种差异
    /// 
    /// 注意默认情况下图片会保留在缓存中。这对支持撤销很重要!
    public func markupImageDeleted(url: URL) {}
    
    /// 在view的divId中删除图片后执行操作(如果需要);默认不执行任何操作
    ///
    /// 此方法仅在使用"editor"div以外的可编辑div时调用
    /// 
    /// 例如,你可能想要删除你放在其他位置的图片副本。如果这样,你
    /// 需要使用相同的名称(默认为UUID),以便容易找到,或者你需要维护
    /// MarkupEditor使用的url和你保存的本地副本之间的映射
    ///
    /// 无论url表示本地图片还是远程图片,通知都会到达。你的代码
    /// 需要区分这种差异
    ///
    /// 注意默认情况下图片会保留在缓存中。这对支持撤销很重要!
    public func markupImageDeleted(_ view: MarkupWKWebView?, url: URL, divId: String) {}
    
    /// 执行将本地图片添加到正在编辑的文档所需的操作
    ///
    /// 默认情况下,我们通过将图片从源url复制到缓存来将其插入视图
    /// 文档相对于html引用该位置
    public func markupImageToAdd(_ view: MarkupWKWebView, url: URL) {
        view.insertLocalImage(url: url)
    }
    
    /// 请参阅协议中的重要注释。默认情况下不支持DropInteraction;但是在SwiftUI中
    /// 你可以在MarkupEditorView上使用.onDrop而无需重新实现此默认方法
    public func markupDropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        // 重写可能类似于:session.canLoadObjects(ofClass: <你的模型类>.self)
        false
    }
    
    /// 默认提供复制建议
    public func markupDropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        UIDropProposal(operation: .copy)
    }
    
    /// 重写此方法以执行拖放操作
    public func markupDropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {}
    
    /// 默认情况下,在MarkupEditor的JavaScript端发生错误时记录日志
    ///
    /// 大多数错误都是内部错误,不应该发生。有关详细信息,请参阅markup.js中的MUError
    /// alert值可用于过滤信息性错误与你可能想要提醒用户的错误
    /// 如果你想让用户知道错误,则重写delegate中的此方法
    public func markupError(code: String, message: String, info: String?, alert: Bool) {
        if alert {
            Logger.script.notice("Error \(code): \(message)")
        } else {
            Logger.script.error("Error \(code): \(message)")
        }
        if let info { Logger.script.info("\(info)") }
    }

    /// 默认情况下,使用LinkViewController在MarkupWKWebView中启动插入链接弹出窗口
    ///
    /// 通过重写markupShowLinkPopover方法,你可以插入自己的应用程序特定视图
    /// 这样做时,请注意在开始时startModalInput,以便在完成时正确返回焦点
    /// 有关示例,请参见showLinkPopover
    public func markupShowLinkPopover(_ view: MarkupWKWebView) {
        view.showLinkPopover()
    }
    
    /// 默认情况下,使用ImageViewController在MarkupWKWebView中启动插入图片弹出窗口
    ///
    /// 通过重写markupShowImagePopover方法,你可以插入自己的应用程序特定视图
    /// 这样做时,请注意在开始时startModalInput,以便在完成时正确返回焦点
    /// 有关示例,请参见showImagePopover
    public func markupShowImagePopover(_ view: MarkupWKWebView) {
        view.showImagePopover()
    }
    
    /// 默认情况下,当MarkupEditor.showInsertPopover.type更改为.table时
    /// 使用SwiftUI TableSizer和TableToolbar从InsertToolbar中显示表格弹出窗口
    ///
    /// 通过重写markupShowTablePopover方法,你可以插入自己的应用程序特定视图
    /// 这样做时,请注意在开始时startModalInput,以便在完成时正确返回焦点
    /// 有关将引导到InsertToolbar的示例,请参见showTablePopover
    public func markupShowTablePopover(_ view: MarkupWKWebView) {
        view.showTablePopover()
    }
    
    public func markupButtonClicked(_ view: MarkupWKWebView, id: String, rect: CGRect) {
        Logger.webview.warning("You should handle markupButtonClicked in your MarkupDelegate.")
    }
    
    /// 视图已激活"搜索模式",此时Enter/Shift+Enter被解释为向前搜索/向后搜索
    /// 工具栏应该被禁用,因为在搜索模式下不应进行编辑
    public func markupActivateSearch(_ view: MarkupWKWebView) {
        MarkupEditor.searchActive.value = true
    }
    
    /// 视图已停用"搜索模式",此时Enter/Shift+Enter不再被解释为搜索操作
    /// 工具栏应该被重新启用
    public func markupDeactivateSearch(_ view: MarkupWKWebView) {
        MarkupEditor.searchActive.value = false
    }
    
}
