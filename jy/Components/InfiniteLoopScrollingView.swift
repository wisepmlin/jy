//
//  LoopingScrollView.swift
//  InfiniteLoopingScrollView
//
//  Created by Alexandr Grigorjev on 28.11.2023.
//

import SwiftUI

struct InfiniteLoopScrollingView<Content: View, Item: RandomAccessCollection>: View where Item.Element: Identifiable {
    // MARK: - Properties

    var width: CGFloat
    var spacing: CGFloat = 0
    let items: Item
    @ViewBuilder var content: (Item.Element) -> Content

    // Auto-scroll related properties
    var autoScroll: Bool = false
    var scrollSpeed: CGFloat = 20  // 每秒滚动的像素数
    @State private var isUserInteracting: Bool = false

    init(
        width: CGFloat,
        spacing: CGFloat = 0,
        items: Item,
        autoScroll: Bool = false,
        @ViewBuilder content: @escaping (Item.Element) -> Content
    ) {
        self.width = width
        self.spacing = spacing
        self.items = items
        self.autoScroll = autoScroll
        self.content = content
    }

    // MARK: - UI

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            VStack(alignment: .leading, spacing: spacing) {
                LazyHStack(spacing: spacing) {
                    Group {
                        ForEach(0..<5) { _ in
                            ForEach(items.enumerated().filter { $0.offset % 3 == 0 }, id: \.element.id) { _, item in
                                content(item)
                            }
                        }
                    }
                }
                LazyHStack(spacing: spacing) {
                    Group {
                        ForEach(0..<5) { _ in
                            ForEach(items.enumerated().filter { $0.offset % 3 == 1 }, id: \.element.id) { _, item in
                                content(item)
                            }
                        }
                    }
                }
                LazyHStack(spacing: spacing) {
                    Group {
                        ForEach(0..<5) { _ in
                            ForEach(items.enumerated().filter { $0.offset % 3 == 2 }, id: \.element.id) { _, item in
                                content(item)
                            }
                        }
                    }
                }
            }
            .background {
                ScrollViewLoopHelper(
                    width: width,
                    spacing: spacing,
                    itemCount: items.count,
                    autoScroll: autoScroll,
                    scrollSpeed: scrollSpeed,
                    isUserInteracting: $isUserInteracting
                )
            }
        }
    }
}

// MARK: - ScrollViewHelper

/// We need to add this helper view to the background of the LazyHStack
fileprivate struct ScrollViewLoopHelper: UIViewRepresentable {
    var width: CGFloat
    var spacing: CGFloat
    var itemCount: Int
    var autoScroll: Bool
    var scrollSpeed: CGFloat
    @Binding var isUserInteracting: Bool
    
    func makeCoordinator() -> LoopCoordinator {
        return LoopCoordinator(
            width: width,
            spacing: spacing,
            itemCount: itemCount,
            autoScroll: autoScroll,
            scrollSpeed: scrollSpeed,
            isUserInteracting: $isUserInteracting
        )
    }
    
    func makeUIView(context: Context) -> UIView {
        return .init()
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async{
            if let scrollView = uiView.superview?.superview?.superview as? UIScrollView,
               !context.coordinator.isAdded {
                scrollView.delegate = context.coordinator
                context.coordinator.scrollView = scrollView
                context.coordinator.scrollView?.backgroundColor = .clear
                context.coordinator.isAdded = true
                context.coordinator.setupAutoScroll()
            }
        }
        
        context.coordinator.autoScroll = autoScroll
        context.coordinator.scrollSpeed = scrollSpeed
    }
}

class LoopCoordinator: NSObject, UIScrollViewDelegate {
    var width: CGFloat
    var spacing: CGFloat
    var itemCount: Int
    var autoScroll: Bool
    var scrollSpeed: CGFloat
    @Binding var isUserInteracting: Bool
    
    weak var scrollView: UIScrollView?
    private var displayLink: CADisplayLink?
    var isAdded: Bool = false
    
    private var totalContentWidth: CGFloat {
        return (CGFloat(itemCount) * width) + (CGFloat(itemCount) * spacing)
    }
    
    init(
        width: CGFloat,
        spacing: CGFloat,
        itemCount: Int,
        autoScroll: Bool,
        scrollSpeed: CGFloat,
        isUserInteracting: Binding<Bool>
    ) {
        self.width = width
        self.spacing = spacing
        self.itemCount = itemCount
        self.autoScroll = autoScroll
        self.scrollSpeed = scrollSpeed
        self._isUserInteracting = isUserInteracting
        super.init()
    }
    
    func setupAutoScroll() {
        displayLink?.invalidate()
        displayLink = CADisplayLink(target: self, selector: #selector(updateScrollOffset))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    @objc private func updateScrollOffset() {
        guard let scrollView = scrollView,
              autoScroll && !isUserInteracting else { return }
        
        let currentOffset = scrollView.contentOffset.x
        let contentWidth = totalContentWidth
        
        // 计算新的偏移量 - 改为减法使其向右滚动
        var newOffset = currentOffset - (scrollSpeed / 60.0)
        
        // 处理循环逻辑 - 修改边界检查
        if newOffset <= 0 {
            newOffset += contentWidth * 2
            scrollView.contentOffset.x = newOffset
        } else if newOffset >= contentWidth * 3 {
            newOffset -= contentWidth * 2
            scrollView.contentOffset.x = newOffset
        } else {
            scrollView.contentOffset.x = newOffset
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isUserInteracting = true
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            handleScrollEnd()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        handleScrollEnd()
    }
    
    private func handleScrollEnd() {
        // 延迟恢复自动滚动
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.isUserInteracting = false
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.x
        let contentWidth = totalContentWidth
        
        // 修改处理手动滚动的循环逻辑
        if isUserInteracting {
            if currentOffset >= contentWidth * 3 {
                scrollView.contentOffset.x = currentOffset - contentWidth * 2
            } else if currentOffset <= 0 { // 修改这里的判断条件
                scrollView.contentOffset.x = currentOffset + contentWidth * 2
            }
        }
    }
    
    deinit {
        displayLink?.invalidate()
    }
}


