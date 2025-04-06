//
//  UIView+Extensions.swift
//  MarkupEditor
//
//  Created by Steven Harris on 9/5/22.
//

import UIKit

// UIView的扩展
extension UIView {
    
    /// 获取当前视图所在的最近的UIViewController
    /// - Returns: 返回最近的UIViewController，如果没有找到则返回nil
    public func closestVC() -> UIViewController? {
        // 从当前视图开始向上遍历响应链
        var responder: UIResponder? = self
        // 当响应者存在时继续循环
        while responder != nil {
            // 判断当前响应者是否为UIViewController
            if let vc = responder as? UIViewController {
                return vc
            }
            // 获取下一个响应者
            responder = responder?.next
        }
        // 如果没有找到UIViewController则返回nil
        return nil
    }
}
