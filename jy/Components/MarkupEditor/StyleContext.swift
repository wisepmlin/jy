//
//  StyleContext.swift
//  MarkupEditor
//
//  Created by Steven Harris on 2/8/21.
//  Copyright © 2021 Steven Harris. All rights reserved.
//

import UIKit

/// HTML标签在StyleToolbar中被视为样式。名称显示给用户，但HTML以标签形式存在
public class StyleContext: @unchecked Sendable, ObservableObject, Identifiable, Hashable, Equatable, CustomStringConvertible {
    // 未定义样式
    public static let Undefined = StyleContext(tag: "Undefined", name: "Style", fontSize: P.fontSize)
    // 多重样式
    public static let Multiple = StyleContext(tag: "Multiple", name: "Multiple", fontSize: P.fontSize)
    // 普通段落样式
    public static let P = StyleContext(tag: "P", name: "Normal", fontSize: 16)
    // 一级标题样式
    public static let H1 = StyleContext(tag: "H1", name: "Header 1", fontSize: 26)
    // 二级标题样式
    public static let H2 = StyleContext(tag: "H2", name: "Header 2", fontSize: 24)
    // 三级标题样式
    public static let H3 = StyleContext(tag: "H3", name: "Header 3", fontSize: 22)
    // 四级标题样式
    public static let H4 = StyleContext(tag: "H4", name: "Header 4", fontSize: 20)
    // 五级标题样式
    public static let H5 = StyleContext(tag: "H5", name: "Header 5", fontSize: 18)
    // 六级标题样式
    public static let H6 = StyleContext(tag: "H6", name: "Header 6", fontSize: 16)
    // 所有可用样式cases
    public static let AllCases = [Undefined, Multiple, P, H1, H2, H3, H4, H5, H6]
    // 标准样式cases（不包含未定义和多重样式）
    public static let StyleCases = [P, H1, H2, H3, H4, H5, H6]
    // 按字体大小从小到大排序的样式cases
    public static let SizeCases = [P, H6, H5, H4, H3, H2, H1]  // In order smallest to largest
    
    // 判断两个StyleContext是否相等
    public static func == (lhs: StyleContext, rhs: StyleContext) -> Bool {
        return lhs.tag == rhs.tag
    }
    
    // 根据标签获取对应的StyleContext，如果找不到则返回段落样式
    @MainActor public static func with(tag: String) -> StyleContext {
        if let styleContext = AllCases.first(where: { $0.tag == tag }) {
            return styleContext
        } else {
            return P        // Default to P rather than Undefined
        }
    }
    
    // 唯一标识符
    public var id: String { tag }
    // HTML标签名
    @Published public var tag: String
    // 显示给用户的样式名称
    @Published public var name: String
    // 字体大小
    @Published public var fontSize: CGFloat
    // 描述信息
    public var description: String { tag }
    
    // 私有初始化方法
    private init(tag: String, name: String, fontSize: CGFloat) {
        self.tag = tag
        self.name = name
        self.fontSize = fontSize
    }

    // 哈希方法实现
    public func hash(into hasher: inout Hasher) {
        hasher.combine(tag)
    }
}
