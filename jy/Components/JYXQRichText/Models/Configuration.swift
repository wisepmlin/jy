//
//  Configuration.swift
//  
//
//  由 Macbookator 创建于 5.06.2022
//

import SwiftUI

public struct Configuration {
    @Environment(\.theme) private var theme
    // 自定义CSS样式
    public var customCSS: String
    
    // 字体类型
    public var fontType: FontType
    // 字体颜色
    public var fontColor: ColorSet
    // 行高
    public var lineHeight: CGFloat
    
    // 富文本颜色方案
    public var colorScheme: RichTextColorScheme
    
    // 图片圆角半径
    public var imageRadius: CGFloat
    
    // 链接打开方式
    public var linkOpenType: LinkOpenType
    // 链接颜色
    public var linkColor: ColorSet
    // 基础URL
    public var baseURL: URL?
    
    // 颜色优先级设置
    public var isColorsImportant: ColorPreference
    
    // 过渡动画
    public var transition: Animation?
    
    public init(
        customCSS: String = "",
        fontType: FontType = .system,
        fontColor: ColorSet = .init(light: "000000", dark: "F2F2F2"),
        lineHeight: CGFloat = 170,
        colorScheme: RichTextColorScheme = .auto,
        imageRadius: CGFloat = 0,
        linkOpenType: LinkOpenType = .Safari,
        linkColor: ColorSet = .init(light: "007AFF", dark: "0A84FF", isImportant: true),
        baseURL: URL? = Bundle.main.bundleURL,
        isColorsImportant: ColorPreference = .onlyLinks,
        transition: Animation? = .none
    ) {
        self.customCSS = customCSS
        self.fontType = fontType
        self.fontColor = fontColor
        self.lineHeight = lineHeight
        self.colorScheme = colorScheme
        self.imageRadius = imageRadius
        self.linkOpenType = linkOpenType
        self.linkColor = linkColor
        self.baseURL = baseURL
        self.isColorsImportant = isColorsImportant
        self.transition = transition
    }
    
    // 生成CSS样式字符串
    func css(isLight: Bool, alignment: TextAlignment) -> String {
        """
        img{max-height: 100%; min-height: 100%; height:auto; max-width: 100%; width:auto;margin-bottom:5px; border-radius: \(imageRadius)px;}
        h1, h2, h3, h4, h5, h6, p, div, dl, ol, ul, pre, blockquote, table {text-align:\(alignment.htmlDescription); line-height: \(lineHeight)%; font-family: '\(fontType.name)' !important; color: \(fontColor.value(isLight)) !important; margin: 0px; padding: 0px;}
        iframe{width:100%; height:250px;}
        
        a:link {color: \(linkColor.value(isLight));}
        A {text-decoration: none;}
        """
    }
}
