//
//  Icons.swift
//  MarkupEditor
//
//  Created by Steven Harris on 5/17/21.
//  Copyright © 2021 Steven Harris. All rights reserved.
//

import SwiftUI

//MARK: Table Icons

/// 表格图标视图结构体
struct TableIcon: View {
    // 定义TableBorder类型别名
    typealias TableBorder = MarkupEditor.TableBorder
    
    // 控制图标是否处于激活状态的绑定变量
    @Binding var active: Bool
    
    // 表格的行数
    var rows: Int
    // 表格的列数
    var cols: Int
    // 内边距
    var inset: CGFloat
    // 选中的行索引
    var selectRow: Int?
    // 选中的列索引
    var selectCol: Int?
    // 是否包含表头
    var withHeader: Bool
    // 要删除的行索引数组
    var deleteRows: [Int]?
    // 要删除的列索引数组
    var deleteCols: [Int]?
    // 表格边框样式
    var border: TableBorder
    
    var body: some View {
        // 使用GeometryReader获取视图尺寸
        GeometryReader() { geometry in
            // 获取总宽度和高度
            let width = geometry.size.width
            let height = geometry.size.height
            // 计算单元格宽度和高度
            let cellWidth = width / CGFloat(cols)
            let cellHeight = height / CGFloat(rows)
            
            // 创建垂直堆栈视图
            VStack(spacing: 0) {
                // 遍历创建行
                ForEach(0..<rows, id: \.self) { row in
                    // 创建水平堆栈视图
                    HStack(spacing: 0) {
                        // 遍历创建列
                        ForEach(0..<cols, id: \.self) { col in
                            // 判断单元格是否被选中
                            let select = row == selectRow || col == selectCol
                            // 判断单元格是否被标记为删除
                            let delete = deleteRows?.contains(row) ?? false || deleteCols?.contains(col) ?? false
                            // 创建表格单元格
                            TableCell(
                                width: cellWidth,
                                height: cellHeight,
                                selected: select,
                                deleted: delete
                            )
                        }
                    }
                }
            }
            .frame(width: width, height: height)
            // 添加表格边框
            .overlay(
                TableIconBorder(active: $active, width: width, height: height, rows: rows, cols: cols, withHeader: withHeader, border: border)
            )
        }
        .padding([.all], inset)
    }
    
    // 初始化方法
    init(active: Binding<Bool>? = nil, rows: Int = 3, cols: Int = 3, inset: CGFloat = 3, selectRow: Int? = nil, selectCol: Int? = nil, withHeader: Bool = false, deleteRows: [Int]? = nil, deleteCols: [Int]? = nil, border: TableBorder = .none) {
        // 设置激活状态绑定
        if let active = active {
            _active = active
        } else {
            _active = .constant(false)
        }
        // 初始化其他属性
        self.rows = rows
        self.cols = cols
        self.inset = inset
        self.selectRow = selectRow
        self.selectCol = selectCol
        self.withHeader = withHeader
        self.deleteRows = deleteRows
        self.deleteCols = deleteCols
        self.border = border
    }
}

/// 表格单元格视图
struct TableCell: View {
    @Environment(\.theme) private var theme
    // 单元格宽度
    let width: CGFloat
    // 单元格高度
    let height: CGFloat
    // 是否被选中
    let selected: Bool
    // 是否被标记为删除
    let deleted: Bool
    
    var body: some View {
        ZStack {
            // 绘制单元格背景矩形
            Rectangle()
                .frame(width: width, height: height)
                .foregroundColor(selected ? theme.jyxqPrimary.opacity(0.3) : Color (UIColor.systemBackground).opacity(0.3))
            
            // 如果单元格被标记为删除，显示红色X图标
            if deleted {
                Image(systemName: "xmark")
                    .foregroundColor(Color.red)
                    .font(Font.system(size: min(width, height) - 2).weight(.bold))
            }
        }
    }
}

