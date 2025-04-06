//
//  RichTextEnums.swift
//
//
//  Created by 이웅재(NuPlay) on 2021/07/26.
//  https://github.com/NuPlay/RichText

import Foundation
import SafariServices

// 字体类型枚举
public enum FontType {
    case system          // 系统字体
    case monospaced      // 等宽字体
    case italic          // 斜体字体
    #if canImport(UIKit)
    case custom(UIFont)  // 自定义UIFont字体
    #endif
    case customName(String)  // 自定义字体名称

    @available(*, deprecated, renamed: "system")
    case `default`       // 默认字体（已废弃）
    
    // 获取字体名称
    var name: String {
        switch self {
        case .monospaced:
            #if canImport(UIKit)
            return UIFont.monospacedSystemFont(ofSize: 17, weight: .regular).fontName
            #else
            return NSFont.monospacedSystemFont(ofSize: 17, weight: .regular).fontName
            #endif
        case .italic:
            #if canImport(UIKit)
            return UIFont.italicSystemFont(ofSize: 17).fontName
            #else
            return NSFont(descriptor: NSFont.systemFont(ofSize: 17).fontDescriptor.withSymbolicTraits(.italic), size: 17)?.fontName ?? ""
            #endif
        #if canImport(UIKit)
        case let .custom(font):
            return font.fontName
        #endif
        case let .customName(name):
            return name
        default:
            return "-apple-system"
        }
    }
}

// 链接打开方式枚举
public enum LinkOpenType {
    #if canImport(UIKit)
    case SFSafariView(configuration: SFSafariViewController.Configuration = .init(), isReaderActivated: Bool? = nil, isAnimated: Bool = true)  // 使用SFSafariView打开
    #endif
    case Safari      // 使用Safari打开
    case custom((URL) -> Void)  // 自定义打开方式
    case none        // 不打开链接
}

// 颜色偏好设置枚举
public enum ColorPreference {
    case all        // 应用所有颜色
    case onlyLinks  // 仅应用链接颜色
    case none       // 不应用颜色
}

// 富文本颜色主题枚举
public enum RichTextColorScheme {
    case light     // 浅色主题
    case dark      // 深色主题
    case auto      // 自动主题
}

// MARK: - 已废弃的枚举
/*
@available(*, deprecated, renamed: "ColorScheme")
public enum colorScheme: String {
    case light = "light"
    case dark = "dark"
    case automatic = "automatic"
}

@available(*, deprecated, renamed: "FontType")
public enum fontType: String {
    case system = "system"
    case monospaced = "monospaced"
    case italic = "italic"

    @available(*, deprecated, renamed: "system")
    case `default` = "default"
}

@available(*, deprecated, renamed: "LinkOpenType")
public enum linkOpenType: String {
    case SFSafariView = "SFSafariView"
    case SFSafariViewWithReader = "SFSafariViewWithReader"
    case Safari = "Safari"
    case none = "none"
}
*/
