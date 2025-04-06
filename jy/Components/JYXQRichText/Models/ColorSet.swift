//
//  ColorSet.swift
//  
//
//  Created by 이웅재(NuPlay) on 2022/01/04.
//  https://github.com/NuPlay/RichText

import SwiftUI

// 颜色集合结构体
public struct ColorSet {
    // 亮色模式下的颜色值
    private let light: String
    // 暗色模式下的颜色值
    private let dark: String
    // 是否为重要样式
    public var isImportant: Bool

    // 使用字符串初始化颜色
    public init(light: String, dark: String, isImportant: Bool = false) {
        self.light = light
        self.dark = dark
        self.isImportant = isImportant
    }

    // iOS平台使用UIColor初始化
    #if canImport(UIKit)
    public init(light: UIColor, dark: UIColor, isImportant: Bool = false) {
         self.light = light.hex ?? "000000"
         self.dark = dark.hex ?? "F2F2F2"
         self.isImportant = isImportant
    }
    // macOS平台使用NSColor初始化
    #else
    public init(light: NSColor, dark: NSColor, isImportant: Bool = false) {
         self.light = light.hex ?? "000000"
         self.dark = dark.hex ?? "F2F2F2"
         self.isImportant = isImportant
    }
    #endif

    // 根据明暗模式返回对应的颜色值
    func value(_ isLight: Bool) -> String {
        "#\(isLight ? light : dark)\(isImportant ? " !important" : "")"
    }
}