/// 表格边框视图
struct TableIconBorder: View {
    // 定义TableBorder类型别名
    typealias TableBorder = MarkupEditor.TableBorder
    // 控制边框是否处于激活状态
    @Binding var active: Bool
    // 边框总宽度
    let width: CGFloat
    // 边框总高度
    let height: CGFloat
    // 行数
    let rows: Int
    // 列数
    let cols: Int
    // 是否包含表头
    let withHeader: Bool
    // 边框样式
    let border: TableBorder
    
    // 边框颜色计算属性
    var borderColor: Color { active ? EdgeColor.activeBorder : EdgeColor.inactiveBorder }
    // 轮廓颜色计算属性
    var outlineColor: Color { active ? EdgeColor.activeOutline : EdgeColor.inactiveOutline }

    // 边缘颜色定义
    private struct EdgeColor {
        static let activeBorder: Color = Color(UIColor.systemBackground)
        static let activeOutline: Color = Color(UIColor.systemBackground)
        static let inactiveBorder: Color = Color("brandPrimary")
        static let inactiveOutline: Color = Color("brandPrimary")
    }

    // 边缘宽度定义
    private struct EdgeWidth {
        static let border: CGFloat = 2
        static let outline: CGFloat = 1
    }
    
    var body: some View {
        // 计算外边框厚度和颜色
        let outerThickness = border == .none ? EdgeWidth.outline : EdgeWidth.border
        let outerColor = border == .none ? outlineColor : borderColor
        // 计算单元格尺寸
        let cellWidth = width / CGFloat(cols)
        let cellHeight = height / CGFloat(rows)
        
        ZStack(alignment: .topLeading) {
            // 绘制外边框矩形
            Rectangle()
                .stroke(outerColor, lineWidth: outerThickness)
                .foregroundColor(Color.clear)
            
            // 绘制行分隔线
            ForEach(0..<rows, id:\.self) { row in
                let rowTopLineWidth = row == 0 ? outerThickness : rowLineWidth(for: row - 1)
                let rowBottomLineWidth = rowLineWidth(for: row)
                let rowBottomColor = rowColor(for: row)
                
                // 创建行分隔线
                TableBorderRowSeparator(
                    row: row,
                    rows: rows,
                    rowWidth: width,
                    cellHeight: cellHeight,
                    color: rowBottomColor,
                    lineWidth: rowBottomLineWidth,
                    outerThickness: outerThickness)
                
                // 绘制列分隔线
                ForEach(0..<cols-1, id: \.self) { col in
                    let isHeader = withHeader ? row == 0 : false
                    let colTrailingColor = isHeader ? Color.clear : colColor(for: col)
                    let colTrailingLineWidth = colLineWidth(for: col)
                    
                    // 创建列分隔线
                    TableBorderColSeparator(
                        row: row,
                        col: col,
                        cellWidth: cellWidth,
                        cellHeight: cellHeight,
                        rowTopLineWidth: rowTopLineWidth,
                        rowBottomLineWidth: rowBottomLineWidth,
                        color: colTrailingColor,
                        lineWidth: colTrailingLineWidth)
                }
            }
        }
    }
    
    /// 获取行底边的颜色
    private func rowColor(for row: Int) -> Color {
        var color: Color
        switch border {
        case .outer, .none:
            color = outlineColor
        case .header:
            if row == 0 {
                color = borderColor
            } else {
                color = outlineColor
            }
        case .cell:
            color = borderColor
        }
        return color
    }
    
    /// 获取行底边的线宽
    private func rowLineWidth(for row: Int) -> CGFloat {
        var thickness: CGFloat
        switch border {
        case .outer, .none:
            thickness = EdgeWidth.outline
        case .header:
            if row == 0 {
                thickness = EdgeWidth.border
            } else {
                thickness = EdgeWidth.outline
            }
        case .cell:
            thickness = EdgeWidth.border
        }
        return thickness
    }
    
    /// 获取单元格右边的颜色
    private func colColor(for col: Int) -> Color {
        var color: Color
        switch border {
        case .outer, .header, .none:
            color = outlineColor
        case .cell:
            color = borderColor
        }
        return color
    }

