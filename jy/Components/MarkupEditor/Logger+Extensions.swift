//
//  Logger+Extensions.swift
//  MarkupEditor
//
//  Created by Steven Harris on 9/4/23.
//

import OSLog

// Logger的扩展，实现Sendable协议
extension Logger: @unchecked Sendable {

    // 获取应用的Bundle标识符作为子系统名称
    private static let subsystem = Bundle.main.bundleIdentifier!

    // 创建用于脚本相关日志的Logger实例
    public static let script = Logger(subsystem: subsystem, category: "script")
    // 创建用于协调器相关日志的Logger实例
    public static let coordinator = Logger(subsystem: subsystem, category: "coordinator")
    // 创建用于WebView相关日志的Logger实例
    public static let webview = Logger(subsystem: subsystem, category: "webview")
    // 创建用于测试相关日志的Logger实例
    public static let test = Logger(subsystem: subsystem, category: "test")
    
}
