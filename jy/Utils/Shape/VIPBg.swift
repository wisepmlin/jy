//
//  VIPBg.swift
//  jy
//
//  Created by 林晓彬 on 2025/2/6.
//
import SwiftUI

struct VIPBg: Shape {
    // 圆角半径
    var cornerRadius: CGFloat = 8
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        
        // 计算关键点
        let startX = 0.69527 * width
        let startY = 0.01936 * height
        let point1X = 0.78659 * width
        let point1Y = 0.30673 * height
//        let point2X = 0.97927 * width
        let point2Y = 0.32609 * height
        
        path.move(to: CGPoint(x: startX, y: startY))
        path.addLine(to: CGPoint(x: point1X, y: point1Y))
        
        // 添加上部曲线
        path.addCurve(
            to: CGPoint(x: 0.80384*width, y: point2Y),
            control1: CGPoint(x: 0.79044*width, y: 0.31882*height),
            control2: CGPoint(x: 0.79691*width, y: point2Y)
        )
        path.addLine(to: CGPoint(x: width - cornerRadius, y: point2Y))
        
        // 右上圆角
        path.addArc(
            center: CGPoint(x: width - cornerRadius, y: point2Y + cornerRadius),
            radius: cornerRadius,
            startAngle: .degrees(270),
            endAngle: .degrees(0),
            clockwise: false
        )
        
        // 右侧
        path.addLine(to: CGPoint(x: width, y: height - cornerRadius))
        
        // 右下圆角
        path.addArc(
            center: CGPoint(x: width - cornerRadius, y: height - cornerRadius),
            radius: cornerRadius,
            startAngle: .degrees(0),
            endAngle: .degrees(90),
            clockwise: false
        )
        
        // 底部
        path.addLine(to: CGPoint(x: cornerRadius, y: height))
        
        // 左下圆角
        path.addArc(
            center: CGPoint(x: cornerRadius, y: height - cornerRadius),
            radius: cornerRadius,
            startAngle: .degrees(90),
            endAngle: .degrees(180),
            clockwise: false
        )
        
        // 左侧
        path.addLine(to: CGPoint(x: 0, y: cornerRadius))
        
        // 左上圆角
        path.addArc(
            center: CGPoint(x: cornerRadius, y: cornerRadius),
            radius: cornerRadius,
            startAngle: .degrees(180),
            endAngle: .degrees(270),
            clockwise: false
        )
        
        path.addLine(to: CGPoint(x: 0.67803*width, y: 0))
        
        // 闭合路径
        path.addCurve(
            to: CGPoint(x: startX, y: startY),
            control1: CGPoint(x: 0.68496*width, y: 0),
            control2: CGPoint(x: 0.69143*width, y: 0.00727*height)
        )
        path.closeSubpath()
        return path
    }
}

struct VIPTagBg: Shape {
    // 左上圆角
    var topLeftRadius: CGFloat = 12
    // 左下圆角
    var bottomLeftRadius: CGFloat = 8
    // 右下圆角
    var bottomRightRadius: CGFloat = 4
    // 右上内圆角
    var topRightInnerRadius: CGFloat = 6
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        
        // 起始点从右下角开始
        path.move(to: CGPoint(x: 0.904*width, y: height))
        
        // 底边到左下角
        path.addLine(to: CGPoint(x: bottomLeftRadius, y: height))
        
        // 左下圆角
        path.addArc(
            center: CGPoint(x: bottomLeftRadius, y: height - bottomLeftRadius),
            radius: bottomLeftRadius,
            startAngle: .degrees(90),
            endAngle: .degrees(180),
            clockwise: false
        )
        
        // 左边到左上角
        path.addLine(to: CGPoint(x: 0, y: topLeftRadius))
        
        // 左上圆角
        path.addArc(
            center: CGPoint(x: topLeftRadius, y: topLeftRadius),
            radius: topLeftRadius,
            startAngle: .degrees(180),
            endAngle: .degrees(270),
            clockwise: false
        )
        
        // 上边到右上角前
        path.addLine(to: CGPoint(x: width - topRightInnerRadius, y: 0))
        