    /// 获取单元格右边的线宽
    private func colLineWidth(for col: Int) -> CGFloat {
        var thickness: CGFloat
        switch border {
        case .outer, .header, .none:
            thickness = EdgeWidth.outline
        case .cell:
            thickness = EdgeWidth.border
        }
        return thickness
    }
}

/// 表格行分隔线视图
struct TableBorderRowSeparator: View {
    // 当前行索引
    let row: Int
    // 总行数
    let rows: Int
    // 行宽度
    let rowWidth: CGFloat
    // 单元格高度
    let cellHeight: CGFloat
    // 分隔线颜色
    let color: Color
    // 线宽
    let lineWidth: CGFloat
    // 外边框厚度
    let outerThickness: CGFloat
    
    var body: some View {
        // 判断是否隐藏行分隔线(最后一行不绘制底部分隔线)
        let hideRowSeparator = row == rows - 1
        if !hideRowSeparator {
            // 计算行底部偏移量
            let rowBottomOffset = cellHeight * CGFloat(row + 1)
            // 绘制水平分隔线路径
            Path { path in
                path.move(to: CGPoint.zero)
                path.addLine(to: CGPoint(x: rowWidth - outerThickness, y: 0))
            }
            .offset(x: outerThickness / 2, y: rowBottomOffset)
            .stroke(color, lineWidth: lineWidth)
        } else {
            EmptyView()
        }
    }
}

/// 表格列分隔线视图
struct TableBorderColSeparator: View {
    // 行索引
    let row: Int
    // 列索引
    let col: Int
    // 单元格宽度
    let cellWidth: CGFloat
    // 单元格高度
    let cellHeight: CGFloat
    // 行顶部线宽
    let rowTopLineWidth: CGFloat
    // 行底部线宽
    let rowBottomLineWidth: CGFloat
    // 分隔线颜色
    let color: Color
    // 线宽
    let lineWidth: CGFloat
    
    var body: some View {
        // 计算行顶部偏移量
        let rowTopOffset = cellHeight * CGFloat(row)
        // 计算列分隔线高度
        let colSeparatorHeight = cellHeight - (rowTopLineWidth + rowBottomLineWidth) / 2
        // 计算列X轴偏移量
        let colXOffset = cellWidth * CGFloat(col + 1)
        // 绘制垂直分隔线路径
        Path { path in
            path.move(to: CGPoint.zero)
            path.addLine(to: CGPoint(x: 0, y: colSeparatorHeight))
        }
        .offset(x: colXOffset, y: rowTopOffset + rowTopLineWidth / 2)
        .stroke(color, lineWidth: lineWidth)
    }
}

/// 添加行视图
struct AddRow: View {
    typealias TableDirection = MarkupEditor.TableDirection
    // 添加方向(前/后)
    let direction: TableDirection
    
    var body: some View {
        VStack(spacing: -6) {
            if direction == .after {
                // 在后面添加行
                ZStack(alignment: .bottom) {
                    TableIcon(rows: 3, cols: 3, selectRow: 2)
                    // 向下箭头图标
                    Image(systemName: "arrow.down")
                        .offset(CGSize(width: 0, height: -4))
                        .foregroundColor(Color.red)
                        .font(Font.system(size: 12).weight(.bold))
                        .zIndex(1)
                }
            } else {
                // 在前面添加行
                ZStack(alignment: .top) {
                    // 向上箭头图标
                    Image(systemName: "arrow.up")
                        .offset(CGSize(width: 0, height: 4))
                        .foregroundColor(Color.red)
                        .font(Font.system(size: 12).weight(.bold))
                        .zIndex(1)
                    TableIcon(rows: 3, cols: 3, selectRow: 0)
                }
            }
        }
    }
}

/// 添加列视图
struct AddCol: View {
    typealias TableDirection = MarkupEditor.TableDirection
    // 添加方向(前/后)
    let direction: TableDirection
    
