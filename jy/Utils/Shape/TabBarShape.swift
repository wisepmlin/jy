//
//  TabBarShape.swift
//  jy
//
//  Created by 林晓彬 on 2025/1/28.
//
import SwiftUI

/// 自定义标签栏形状组件
struct TabBarShape: Shape {
    // MARK: - Properties
    
    /// 圆角半径，控制标签栏四角和凹陷过渡的圆滑程度
    var radius: CGFloat = 34.0
    
    /// 中心凹陷的垂直偏移量，控制凹陷的深度
    var offsetY: CGFloat = 20.0
    
    /// 中心凹陷的宽度比例，控制凹陷的水平范围
    var centerWidthRatio: CGFloat = 0.04
    
    // MARK: - Shape Protocol Implementation
    
    /// 绘制标签栏的自定义形状
    /// - Parameter rect: 绘制的目标区域
    /// - Returns: 标签栏的自定义路径
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let v = radius * 2 // 直径，用于计算凹陷大小
        let width = rect.size.width
        let height = rect.size.height
        
        // 从左上角开始绘制
        path.move(to: CGPoint(x: 0, y: 0))
        
        // 绘制左上角圆角
        path.addArc(
            center: CGPoint(x: radius/2, y: radius/2),
            radius: radius/2,
            startAngle: Angle(degrees: 180),
            endAngle: Angle(degrees: 270),
            clockwise: false
        )
        
        // 绘制左侧凹陷过渡曲线
        path.addArc(
            center: CGPoint(x: ((width / 2) - radius) - radius + v * centerWidthRatio + radius/2, y: radius/2),
            radius: radius/2,
            startAngle: Angle(degrees: 270),
            endAngle: Angle(degrees: 340),
            clockwise: false
        )
        
        // 绘制中心凹陷曲线
        path.addArc(
            center: CGPoint(x: width / 2, y: offsetY),
            radius: v/2,
            startAngle: Angle(degrees: 160),
            endAngle: Angle(degrees: 20),
            clockwise: true
        )
        
        // 绘制右侧凹陷过渡曲线
        path.addArc(
            center: CGPoint(x: (width - ((width / 2) - radius)) - v * centerWidthRatio + radius/2, y: radius/2),
            radius: radius/2,
            startAngle: Angle(degrees: 200),
            endAngle: Angle(degrees: 270),
            clockwise: false
        )
        
        // 绘制右上角圆角
        path.addArc(
            center: CGPoint(x: width - radius/2, y: radius/2),
            radius: radius/2,
            startAngle: Angle(degrees: 270),
            endAngle: Angle(degrees: 360),
            clockwise: false
        )
        
        // 完成底部边缘
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        
        return path
    }
}
