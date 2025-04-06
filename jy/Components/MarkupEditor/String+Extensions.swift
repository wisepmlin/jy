//
//  String+Extensions.swift
//  MarkupEditor
//
//  Created by Steven Harris on 2/27/21.
//  Copyright © 2021 Steven Harris. All rights reserved.
//

import Foundation

extension String {
    
    /// 转义字符串中的单引号字符
    /// 在将字符串传递到JavaScript时使用，以防止字符串过早结束
    public var escaped: String {
        let unicode = self.unicodeScalars
        var newString = ""
        for char in unicode {
            if char.value == 39 || // ASCII码39表示单引号(')
                char.value < 9 ||  // ASCII码9表示水平制表符
                (char.value > 9 && char.value < 32) // ASCII码小于32表示特殊字符
            {
                let escaped = char.escaped(asASCII: true) // 将字符转换为转义形式
                newString.append(escaped)
            } else {
                newString.append(String(char)) // 直接添加非特殊字符
            }
        }
        return newString
    }
    
    /// 判断字符串是否为有效的URL
    public var isValidURL: Bool {
        guard !isEmpty else { return false } // 如果字符串为空，返回false
        // 创建URL检测器
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        // 在字符串中查找URL匹配项
        let matches = detector.matches(in: self, options: [], range: NSRange(location: 0, length: utf16.count))
        // 只有当字符串完全匹配一个URL时才返回true
        return matches.count == 1 && matches[0].range.length == utf16.count
    }
    
}