    var body: some View {
        HStack(spacing: -6) {
            if direction == .after {
                // 在后面添加列
                ZStack(alignment: .trailing) {
                    TableIcon(rows: 3, cols: 3, selectCol: 2)
                    // 向右箭头图标
                    Image(systemName: "arrow.right")
                        .offset(CGSize(width: -4, height: 0))
                        .foregroundColor(Color.red)
                        .font(Font.system(size: 12).weight(.bold))
                        .zIndex(1)
                }
            } else {
                // 在前面添加列
                ZStack(alignment: .leading) {
                    // 向左箭头图标
                    Image(systemName: "arrow.left")
                        .offset(CGSize(width: 4, height: 0))
                        .foregroundColor(Color.red)
                        .font(Font.system(size: 12).weight(.bold))
                            .zIndex(1)
                    TableIcon(rows: 3, cols: 3, selectCol: 0)
                }
            }
        }
    }
}

/// 添加表头视图
struct AddHeader: View {
    var body: some View {
        ZStack(alignment: .top) {
            TableIcon(rows: 3, cols: 3, selectRow: 0, withHeader: true)
            // 向上箭头图标
            Image(systemName: "arrow.up")
                .offset(CGSize(width: 0, height: 4))
                .foregroundColor(Color.red)
                .font(Font.system(size: 12).weight(.bold))
                .zIndex(1)
        }
    }
}

/// 删除行视图
struct DeleteRow: View {
    var body: some View {
        TableIcon(rows: 3, cols: 3, selectRow: 1, deleteRows: [1])
    }
}

/// 删除列视图
struct DeleteCol: View {
    var body: some View {
        TableIcon(rows: 3, cols: 3, selectCol: 1, deleteCols: [1])
    }
}

/// 删除表格视图
struct DeleteTable: View {
    var body: some View {
        TableIcon(rows: 3, cols: 3, deleteRows: [0, 1, 2])
    }
}

/// 创建表格视图
struct CreateTable: View {
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            TableIcon(rows: 3, cols: 3, selectRow: 2, selectCol: 2)
            // 右下箭头图标
            Image(systemName: "arrow.down.forward")
                .offset(CGSize(width: -4, height: -4))
                .foregroundColor(Color.red)
                .font(Font.system(size: 12).weight(.bold))
                .zIndex(1)
        }
    }
}

/// 边框图标视图
struct BorderIcon: View {
    typealias TableBorder = MarkupEditor.TableBorder
    // 是否激活状态
    @Binding var active: Bool
    // 边框样式
    var border: TableBorder = .none
    
    var body: some View {
        TableIcon(active: $active, rows: 3, cols: 3, withHeader: true, border: border)
    }
    
    // 初始化方法
    init(_ border: TableBorder = .none, active: Binding<Bool>? = nil) {
        self.border = border
        if let active = active {
            _active = active
        } else {
            _active = .constant(false)
        }
    }
}

/// 表格图标预览
struct TableIcon_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            HStack(alignment: .top) {
                // 基础表格图标组
                Group {
                    TableIcon()
                        .frame(width: 30, height: 30)
                    CreateTable()
                        .frame(width: 30, height: 30)
                }
                Divider()
                // 添加操作图标组
                Group {
                    AddHeader()
                        .frame(width: 30, height: 30)
                    AddRow(direction: .after)
                        .frame(width: 30, height: 30)
                    AddRow(direction: .before)
                        .frame(width: 30, height: 30)
                    AddCol(direction: .after)
                        .frame(width: 30, height: 30)
                    AddCol(direction: .before)
                        .frame(width: 30, height: 30)
                }
                Divider()
                // 删除操作图标组
                Group {
                    DeleteRow()
                        .frame(width: 30, height: 30)
                    DeleteCol()
                        .frame(width: 30, height: 30)
                    DeleteTable()
                        .frame(width: 30, height: 30)
                }
                Divider()
                // 边框样式图标组
                Group {
                    BorderIcon(.cell)
                        .frame(width: 30, height: 30)
                    BorderIcon(.header)
                        .frame(width: 30, height: 30)
                    BorderIcon(.outer)
                        .frame(width: 30, height: 30)
                    BorderIcon(.none)
                        .frame(width: 30, height: 30)
                }
                Spacer()
            }
            .frame(height: 30)
            Spacer()
        }
    }
}
