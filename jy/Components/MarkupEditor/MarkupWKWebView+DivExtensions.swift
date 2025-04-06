//
//  MarkupWKWebView+DivExtensions.swift
//  MarkupEditor
//
//  Created by Steven Harris on 1/15/24.
//

import OSLog

extension MarkupWKWebView {
    
    /// 将divStructure中的所有div添加到视图中，同时添加它们的资源(资源名称必须唯一)
    ///
    /// 此方法调用多个异步JavaScript方法来添加divStructure中的div，不等待任何响应
    public func load(divStructure: MarkupDivStructure, index: Int = 0, handler: (()->Void)? = nil) {
        for div in divStructure.divs {
            if let resourcesUrl = div.resourcesUrl {
                copyResources(from: resourcesUrl)
            }
            addDiv(div)
        }
        handler?()
    }
    
    /// 卸载divStructure中的所有div
    ///
    /// 此方法调用多个异步JavaScript方法来移除divStructure中的div，不等待任何响应
    /// 作为替代方案，我们可以使用removeAllDivs，但我们显式地这样做是因为我们希望在divStructure的内容与视图中的内容不对应时能够明显看出来
    /// 当持有MarkupEditorView的SwiftUI视图因状态更改而初始化时，可能会发生这种情况
    public func unload(divStructure: MarkupDivStructure, index: Int = 0, handler: (()->Void)? = nil) {
        for div in divStructure.divs {
            // 注意我们不从临时目录中删除资源
            removeDiv(div)
        }
        handler?()
    }
    
    /* 使用递归和等待回调的替代方案 */
    /*
    /// 递归地将divStructure中的所有div加载到视图中，当全部完成时执行handler
    public func load(divStructure: MarkupDivStructure, index: Int = 0, handler: (()->Void)? = nil) {
        loadDiv(divStructure: divStructure, atIndex: index) { nextIndex in
            if let nextIndex {
                self.load(divStructure: divStructure, index: nextIndex, handler: handler)
            } else {
                print("executing load handler")
                handler?()
            }
        }
    }
    
    /// 将指定索引处的div加载到视图中，完成后使用下一个索引执行handler
    ///
    /// 注意"完成"仅表示对JavaScript的异步调用已返回，而不是JavaScript端正在加载的内容实际已加载
    /// 以这种方式执行加载过程的原因是为了避免在执行数百个evaluateJavaScript调用而不等待它们执行其处理程序时触发IPC限制
    /// 参见https://forums.developer.apple.com/forums/thread/670959作为示例
    /// 但我已经看到"IPC throttling was triggered (has 625 pending incoming messages, will only process 600 before yielding)"
    private func loadDiv(divStructure: MarkupDivStructure, atIndex index: Int, handler: @escaping (Int?)->Void) {
        guard index < divStructure.divs.count else {
            handler(nil)
            return
        }
        let div = divStructure.divs[index]
        if let resourcesUrl = div.resourcesUrl {
            copyResources(from: resourcesUrl)
        }
        addDiv(div) {
            handler(index + 1)
        }
    }
    
    public func unload(divStructure: MarkupDivStructure, index: Int = 0, handler: (()->Void)? = nil) {
        unloadDiv(divStructure: divStructure, atIndex: index) { nextIndex in
            if let nextIndex {
                self.unload(divStructure: divStructure, index: nextIndex, handler: handler)
            } else {
                print("executing unload handler")
                handler?()
            }
        }
    }
    
    private func unloadDiv(divStructure: MarkupDivStructure, atIndex index: Int, handler: @escaping (Int?)->Void) {
        guard index < divStructure.divs.count else {
            handler(nil)
            return
        }
        let div = divStructure.divs[index]
        // TODO: Remove resources
        removeDiv(div) {
            handler(index + 1)
        }
    }
    */
    
    /// 将baseUrl中的所有资源复制到用于编辑的临时路径中
    ///
    /// 注意资源在文档中的所有div中需要唯一命名
    private func copyResources(from resourcesUrl: URL) {
        let fileManager = FileManager.default
        var tempResourcesUrl: URL
        if resourcesUrl.baseURL == nil {
            tempResourcesUrl = baseUrl
        } else {
            tempResourcesUrl = baseUrl.appendingPathComponent(resourcesUrl.relativePath)
        }
        let tempResourcesUrlPath = tempResourcesUrl.path
        do {
            try fileManager.createDirectory(atPath: tempResourcesUrlPath, withIntermediateDirectories: true, attributes: nil)
            // 如果我们指定了resourceUrl但没有资源，这不是错误
            let resources = (try? fileManager.contentsOfDirectory(at: resourcesUrl, includingPropertiesForKeys: nil, options: [])) ?? []
            for srcUrl in resources {
                let dstUrl = tempResourcesUrl.appendingPathComponent(srcUrl.lastPathComponent)
                try? fileManager.removeItem(at: dstUrl)
                try fileManager.copyItem(at: srcUrl, to: dstUrl)
            }
        } catch let error {
            Logger.webview.error("复制资源文件失败: \(error.localizedDescription)")
        }
    }
    