        // 右上内圆角
        path.addArc(
            center: CGPoint(x: width - topRightInnerRadius, y: topRightInnerRadius),
            radius: topRightInnerRadius,
            startAngle: .degrees(270),
            endAngle: .degrees(0),
            clockwise: false
        )
        
        // 右侧曲线
        path.addCurve(
            to: CGPoint(x: 0.90403*width, y: 0.36547*height),
            control1: CGPoint(x: 0.9478*width, y: 0.12*height),
            control2: CGPoint(x: 0.90532*width, y: 0.16277*height)
        )
        
        path.addLine(to: CGPoint(x: 0.904*width, y: 0.375*height))
        
        // 右边到右下角
        path.addLine(to: CGPoint(x: 0.904*width, y: height - bottomRightRadius))
        
        // 右下圆角
        path.addArc(
            center: CGPoint(x: 0.904*width - bottomRightRadius, y: height - bottomRightRadius),
            radius: bottomRightRadius,
            startAngle: .degrees(0),
            endAngle: .degrees(90),
            clockwise: false
        )
        
        path.closeSubpath()
        return path
    }
}

struct ShieldIcon: Shape {
    var cornerRadius: CGFloat = 4 // 默认圆角大小
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        
        // 根据 SVG 文件调整尺寸比例
        path.move(to: CGPoint(x: cornerRadius/width * width, y: 0))
        path.addLine(to: CGPoint(x: (width - cornerRadius), y: 0))
        
        // 右上圆角
        path.addArc(
            center: CGPoint(x: width - cornerRadius, y: cornerRadius),
            radius: cornerRadius,
            startAngle: .degrees(270),
            endAngle: .degrees(0),
            clockwise: false
        )
        
        // 右边
        path.addLine(to: CGPoint(x: width, y: 42.4/55 * height))
        
        // 右下曲线
        path.addCurve(
            to: CGPoint(x: 41.7/44 * width, y: 46.1/55 * height),
            control1: CGPoint(x: width, y: 44/55 * height),
            control2: CGPoint(x: 43.1/44 * width, y: 45.4/55 * height)
        )
        
        // 底部
        path.addLine(to: CGPoint(x: 25.3/44 * width, y: 53.5/55 * height))
        path.addCurve(
            to: CGPoint(x: 18.7/44 * width, y: 53.5/55 * height),
            control1: CGPoint(x: 23.2/44 * width, y: 54.5/55 * height),
            control2: CGPoint(x: 20.8/44 * width, y: 54.5/55 * height)
        )
        
        // 左下曲线
        path.addLine(to: CGPoint(x: 2.3/44 * width, y: 46.1/55 * height))
        path.addCurve(
            to: CGPoint(x: 0, y: 42.4/55 * height),
            control1: CGPoint(x: 0.9/44 * width, y: 45.4/55 * height),
            control2: CGPoint(x: 0, y: 44/55 * height)
        )
        
        // 左边
        path.addLine(to: CGPoint(x: 0, y: cornerRadius))
        
        // 左上圆角
        path.addArc(
            center: CGPoint(x: cornerRadius, y: cornerRadius),
            radius: cornerRadius,
            startAngle: .degrees(180),
            endAngle: .degrees(270),
            clockwise: false
        )
        
        path.closeSubpath()
        return path
    }
}

