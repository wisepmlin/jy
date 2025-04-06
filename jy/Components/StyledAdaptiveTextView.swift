import SwiftUI

/// 一个带有样式的自适应文本输入视图
/// - 支持自动调整高度
/// - 支持占位文本
/// - 支持最大高度限制
/// - 支持焦点状态样式
/// - 支持主题定制
struct StyledAdaptiveTextView: View {
    // MARK: - 环境依赖
    @Environment(\.theme.self) private var theme
    
    // MARK: - 公共属性
    /// 占位文本
    let placeholder: String
    /// 字体大小
    let font: UIFont
    /// 最大高度限制
    let maxHeight: CGFloat
    /// 绑定的文本内容
    @Binding var text: String
    /// 文本高度状态：(是否超过两行, 当前行数)
    @Binding var heighState: (Bool, Int)
    /// 焦点状态绑定
    var isFocused: FocusState<Bool>.Binding
    /// 文本变化回调
    var onTextChange: ((String) -> Void)?
    
    // MARK: - 内部状态
    /// 当前视图高度
    @State private var height: CGFloat = 36
    /// 是否超过两行
    @State private var isLineTwo: Bool = false
    /// 当前行数
    @State private var line: Int = 1
    
    // MARK: - 初始化方法
    /// 创建一个带样式的自适应文本输入视图
    /// - Parameters:
    ///   - placeholder: 占位文本
    ///   - maxHeight: 最大高度限制
    ///   - text: 绑定的文本内容
    ///   - heighState: 文本高度状态绑定
    ///   - isFocused: 焦点状态绑定
    ///   - onTextChange: 文本变化回调
    init(placeholder: String = "想说点什么",
         font: UIFont = .systemFont(ofSize: 16, weight: .regular),
         maxHeight: CGFloat = 240,
         text: Binding<String>,
         heighState: Binding<(Bool, Int)>,
         isFocused: FocusState<Bool>.Binding,
         onTextChange: ((String) -> Void)? = nil
    ) {
        self.placeholder = placeholder
        self.font = font
        self.maxHeight = maxHeight
        self._text = text
        self._heighState = heighState
        self.isFocused = isFocused
        self.onTextChange = onTextChange
    }
    
    // MARK: - 视图构建
    var body: some View {
        // 核心输入组件
        AdaptiveTextView(
            text: $text,
            placeholder: placeholder,
            font: font,
            maxHeight: maxHeight,
            onTextChange: onTextChange,
            onHeightChange: { getHeight in
                // 使用动画更新高度
                withAnimation(.easeInOut(duration: 0.05)) {
                    height = getHeight
                }
            },
            onTextHeightStateChange: { getIsLineTwo, getLine in
                // 使用动画更新文本高度状态
                withAnimation(.easeInOut(duration: 0.05)) {
                    isLineTwo = getIsLineTwo
                    line = getLine
                    heighState = (getIsLineTwo, getLine)
                }
            }
        )
        // 应用主题样式
        .themeFont(theme.fonts.body)
        .frame(height: height, alignment: .bottom)
        // 背景样式
        .background(isFocused.wrappedValue ? theme.background : theme.gray6Background)
        .compositingGroup()
        .cornerRadius(theme.minCornerRadius)
        .shadow(
            color: isFocused.wrappedValue ? theme.jyxqPrimary.opacity(0.35) : .clear,
            radius: isFocused.wrappedValue ? 2 : 0,
            x: 0,
            y: 0
        )
        // 边框效果
        .overlay(
            RoundedRectangle(cornerRadius: theme.minCornerRadius)
                .stroke(isFocused.wrappedValue ? theme.background : .clear, lineWidth: 0.5)
        )
        // 焦点绑定
        .focused(isFocused)
    }
}
