//
//  MarkupEditor.swift
//  MarkupEditor
//
//  Created by Steven Harris on 8/8/22.
//

import SwiftUI
import UniformTypeIdentifiers

/// MarkupEditor结构体持有工具栏、视图和其他机制所需的所有状态
///
/// 所有状态都保存在静态变量中以提供方便的访问。MarkupEditor持有工具栏使用的多个ObservableObjects
@MainActor
public struct MarkupEditor {
    // 观察第一响应者
    public static var observedFirstResponder = ObservedFirstResponder()
    // 第一响应者ID
    public static var firstResponder: String? {
        get { observedFirstResponder.id }
        set { observedFirstResponder.id = newValue }
    }
    // 顶层属性配置
    public static var topLevelAttributes: [String : String] = [
        "contenteditable" : "true",
        "spellcheck" : "false",
        "autocorrect" : "true"
    ]
    // 标记菜单
    public static let markupMenu = MarkupMenu()
    // 工具栏内容
    public static let toolbarContents = ToolbarContents.shared
    // 工具栏样式
    public static let toolbarStyle = ToolbarStyle()
    // 工具栏位置
    public static var toolbarLocation = ToolbarLocation.automatic
    // 左侧工具栏
    public static var leftToolbar: AnyView? {
        didSet {
            toolbarContents.leftToolbar = leftToolbar != nil
        }
    }
    // 右侧工具栏
    public static var rightToolbar: AnyView? {
        didSet {
            toolbarContents.rightToolbar = rightToolbar != nil
        }
    }
    // 观察的WebView
    public static let observedWebView = ObservedWebView()
    // 当前选中的WebView
    public static var selectedWebView: MarkupWKWebView? {
        get { observedWebView.selectedWebView }
        set { observedWebView.selectedWebView = newValue }
    }
    // 选择状态
    public static let selectionState = SelectionState()
    // 搜索激活状态
    public static let searchActive = SearchActive()
    // 选择图片状态
    public static let selectImage = SelectImage()
    // 显示插入弹出框状态
    public static let showInsertPopover = ShowInsertPopover()
    // 支持的图片类型
    public static let supportedImageTypes: [UTType] = [.image, .movie]
    // 工具栏样式
    public static var style: ToolbarStyle.Style = .labeled {
        didSet {
            toolbarStyle.style = style
        }
    }
    // 是否允许本地图片
    public static var allowLocalImages: Bool = false
    // 设置为true以允许在iOS/macCatalyst 16.4或更高版本的Safari开发菜单中检查MarkupWKWebView
    // 默认为false以与WKWebView默认值保持一致
    public static var isInspectable: Bool = false
    
    // 初始化菜单
    public static func initMenu(with builder: UIMenuBuilder) {
        markupMenu.initMenu(with: builder)
    }
    
    // 搜索方向枚举
    public enum FindDirection {
        case forward    // 向前
        case backward   // 向后
    }
    
    // 表格方向枚举，用于添加行和列
    // 用于图标和MarkupWKWebView
    // "before"表示列的左侧，"after"表示列的右侧
    // "before"表示行的上方，"after"表示行的下方
    public enum TableDirection {
        case before    // 之前
        case after     // 之后
    }

    // 表格边框样式枚举
    public enum TableBorder: String {
        case outer     // 外边框
        case header    // 表头边框
        case cell      // 单元格边框
        case none      // 无边框
    }

    // 工具栏位置枚举，用于控制MarkupEditorView和MarkupEditorUIView中的工具栏位置
    @MainActor
    public enum ToolbarLocation {
        case top       // 顶部
        case bottom    // 底部
        case keyboard  // 键盘
        case none      // 无
        
        // 自动判断工具栏位置
        static var automatic: ToolbarLocation {
            switch UIDevice.current.userInterfaceIdiom {
            case .mac, .pad:
                return .top
            case .phone:
                return .keyboard
            default:
                return .top
            }
        }
    }
    
    // 判断当前设备类型
    @MainActor
    public static func userInterfaceIdiom(is idiom: UIUserInterfaceIdiom) -> Bool {
        UIDevice.current.userInterfaceIdiom == idiom
    }

}

// 观察第一响应者的类
public class ObservedFirstResponder: ObservableObject {
    @Published public var id: String?
}

// 包含selectedWebView的可观察对象
// 当单个MarkupToolbar与多个MarkupWKWebViews一起使用时，
// 需要能够跟踪选择了哪个WebView，以便MarkupToolbar正确反映其状态
public class ObservedWebView: ObservableObject, Identifiable {
    @Published public var selectedWebView: MarkupWKWebView?
    public var id: UUID = UUID()
    
    public init(_ webView: MarkupWKWebView? = nil) {
        selectedWebView = webView
    }
}

// 包含用于选择本地图片的DocumentPicker显示状态的Bool值的可观察对象
public class SelectImage: ObservableObject {
    @Published public var value: Bool
    
    public init(_ value: Bool = false) {
        self.value = value
    }
}

// 包含"搜索模式"是否激活的Bool值的可观察对象
// 在搜索模式下，Enter/Shift+Enter被解释为searchForward/searchBackward
// 此时MarkupToolbar通常应该被禁用
public class SearchActive: ObservableObject {
    @Published public var value: Bool
    
    public init(_ value: Bool = false) {
        self.value = value
    }
}

// 包含应显示的弹出框类型或无的可观察对象
// 该值由InsertToolbar用于显示默认的TableSizer和TableToolbar
public class ShowInsertPopover: ObservableObject, Equatable {
    
    public static func == (lhs: ShowInsertPopover, rhs: ShowInsertPopover) -> Bool {
        guard let lType = lhs.type, let rType = rhs.type else { return false }
        return lType == rType
    }
    
    @Published public var type: ToolbarContents.PopoverType?
}
