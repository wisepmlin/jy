//
//  FlowLayout.swift
//  jy
//
//  Created by 林晓彬 on 2025/2/1.
//
import SwiftUI

// 添加 FlowLayout 布局组件
struct FlowLayout: Layout {
    var spacing: CGFloat
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 0
        var height: CGFloat = 0
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            
            if x + size.width > width {
                // 换行
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            
            // 更新行高
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            
            // 更新总高度
            height = max(height, y + rowHeight)
        }
        
        return CGSize(width: width, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0
        let width = bounds.width
        
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            
            if x + size.width > width + bounds.minX {
                // 换行
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            
            view.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
            
            // 更新行高和x坐标
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }
    }
}
