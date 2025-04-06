//
//  MarkupDivStructure.swift
//  SwiftUIDemo
//
//  Created by Steven Harris on 1/17/24.
//

import Foundation

/// MarkupDivStructure是一个用于存储MarkupEditor使用的div和按钮组的类
public class MarkupDivStructure {
    // 存储所有的HTML div容器
    public var divs: [HtmlDivHolder] = []
    // 通过id存储HTML div容器的字典
    private var divsById: [String : HtmlDivHolder] = [:]
    // 通过id存储HTML按钮的字典
    private var buttonsById: [String : HtmlButton] = [:]
    // 存储div id对应的焦点id的字典
    private var focusIdsByDivId: [String : String] = [:]
    // 存储焦点id对应的按钮组id的字典
    private var buttonGroupIdsByFocusId: [String : String] = [:]
    
    // 初始化方法
    public init() {}
    
    // 重置所有数据结构
    public func reset() {
        divs = []
        divsById = [:]
        buttonsById = [:]
        focusIdsByDivId = [:]
        buttonGroupIdsByFocusId = [:]
    }
    
    // 添加一个HTML div容器
    public func add(_ div: HtmlDivHolder) {
        divs.append(div)
        divsById[div.id] = div
        // 如果div有焦点id，则保存对应关系
        if let focusId = div.focusId {
            focusIdsByDivId[div.id] = focusId
        }
        // 如果div有按钮组，则处理按钮组相关的存储
        if let buttonGroup = div.buttonGroup {
            divsById[buttonGroup.id] = buttonGroup
            if let focusId = div.focusId {
                buttonGroupIdsByFocusId[focusId] = buttonGroup.id
            }
            // 存储按钮组中的所有按钮
            for button in buttonGroup.buttons {
                buttonsById[button.id] = button
            }
        }
    }
    
    // 移除一个HTML div容器
    public func remove(_ div: HtmlDivHolder) {
        guard let index = divs.firstIndex(where: {existing in existing.id == div.id }) else { return }
        divs.remove(at: index)
        divsById.removeValue(forKey: div.id)
        focusIdsByDivId.removeValue(forKey: div.id)
        buttonGroupIdsByFocusId.removeValue(forKey: div.id) // 如果这个div.id是一个焦点id，则移除它
        // 移除所有相关按钮
        for button in div.buttons {
            buttonsById.removeValue(forKey: button.id)
        }
    }
    
    // 根据按钮id获取按钮
    public func button(forButtonId buttonId: String) -> HtmlButton? {
        buttonsById[buttonId]
    }
    
    // 根据div id获取div容器
    public func div(forDivId divId: String?) -> HtmlDivHolder? {
        guard let divId else { return nil }
        return divsById[divId]
    }
    
    // 根据div id获取焦点id
    public func focusId(forDivId divId: String) -> String? {
        focusIdsByDivId[divId]
    }
    
    // 根据div id获取按钮组id
    public func buttonGroupId(forDivId divId: String?) -> String? {
        guard let divId else { return nil }
        return buttonGroupIdsByFocusId[divId]
    }
    
}
