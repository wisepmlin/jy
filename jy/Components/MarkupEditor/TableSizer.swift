//
//  TableSizer.swift
//  MarkupEditor
//
//  Created by Steven Harris on 5/12/21.
//  Copyright © 2021, 2022 Steven Harris. All rights reserved.
//

import SwiftUI

/// TableSizer 展示一个网格供用户选择要创建的表格大小。
///
/// TableSizer 的一个难点是如何同时处理鼠标和触摸设备。
/// 特别是，当使用鼠标时，基于悬停的高亮显示非常好用，
/// 但在触摸设备上，你需要拖动才能看到手势效果。当你通过悬停来设置
/// 表格大小时，你需要使用一个确认手势来表示完成，
/// 这个确认手势是在 TableSizer 网格中的点击。
///
/// 如果你在没有鼠标的触摸设备上，悬停不会有任何效果，所以
/// 行数和列数保持为0直到你开始拖动。如果你在触摸设备上拖动，
/// 那么当你停止拖动时，表格会被插入，所以你不需要点击。
/// 你也可以用鼠标拖动，这种情况下它的行为类似于
/// 标准的拖动行为，当你停止拖动时会关闭并插入表格。
///
/// 行数和列数设置为0表示表格不应该被调整大小。这种情况
/// 发生在鼠标或拖动位置在TableSizer网格之外时，或者
/// （从某种意义上说）点击在TableSizer网格之外时。
struct TableSizer: View {
    @Environment(\.theme) private var theme
    // 最大行数
    let maxRows: Int = 6
    // 最大列数
    let maxCols: Int = 8
    // 单元格大小
    let cellSize: CGFloat = 16
    // 选中区域的颜色
    let sizedColor = Color.accentColor.opacity(0.2)
    //TODO: 这是一个临时解决方案，因为我找不到让弹出框在两种环境中都看起来正确的方法
    #if targetEnvironment(macCatalyst)
    let topPadding: CGFloat = 8
    let bottomPadding: CGFloat = 8
    #else
    let topPadding: CGFloat = 0
    let bottomPadding: CGFloat = 20
    #endif
    // 行数绑定
    @Binding var rows: Int
    // 列数绑定
    @Binding var cols: Int
    // 显示状态绑定
    @Binding var showing: Bool
    // 是否正在拖动
    @State var dragged: Bool = false
    // 背景宽度
    @State private var backgroundWidth = CGFloat.zero
    // 背景高度
    @State private var backgroundHeight = CGFloat.zero
    
    var body: some View {
        // 拖动手势
        let dragGesture = DragGesture()
            .onChanged { value in
                dragged = true
                let location = value.location
                let colCount = (location.x / cellSize).rounded(.awayFromZero)
                let rowCount  = (location.y / cellSize).rounded(.awayFromZero)
                cols = Int(colCount)
                rows = Int(rowCount)
                if (cols > maxCols || rows > maxRows) {
                    rows = 0
                    cols = 0
                }
                setBackground()
            }
            .onEnded { _ in
                showing.toggle()
            }
        // 点击手势
        let tapGesture = TapGesture()
            .onEnded {
                showing.toggle()
            }
        VStack(spacing: 4) {
            // 显示表格大小或提示文本
            if rows > 0 && cols > 0 {
                Text("\(rows)x\(cols) table").foregroundColor(Color.black)
            } else {
                Text("表格大小").foregroundColor(Color.black)
            }
            ZStack(alignment: .topLeading) {
                // 选中区域背景
                Rectangle()
                    .foregroundColor(sizedColor)
                    .frame(width: backgroundWidth, height: backgroundHeight)
                // 表格网格
                VStack(spacing: 0) {
                    ForEach(0..<maxRows, id: \.self) { row in
                        HStack(spacing: 0) {
                            ForEach(0..<maxCols, id: \.self) { col in
                                Rectangle()
                                    .stroke(theme.jyxqPrimary, lineWidth: 0.5)
                                    .frame(width: cellSize, height: cellSize)
                                    .background(Color.clear)
                                    .foregroundColor(Color.clear)
                                    .contentShape(Rectangle())
                                    .onHover { hovering in
                                        if hovering && !dragged {
                                            rows = row + 1
                                            cols = col + 1
                                            if (cols > maxCols || rows > maxRows) {
                                                rows = 0
                                                cols = 0
                                            }
                                            setBackground()
                                        }
                                    }
                            }
                        }
                    }
                }
            }
            .highPriorityGesture(tapGesture)
            .onHover { hovering in
                // 让用户直观地知道表格不会被调整大小
                // 用dragged进行保护，因为onHover可能在onEnded之后发生，
                // 这会导致没有表格被创建
                if !dragged {
                    rows = 0
                    cols = 0
                }
                setBackground()
            }
            .gesture(dragGesture)
        }
        .padding(EdgeInsets(top: topPadding, leading: 8, bottom: bottomPadding, trailing: 8))
    }
    
    init(rows: Binding<Int>, cols: Binding<Int>, showing: Binding<Bool>) {
        // TableSizer应该总是以零行和零列打开，因为它只用于创建新表格
        _rows = rows
        _cols = cols
        _showing = showing
    }
    
    // 设置背景尺寸
    private func setBackground() {
        backgroundWidth = CGFloat(cols) * cellSize
        backgroundHeight = CGFloat(rows) * cellSize
    }
}

// 预览提供者
struct TableSizer_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            HStack {
                TableSizer(rows: .constant(3), cols: .constant(3), showing: .constant(true))
                Spacer()
            }
            Spacer()
        }
    }
}
