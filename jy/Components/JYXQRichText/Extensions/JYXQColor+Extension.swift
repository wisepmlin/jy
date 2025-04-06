//
//  Color+Extension.swift
//
//  由 Macbookator 创建于 5.06.2022
//

#if canImport(UIKit)
import UIKit

extension UIColor {
    // 将UIColor转换为十六进制字符串
    var hex: String? {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        // 用于将RGB值转换为0-255范围的乘数
        let multiplier = CGFloat(255.999999)

        // 尝试获取颜色的RGBA分量
        guard getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return nil
        }

        // 如果透明度为1.0，返回6位十六进制值（RGB）
        if alpha == 1.0 {
            return String(
                format: "%02lX%02lX%02lX",
                Int(red * multiplier),
                Int(green * multiplier),
                Int(blue * multiplier)
            )
        } else {
            // 如果有透明度，返回8位十六进制值（RGBA）
            return String(
                format: "%02lX%02lX%02lX%02lX",
                Int(red * multiplier),
                Int(green * multiplier),
                Int(blue * multiplier),
                Int(alpha * multiplier)
            )
        }
    }
}
#else
import AppKit

extension NSColor {
    // 将NSColor转换为十六进制字符串
    var hex: String? {
        // 确保颜色组件存在且至少有RGB三个分量
        guard let components = cgColor.components, components.count >= 3 else {
            return nil
        }

        // 获取RGB分量
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])

        // 转换为6位十六进制格式
        return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
    }
}
#endif
