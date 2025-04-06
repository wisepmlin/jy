//
//  FormatContext.swift
//  MarkupEditor
//
//  Created by Steven Harris on 2/8/21.
//  Copyright © 2021 Steven Harris. All rights reserved.
//

import Foundation

/// 在FormatToolbar中作为格式处理的HTML标签
public class FormatContext: @unchecked Sendable, ObservableObject, Identifiable, Hashable, Equatable, CustomStringConvertible {
    
    // 判断两个FormatContext对象是否相等
    public static func == (lhs: FormatContext, rhs: FormatContext) -> Bool {
        return lhs.tag == rhs.tag
    }
    
    // 定义加粗标签
    public static let B = FormatContext(tag: "B")
    // 定义斜体标签
    public static let I = FormatContext(tag: "I")
    // 定义下划线标签
    public static let U = FormatContext(tag: "U")
    // 定义删除线标签
    public static let STRIKE = FormatContext(tag: "DEL")
    // 定义下标标签
    public static let SUB = FormatContext(tag: "SUB")
    // 定义上标标签
    public static let SUP = FormatContext(tag: "SUP")
    // 定义代码标签
    public static let CODE = FormatContext(tag: "CODE")
    // 所有可用的格式标签数组
    public static let AllCases = [B, I, U, STRIKE, SUB, SUP, CODE]
    
    // 标签名作为唯一标识符
    public var id: String { tag }
    // 可观察的标签属性
    @Published public var tag: String
    // 描述信息为标签名
    public var description: String { tag }
    
    // 私有初始化方法
    private init(tag: String) {
        self.tag = tag
    }

    // 实现Hashable协议的哈希方法
    public func hash(into hasher: inout Hasher) {
        hasher.combine(tag)
    }
}
