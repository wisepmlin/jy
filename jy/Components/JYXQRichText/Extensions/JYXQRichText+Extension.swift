//
//  RichTextExtension.swift
//  
//
//  Created by 이웅재(NuPlay) on 2021/08/27.
//  https://github.com/NuPlay/RichText

import SwiftUI

extension JYXQRichText {
    // 添加自定义CSS样式
    public func customCSS(_ customCSS: String) -> JYXQRichText {
        var result = self
        result.configuration.customCSS += customCSS
        return result
    }
    
    // 设置行高
    public func lineHeight(_ lineHeight: CGFloat) -> JYXQRichText {
        var result = self
        result.configuration.lineHeight = lineHeight
        return result
    }
    
    // 设置颜色方案
    public func colorScheme(_ colorScheme: RichTextColorScheme) -> JYXQRichText {
        var result = self
        result.configuration.colorScheme = colorScheme
        return result
    }

    // 设置图片圆角
    public func imageRadius(_ imageRadius: CGFloat) -> JYXQRichText {
        var result = self
        result.configuration.imageRadius = imageRadius
        return result
    }

    // 设置字体类型
    public func fontType(_ fontType: FontType) -> JYXQRichText {
        var result = self
        result.configuration.fontType = fontType
        return result
    }
    
    #if canImport(UIKit)
    // 设置前景色(iOS 14.0及以上版本)
    @available(iOS 14.0, *)
    public func foregroundColor(light: Color, dark: Color) -> JYXQRichText {
        var result = self
        result.configuration.fontColor = .init(light: UIColor(light), dark: UIColor(dark))
        return result
    }

    // 设置前景色(UIKit)
    public func foregroundColor(light: UIColor, dark: UIColor) -> JYXQRichText {
        var result = self
        result.configuration.fontColor = .init(light: light, dark: dark)
        return result
    }
    #else
    // 设置前景色(macOS)
    public func foregroundColor(light: NSColor, dark: NSColor) -> JYXQRichText {
        var result = self
        result.configuration.fontColor = .init(light: light, dark: dark)
        return result
    }
    #endif
    
    #if canImport(UIKit)
    // 设置链接颜色(iOS 14.0及以上版本)
    @available(iOS 14.0, *)
    public func linkColor(light: Color, dark: Color) -> JYXQRichText {
        var result = self
        result.configuration.linkColor = .init(light: UIColor(light), dark: UIColor(dark))
        return result
    }
    
    // 设置链接颜色(UIKit)
    public func linkColor(light: UIColor, dark: UIColor) -> JYXQRichText {
        var result = self
        result.configuration.linkColor = .init(light: light, dark: dark)
        return result
    }
    #else
    // 设置链接颜色(macOS)
    public func linkColor(light: NSColor, dark: NSColor) -> JYXQRichText {
        var result = self
        result.configuration.linkColor = .init(light: light, dark: dark)
        return result
    }
    #endif

    // 设置链接打开方式
    public func linkOpenType(_ linkOpenType: LinkOpenType) -> JYXQRichText {
        var result = self
        result.configuration.linkOpenType = linkOpenType
        return result
    }

    // 设置基础URL
    public func baseURL(_ baseURL: URL) -> JYXQRichText {
        var result = self
        result.configuration.baseURL = baseURL
        return result
    }

    // 设置颜色偏好
    public func colorPreference(forceColor: ColorPreference) -> JYXQRichText {
        var result = self
        result.configuration.isColorsImportant = forceColor
        
        switch forceColor {
        case .all:
            result.configuration.linkColor.isImportant = true
            result.configuration.fontColor.isImportant = true
        case .onlyLinks:
            result.configuration.linkColor.isImportant = true
            result.configuration.fontColor.isImportant = false
        case .none:
            result.configuration.linkColor.isImportant = false
            result.configuration.fontColor.isImportant = false
        }
        
        return result
    }
    
    // 设置占位视图
    public func placeholder<T>(@ViewBuilder content: () -> T) -> JYXQRichText where T: View {
        var result = self
        result.placeholder = AnyView(content())
        return result
    }
    
    // 设置过渡动画
    public func transition(_ transition: Animation?) -> JYXQRichText {
        var result = self
        result.configuration.transition = transition
        return result
    }
}