    /// 将div添加到视图中，如果按钮不是动态创建的，则包括其按钮
    public func addDiv(_ div: HtmlDivHolder, handler: (()->Void)? = nil) {
        let id = div.id
        let parentId = div.parentId
        let cssClass = div.cssClass
        let attributes = div.attributes
        var jsonAttributes: String?
        if !attributes.isEmpty, let jsonData = try? JSONSerialization.data(withJSONObject: attributes.options) {
            jsonAttributes = String(data: jsonData, encoding: .utf8)
        }
        let htmlContents = div.htmlContents.escaped
        let buttonGroup = div.buttonGroup
        evaluateJavaScript("MU.addDiv('\(id)', '\(parentId)', '\(cssClass)', '\(jsonAttributes ?? "null")', '\(htmlContents)')") { result, error in
            if let error {
                Logger.webview.error("添加HtmlDiv时出错: \(error)")
            }
            if let buttonGroup, !buttonGroup.isDynamic {
                self.addButtonGroup(buttonGroup) {
                    handler?()
                }
            } else {
                handler?()
            }
        }
    }
    
    /// 从视图中移除div
    public func removeDiv(_ div: HtmlDivHolder, handler: (()->Void)? = nil) {
        evaluateJavaScript("MU.removeDiv('\(div.id)')") { result, error in
            if let error {
                Logger.webview.error("移除HtmlDiv时出错: \(error)")
            }
            handler?()
        }
    }
    
    /// 将buttonGroup添加到视图中
    ///
    /// 按钮组是包含按钮的div，因此它们可以作为一个组进行定位
    /// 按钮组始终位于某个父级中，通常是具有contentEditable div的focusId的非contenteditable标题
    public func addButtonGroup(_ buttonGroup: HtmlButtonGroup, handler: (()->Void)? = nil) {
        let id = buttonGroup.id
        let parentId = buttonGroup.parentId
        let cssClass = buttonGroup.cssClass
        evaluateJavaScript("MU.addDiv('\(id)', '\(parentId)', '\(cssClass)')") { result, error in
            if let error {
                Logger.webview.error("添加HtmlButtonGroup时出错: \(error)")
            } else if let result {
                Logger.webview.warning("\(result as? String ?? "nil")")
            } else {
                // 我们将在所有按钮添加完成之前运行handler，但我们不在意
                for button in buttonGroup.buttons {
                    self.addButton(button, in: id)
                }
            }
            handler?()
        }
    }
    
    /// 从视图中移除buttonGroup
    public func removeButtonGroup(_ buttonGroup: HtmlButtonGroup, handler: (()->Void)? = nil) {
        evaluateJavaScript("MU.removeDiv('\(buttonGroup.id)')") { result, error in
            if let error {
                Logger.webview.error("移除HtmlButtonGroup时出错: \(error)")
            }
            handler?()
        }
    }

    /// 将button添加到具有parentId的父HtmlButtonGroup div中
    private func addButton(_ button: HtmlButton, in parentId: String, handler: (()->Void)? = nil) {
        let id = button.id
        let cssClass = button.cssClass
        let label = button.label.escaped
        evaluateJavaScript("MU.addButton('\(id)', '\(parentId)', '\(cssClass)', '\(label)')") { result, error in
            if let error {
                Logger.webview.error("添加HtmlButton时出错: \(error)")
            }
            handler?()
        }
    }
    
    /// 根据id移除button
    private func removeButton(_ button: HtmlButton, handler: (()->Void)? = nil) {
        evaluateJavaScript("MU.removeButton('\(button.id)')") { result, error in
            if let error {
                Logger.webview.error("移除HtmlButton时出错: \(error)")
            }
            handler?()
        }
    }
    
    /// 聚焦于具有id的元素
    ///
    /// 用于设置contenteditable div的焦点。聚焦后，选择状态将重置
    public func focus(on id: String?, handler: (()->Void)? = nil) {
        guard let id else {
            handler?()
            return
        }
        evaluateJavaScript("MU.focusOn('\(id)')") { result, error in
            if let error {
                Logger.webview.error("聚焦id为\(id)的元素时出错: \(error)")
            }
            self.becomeFirstResponder()
            self.getSelectionState { selectionState in
                MarkupEditor.selectionState.reset(from: selectionState)
                handler?()
            }
        }
    }
    
    /// 将具有id的元素滚动到视图中
    public func scrollIntoView(id: String?, handler: (()->Void)? = nil) {
        guard let id else {
            handler?()
            return
        }
        evaluateJavaScript("MU.scrollIntoView('\(id)')") { result, error in
            if let error {
                Logger.webview.error("滚动到id为\(id)的元素时出错: \(error)")
            }
            handler?()
        }
    }
    
    /// 移除所有div
    public func removeAllDivs(handler: (()->Void)? = nil) {
        evaluateJavaScript("MU.removeAllDivs()") { result, error in
            if let error {
                Logger.webview.error("移除所有div时出错: \(error)")
            }
            handler?()
        }
    }

}
