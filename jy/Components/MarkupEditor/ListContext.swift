//
//  ListContext.swift
//  MarkupEditor
//
//  Created by Steven Harris on 2/8/21.
//  Copyright © 2021 Steven Harris. All rights reserved.
//

import Foundation

/// 在StyleToolbar中跟踪列表类型
public class ListContext: @unchecked Sendable, ObservableObject, Identifiable, Hashable, Equatable, CustomStringConvertible {
    
    // 判断两个ListContext对象是否相等
    public static func == (lhs: ListContext, rhs: ListContext) -> Bool {
        return lhs.tag == rhs.tag
    }
    
    // 定义列表类型的静态常量
    public static let Undefined = ListContext(tag: "Undefined")  // 未定义类型
    public static let UL = ListContext(tag: "UL")               // 无序列表
    public static let OL = ListContext(tag: "OL")               // 有序列表
    public static let AllCases = [Undefined, UL, OL]            // 所有可用的列表类型
    
    // 根据标签创建对应的ListContext对象
    public static func with(tag: String) -> ListContext {
        if let listContext = AllCases.first(where: { $0.tag == tag }) {
            return listContext
        } else {
            return Undefined
        }
    }
    
    // 标识符属性，使用tag作为id
    public var id: String { tag }
    // 可观察的tag属性
    @Published public var tag: String
    // 描述属性，返回tag值
    public var description: String { tag }
    
    // 私有初始化方法
    private init(tag: String) {
        self.tag = tag
    }

    // 实现Hashable协议的方法
    public func hash(into hasher: inout Hasher) {
        hasher.combine(tag)
    }
}
