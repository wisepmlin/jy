//
//  MarkupWKWebViewConfiguration.swift
//  MarkupEditor
//
//  Created by Steven Harris on 12/23/23.
//

import Foundation

/// 用于初始化MarkupEditor web视图的属性集合
///
/// MarkupWKWebViewConfiguration对象提供了如何配置MarkupWKWebView对象的信息。
/// 使用配置对象可以指定：
///
/// * 在MarkupWKWebView加载完`markup.js`文件后需要加载的Javascript文件脚本。
/// 文件名必须指定，并且必须作为应用程序包的一部分提供给MarkupEditor。
///
/// * 在MarkupWKWebView加载完`markup.css`文件后需要加载的CSS文件。
/// 文件名必须指定，并且必须作为应用程序包的一部分提供给MarkupEditor。
///
/// * `markup.html`中`editor`元素的顶级属性。默认情况下，整个`editor`
/// 是可编辑的，但不会执行拼写检查。自动更正默认启用，因为如果没有它，
/// iOS键盘将不会提供建议。
///
/// 在代码中创建MarkupWKWebViewConfiguration对象，配置其属性，并将其传递给
/// WKWebView对象的初始化器。web视图仅在创建时采用配置设置；之后无法
/// 动态更改这些设置。
public class MarkupWKWebViewConfiguration {
    
    // 用户自定义的JavaScript文件
    public var userScriptFile: String? = nil
    // 用户自定义的CSS文件
    public var userCssFile: String? = nil
    // 编辑器的顶级属性
    public var topLevelAttributes = EditableAttributes.standard
    
    // 初始化方法
    public init() {}
}
