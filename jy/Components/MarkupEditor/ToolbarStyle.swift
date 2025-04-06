//
//  ToolbarStyle.swift
//  MarkupEditor
//
//  Created by Steven Harris on 8/8/22.
//

import UIKit

// 工具栏样式类，支持主线程操作和状态观察
@MainActor
public class ToolbarStyle: @unchecked Sendable, ObservableObject {
    
    // 紧凑样式的静态实例
    static let compact = ToolbarStyle(.compact)
    // 带标签样式的静态实例
    static let labeled = ToolbarStyle(.labeled)
    
    // 当前样式
    var style: Style
    
    // 样式枚举：紧凑和带标签两种
    public enum Style {
        case compact    // 紧凑样式
        case labeled    // 带标签样式
    }
    
    // 初始化方法，默认使用带标签样式
    public init(_ style: Style = .labeled) {
        self.style = style
    }
    
    // 获取工具栏高度
    public func height() -> CGFloat {
        switch style {
        case .compact:
            if UIDevice.current.userInterfaceIdiom == .mac {
                return 30  // Mac平台下紧凑样式高度
            } else {
                return 40  // 其他平台下紧凑样式高度
            }
        case .labeled:
            return 46     // 带标签样式高度
        }
    }
    
    // 获取按钮高度
    public func buttonHeight() -> CGFloat {
        switch style {
        case .compact:
            if UIDevice.current.userInterfaceIdiom == .mac {
                return 24  // Mac平台下紧凑样式按钮高度
            } else {
                return 32  // 其他平台下紧凑样式按钮高度
            }
        case .labeled:
            return 30     // 带标签样式按钮高度
        }
    }
    
    // 获取符号图标的缩放比例
    public static func symbolScale(for style: Style) -> UIImage.SymbolScale {
        switch style {
        case .compact:
            if UIDevice.current.userInterfaceIdiom == .mac {
                return .medium  // Mac平台下使用中等缩放
            } else {
                return .large   // 其他平台下使用大号缩放
            }
        case .labeled:
            return .large      // 带标签样式使用大号缩放
        }
    }
    
}