struct Qr: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.3125*width, y: 0.0625*height))
        path.addLine(to: CGPoint(x: 0.0625*width, y: 0.0625*height))
        path.addLine(to: CGPoint(x: 0.0625*width, y: 0.3125*height))
        path.addLine(to: CGPoint(x: 0.3125*width, y: 0.3125*height))
        path.addLine(to: CGPoint(x: 0.3125*width, y: 0.0625*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.375*width, y: 0))
        path.addLine(to: CGPoint(x: 0.375*width, y: 0.375*height))
        path.addLine(to: CGPoint(x: 0, y: 0.375*height))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0.375*width, y: 0))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.125*width, y: 0.125*height))
        path.addLine(to: CGPoint(x: 0.25*width, y: 0.125*height))
        path.addLine(to: CGPoint(x: 0.25*width, y: 0.25*height))
        path.addLine(to: CGPoint(x: 0.125*width, y: 0.25*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.9375*width, y: 0.0625*height))
        path.addLine(to: CGPoint(x: 0.6875*width, y: 0.0625*height))
        path.addLine(to: CGPoint(x: 0.6875*width, y: 0.3125*height))
        path.addLine(to: CGPoint(x: 0.9375*width, y: 0.3125*height))
        path.addLine(to: CGPoint(x: 0.9375*width, y: 0.0625*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: width, y: 0))
        path.addLine(to: CGPoint(x: width, y: 0.375*height))
        path.addLine(to: CGPoint(x: 0.625*width, y: 0.375*height))
        path.addLine(to: CGPoint(x: 0.625*width, y: 0))
        path.addLine(to: CGPoint(x: width, y: 0))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.75*width, y: 0.125*height))
        path.addLine(to: CGPoint(x: 0.875*width, y: 0.125*height))
        path.addLine(to: CGPoint(x: 0.875*width, y: 0.25*height))
        path.addLine(to: CGPoint(x: 0.75*width, y: 0.25*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.3125*width, y: 0.6875*height))
        path.addLine(to: CGPoint(x: 0.0625*width, y: 0.6875*height))
        path.addLine(to: CGPoint(x: 0.0625*width, y: 0.9375*height))
        path.addLine(to: CGPoint(x: 0.3125*width, y: 0.9375*height))
        path.addLine(to: CGPoint(x: 0.3125*width, y: 0.6875*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.375*width, y: 0.625*height))
        path.addLine(to: CGPoint(x: 0.375*width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.addLine(to: CGPoint(x: 0, y: 0.625*height))
        path.addLine(to: CGPoint(x: 0.375*width, y: 0.625*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.125*width, y: 0.75*height))
        path.addLine(to: CGPoint(x: 0.25*width, y: 0.75*height))
        path.addLine(to: CGPoint(x: 0.25*width, y: 0.875*height))
        path.addLine(to: CGPoint(x: 0.125*width, y: 0.875*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.4375*width, y: 0))
        path.addLine(to: CGPoint(x: 0.5*width, y: 0))
        path.addLine(to: CGPoint(x: 0.5*width, y: 0.0625*height))
        path.addLine(to: CGPoint(x: 0.4375*width, y: 0.0625*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.5*width, y: 0.0625*height))
        path.addLine(to: CGPoint(x: 0.5625*width, y: 0.0625*height))
        path.addLine(to: CGPoint(x: 0.5625*width, y: 0.125*height))
        path.addLine(to: CGPoint(x: 0.5*width, y: 0.125*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.4375*width, y: 0.125*height))
        path.addLine(to: CGPoint(x: 0.5*width, y: 0.125*height))
        path.addLine(to: CGPoint(x: 0.5*width, y: 0.1875*height))
        path.addLine(to: CGPoint(x: 0.4375*width, y: 0.1875*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.5*width, y: 0.1875*height))
        path.addLine(to: CGPoint(x: 0.5625*width, y: 0.1875*height))
        path.addLine(to: CGPoint(x: 0.5625*width, y: 0.25*height))
        path.addLine(to: CGPoint(x: 0.5*width, y: 0.25*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.4375*width, y: 0.25*height))
        path.addLine(to: CGPoint(x: 0.5*width, y: 0.25*height))
        path.addLine(to: CGPoint(x: 0.5*width, y: 0.3125*height))
        path.addLine(to: CGPoint(x: 0.4375*width, y: 0.3125*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.5*width, y: 0.3125*height))
        path.addLine(to: CGPoint(x: 0.5625*width, y: 0.3125*height))
        path.addLine(to: CGPoint(x: 0.5625*width, y: 0.375*height))
        path.addLine(to: CGPoint(x: 0.5*width, y: 0.375*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.4375*width, y: 0.375*height))
        path.addLine(to: CGPoint(x: 0.5*width, y: 0.375*height))
        path.addLine(to: CGPoint(x: 0.5*width, y: 0.4375*height))
        path.addLine(to: CGPoint(x: 0.4375*width, y: 0.4375*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.4375*width, y: 0.5*height))
        path.addLine(to: CGPoint(x: 0.5*width, y: 0.5*height))
        path.addLine(to: CGPoint(x: 0.5*width, y: 0.5625*height))
        path.addLine(to: CGPoint(x: 0.4375*width, y: 0.5625*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.5*width, y: 0.5625*height))
        path.addLine(to: CGPoint(x: 0.5625*width, y: 0.5625*height))
        path.addLine(to: CGPoint(x: 0.5625*width, y: 0.625*height))
        path.addLine(to: CGPoint(x: 0.5*width, y: 0.625*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.4375*width, y: 0.625*height))
        path.addLine(to: CGPoint(x: 0.5*width, y: 0.625*height))
        path.addLine(to: CGPoint(x: 0.5*width, y: 0.6875*height))
        path.addLine(to: CGPoint(x: 0.4375*width, y: 0.6875*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.5*width, y: 0.6875*height))
        path.addLine(to: CGPoint(x: 0.5625*width, y: 0.6875*height))
        path.addLine(to: CGPoint(x: 0.5625*width, y: 0.75*height))
        path.addLine(to: CGPoint(x: 0.5*width, y: 0.75*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.4375*width, y: 0.75*height))
        path.addLine(to: CGPoint(x: 0.5*width, y: 0.75*height))
        path.addLine(to: CGPoint(x: 0.5*width, y: 0.8125*height))
        path.addLine(to: CGPoint(x: 0.4375*width, y: 0.8125*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.5*width, y: 0.8125*height))
        path.addLine(to: CGPoint(x: 0.5625*width, y: 0.8125*height))
        path.addLine(to: CGPoint(x: 0.5625*width, y: 0.875*height))
        path.addLine(to: CGPoint(x: 0.5*width, y: 0.875*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.4375*width, y: 0.875*height))
        path.addLine(to: CGPoint(x: 0.5*width, y: 0.875*height))
        path.addLine(to: CGPoint(x: 0.5*width, y: 0.9375*height))
        path.addLine(to: CGPoint(x: 0.4375*width, y: 0.9375*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.5*width, y: 0.9375*height))
        path.addLine(to: CGPoint(x: 0.5625*width, y: 0.9375*height))
        path.addLine(to: CGPoint(x: 0.5625*width, y: height))
        path.addLine(to: CGPoint(x: 0.5*width, y: height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.9375*width, y: 0.5*height))
        path.addLine(to: CGPoint(x: width, y: 0.5*height))
        path.addLine(to: CGPoint(x: width, y: 0.5625*height))
        path.addLine(to: CGPoint(x: 0.9375*width, y: 0.5625*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.0625*width, y: 0.5*height))
        path.addLine(to: CGPoint(x: 0.125*width, y: 0.5*height))
        path.addLine(to: CGPoint(x: 0.125*width, y: 0.5625*height))
        path.addLine(to: CGPoint(x: 0.0625*width, y: 0.5625*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.125*width, y: 0.4375*height))
        path.addLine(to: CGPoint(x: 0.1875*width, y: 0.4375*height))
        path.addLine(to: CGPoint(x: 0.1875*width, y: 0.5*height))
        path.addLine(to: CGPoint(x: 0.125*width, y: 0.5*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0, y: 0.4375*height))
        path.addLine(to: CGPoint(x: 0.0625*width, y: 0.4375*height))
        path.addLine(to: CGPoint(x: 0.0625*width, y: 0.5*height))
        path.addLine(to: CGPoint(x: 0, y: 0.5*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.25*width, y: 0.4375*height))
        path.addLine(to: CGPoint(x: 0.3125*width, y: 0.4375*height))
        path.addLine(to: CGPoint(x: 0.3125*width, y: 0.5*height))
        path.addLine(to: CGPoint(x: 0.25*width, y: 0.5*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.3125*width, y: 0.5*height))
        path.addLine(to: CGPoint(x: 0.375*width, y: 0.5*height))
        path.addLine(to: CGPoint(x: 0.375*width, y: 0.5625*height))
        path.addLine(to: CGPoint(x: 0.3125*width, y: 0.5625*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.375*width, y: 0.4375*height))
        path.addLine(to: CGPoint(x: 0.4375*width, y: 0.4375*height))
        path.addLine(to: CGPoint(x: 0.4375*width, y: 0.5*height))
        path.addLine(to: CGPoint(x: 0.375*width, y: 0.5*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.5625*width, y: 0.5*height))
        path.addLine(to: CGPoint(x: 0.625*width, y: 0.5*height))
        path.addLine(to: CGPoint(x: 0.625*width, y: 0.5625*height))
        path.addLine(to: CGPoint(x: 0.5625*width, y: 0.5625*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.625*width, y: 0.4375*height))
        path.addLine(to: CGPoint(x: 0.6875*width, y: 0.4375*height))
        path.addLine(to: CGPoint(x: 0.6875*width, y: 0.5*height))
        path.addLine(to: CGPoint(x: 0.625*width, y: 0.5*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.6875*width, y: 0.5*height))
        path.addLine(to: CGPoint(x: 0.75*width, y: 0.5*height))
        path.addLine(to: CGPoint(x: 0.75*width, y: 0.5625*height))
        path.addLine(to: CGPoint(x: 0.6875*width, y: 0.5625*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.75*width, y: 0.4375*height))
        path.addLine(to: CGPoint(x: 0.8125*width, y: 0.4375*height))
        path.addLine(to: CGPoint(x: 0.8125*width, y: 0.5*height))
        path.addLine(to: CGPoint(x: 0.75*width, y: 0.5*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.8125*width, y: 0.5*height))
        path.addLine(to: CGPoint(x: 0.875*width, y: 0.5*height))
        path.addLine(to: CGPoint(x: 0.875*width, y: 0.5625*height))
        path.addLine(to: CGPoint(x: 0.8125*width, y: 0.5625*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.875*width, y: 0.4375*height))
        path.addLine(to: CGPoint(x: 0.9375*width, y: 0.4375*height))
        path.addLine(to: CGPoint(x: 0.9375*width, y: 0.5*height))
        path.addLine(to: CGPoint(x: 0.875*width, y: 0.5*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.9375*width, y: 0.625*height))
        path.addLine(to: CGPoint(x: width, y: 0.625*height))
        path.addLine(to: CGPoint(x: width, y: 0.6875*height))
        path.addLine(to: CGPoint(x: 0.9375*width, y: 0.6875*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.5625*width, y: 0.625*height))
        path.addLine(to: CGPoint(x: 0.625*width, y: 0.625*height))
        path.addLine(to: CGPoint(x: 0.625*width, y: 0.6875*height))
        path.addLine(to: CGPoint(x: 0.5625*width, y: 0.6875*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.625*width, y: 0.5625*height))
        path.addLine(to: CGPoint(x: 0.6875*width, y: 0.5625*height))
        path.addLine(to: CGPoint(x: 0.6875*width, y: 0.625*height))
        path.addLine(to: CGPoint(x: 0.625*width, y: 0.625*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.6875*width, y: 0.625*height))
        path.addLine(to: CGPoint(x: 0.75*width, y: 0.625*height))
        path.addLine(to: CGPoint(x: 0.75*width, y: 0.6875*height))
        path.addLine(to: CGPoint(x: 0.6875*width, y: 0.6875*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.8125*width, y: 0.625*height))
        path.addLine(to: CGPoint(x: 0.875*width, y: 0.625*height))
        path.addLine(to: CGPoint(x: 0.875*width, y: 0.6875*height))
        path.addLine(to: CGPoint(x: 0.8125*width, y: 0.6875*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.875*width, y: 0.5625*height))
        path.addLine(to: CGPoint(x: 0.9375*width, y: 0.5625*height))
        path.addLine(to: CGPoint(x: 0.9375*width, y: 0.625*height))
        path.addLine(to: CGPoint(x: 0.875*width, y: 0.625*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.9375*width, y: 0.75*height))
        path.addLine(to: CGPoint(x: width, y: 0.75*height))
        path.addLine(to: CGPoint(x: width, y: 0.8125*height))
        path.addLine(to: CGPoint(x: 0.9375*width, y: 0.8125*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.5625*width, y: 0.75*height))
        path.addLine(to: CGPoint(x: 0.625*width, y: 0.75*height))
        path.addLine(to: CGPoint(x: 0.625*width, y: 0.8125*height))
        path.addLine(to: CGPoint(x: 0.5625*width, y: 0.8125*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.625*width, y: 0.6875*height))
        path.addLine(to: CGPoint(x: 0.6875*width, y: 0.6875*height))
        path.addLine(to: CGPoint(x: 0.6875*width, y: 0.75*height))
        path.addLine(to: CGPoint(x: 0.625*width, y: 0.75*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.75*width, y: 0.6875*height))
        path.addLine(to: CGPoint(x: 0.8125*width, y: 0.6875*height))
        path.addLine(to: CGPoint(x: 0.8125*width, y: 0.75*height))
        path.addLine(to: CGPoint(x: 0.75*width, y: 0.75*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.8125*width, y: 0.75*height))
        path.addLine(to: CGPoint(x: 0.875*width, y: 0.75*height))
        path.addLine(to: CGPoint(x: 0.875*width, y: 0.8125*height))
        path.addLine(to: CGPoint(x: 0.8125*width, y: 0.8125*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.875*width, y: 0.6875*height))
        path.addLine(to: CGPoint(x: 0.9375*width, y: 0.6875*height))
        path.addLine(to: CGPoint(x: 0.9375*width, y: 0.75*height))
        path.addLine(to: CGPoint(x: 0.875*width, y: 0.75*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.9375*width, y: 0.875*height))
        path.addLine(to: CGPoint(x: width, y: 0.875*height))
        path.addLine(to: CGPoint(x: width, y: 0.9375*height))
        path.addLine(to: CGPoint(x: 0.9375*width, y: 0.9375*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.625*width, y: 0.8125*height))
        path.addLine(to: CGPoint(x: 0.6875*width, y: 0.8125*height))
        path.addLine(to: CGPoint(x: 0.6875*width, y: 0.875*height))
        path.addLine(to: CGPoint(x: 0.625*width, y: 0.875*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.6875*width, y: 0.875*height))
        path.addLine(to: CGPoint(x: 0.75*width, y: 0.875*height))
        path.addLine(to: CGPoint(x: 0.75*width, y: 0.9375*height))
        path.addLine(to: CGPoint(x: 0.6875*width, y: 0.9375*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.75*width, y: 0.8125*height))
        path.addLine(to: CGPoint(x: 0.8125*width, y: 0.8125*height))
        path.addLine(to: CGPoint(x: 0.8125*width, y: 0.875*height))
        path.addLine(to: CGPoint(x: 0.75*width, y: 0.875*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.8125*width, y: 0.875*height))
        path.addLine(to: CGPoint(x: 0.875*width, y: 0.875*height))
        path.addLine(to: CGPoint(x: 0.875*width, y: 0.9375*height))
        path.addLine(to: CGPoint(x: 0.8125*width, y: 0.9375*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.625*width, y: 0.9375*height))
        path.addLine(to: CGPoint(x: 0.6875*width, y: 0.9375*height))
        path.addLine(to: CGPoint(x: 0.6875*width, y: height))
        path.addLine(to: CGPoint(x: 0.625*width, y: height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.75*width, y: 0.9375*height))
        path.addLine(to: CGPoint(x: 0.8125*width, y: 0.9375*height))
        path.addLine(to: CGPoint(x: 0.8125*width, y: height))
        path.addLine(to: CGPoint(x: 0.75*width, y: height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.875*width, y: 0.9375*height))
        path.addLine(to: CGPoint(x: 0.9375*width, y: 0.9375*height))
        path.addLine(to: CGPoint(x: 0.9375*width, y: height))
        path.addLine(to: CGPoint(x: 0.875*width, y: height))
        path.closeSubpath()
        return path
    }
}
