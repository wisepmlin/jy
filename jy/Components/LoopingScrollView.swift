//
//  LoopingScrollView.swift
//  jy
//
//  Created by 林晓彬 on 2025/2/12.
//


//
//  LoopingScrollView.swift
//  InfiniteLoopingScrollView
//
//  Created by Alexandr Grigorjev on 28.11.2023.
//

import SwiftUI

struct LoopingScrollView<Content: View, Item: RandomAccessCollection>: View where Item.Element: Identifiable {
    // MARK: - Properties
    @Environment(\.theme) private var theme
    private let width: CGFloat
    private let spacing: CGFloat
    private let items: Item
    private let autoScroll: Bool
    private let scrollInterval: TimeInterval
    private let showIndicator: Bool
    private let content: (Item.Element) -> Content
    
    // 使用 @StateObject 来确保 ScrollViewModel 的生命周期
    @StateObject private var viewModel: ScrollViewModel
    @Binding private var selectedIndex: Int

    // MARK: - Initialization
    init(
        width: CGFloat,
        spacing: CGFloat = 0,
        items: Item,
        autoScroll: Bool = false,
        scrollInterval: TimeInterval = 3.0,
        showIndicator: Bool = true,
        @ViewBuilder content: @escaping (Item.Element) -> Content
    ) {
        self.width = width
        self.spacing = spacing
        self.items = items
        self.autoScroll = autoScroll
        self.scrollInterval = scrollInterval
        self.showIndicator = showIndicator
        self.content = content
        self._selectedIndex = .constant(0)
        self._viewModel = StateObject(wrappedValue: ScrollViewModel())
    }
    
    init(
        width: CGFloat,
        spacing: CGFloat = 0,
        items: Item,
        autoScroll: Bool = false,
        scrollInterval: TimeInterval = 3.0,
        showIndicator: Bool = true,
        selectedIndex: Binding<Int>,
        @ViewBuilder content: @escaping (Item.Element) -> Content
    ) {
        self.width = width
        self.spacing = spacing
        self.items = items
        self.autoScroll = autoScroll
        self.scrollInterval = scrollInterval
        self.showIndicator = showIndicator
        self.content = content
        self._selectedIndex = selectedIndex
        self._viewModel = StateObject(wrappedValue: ScrollViewModel())
    }

    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            let repeatingCount = calculateRepeatingCount(for: geometry.size)
            
            ZStack(alignment: .bottomTrailing) {
                scrollContent(repeatingCount: repeatingCount)
                if showIndicator {
                    pageIndicator
                }
            }
        }
        .scrollIndicators(.automatic)
        .onAppear(perform: setupAutoScroll)
        .onDisappear(perform: stopAutoScroll)
        .onChange(of: viewModel.currentPage) { oldValue, newValue in
            selectedIndex = newValue
        }
    }
    
    // MARK: - Private Views
    @ViewBuilder
    private var pageIndicator: some View {
        HStack(spacing: 3) {
            ForEach(0..<items.count, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(viewModel.currentPage == index ? theme.jyxqPrimary : Color.white.opacity(0.5))
                    .frame(width: 5, height: 2)
            }
        }
        .padding(6)
        .background(Material.ultraThin)
        .cornerRadius(12)
        .padding([.bottom, .trailing], 8)
    }
    
    @ViewBuilder
    private func scrollContent(repeatingCount: Int) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: spacing) {
                ForEach(items, id: \.id) { item in
                    content(item)
                        .frame(width: width)
                        .containerRelativeFrame(.horizontal, count: 1, spacing: 0)
                }
                ForEach(0..<repeatingCount, id: \.self) { index in
                    let item = Array(items)[index % items.count]
                    content(item)
                        .frame(width: width)
                        .containerRelativeFrame(.horizontal, count: 1, spacing: 0)
                }
            }
            .scrollTargetLayout()
            .background {
                ScrollViewHelper(
                    width: width,
                    spacing: spacing,
                    itemCount: items.count,
                    repeatingCount: repeatingCount,
                    autoScroll: autoScroll,
                    scrollInterval: scrollInterval,
                    currentPage: $viewModel.currentPage
                )
            }
        }
        .scrollTargetBehavior(.paging)
        .scrollIndicators(.never)
    }
    
    // MARK: - Private Methods
    private func calculateRepeatingCount(for size: CGSize) -> Int {
        width > 0 ? Int((size.width / width).rounded()) + 1 : 1
    }
    
    private func setupAutoScroll() {
        viewModel.setupAutoScroll(
            enabled: autoScroll,
            interval: scrollInterval,
            itemCount: items.count
        )
    }
    
    private func stopAutoScroll() {
        viewModel.stopAutoScroll()
    }
}

// MARK: - ViewModel
final class ScrollViewModel: ObservableObject {
    @Published var currentPage: Int = 0
    private var scrollTimer: Timer?
    
    func setupAutoScroll(enabled: Bool, interval: TimeInterval, itemCount: Int) {
        guard enabled else { return }
        
        // 使用 RunLoop 的主线程来处理定时器
        scrollTimer = Timer(timeInterval: interval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                withAnimation(.interpolatingSpring(stiffness: 300, damping: 100)) {
                    self.currentPage = (self.currentPage + 1) % itemCount
                }
            }
        }
        RunLoop.main.add(scrollTimer!, forMode: .common)
    }
    
    func stopAutoScroll() {
        scrollTimer?.invalidate()
        scrollTimer = nil
    }
    
    deinit {
        stopAutoScroll()
    }
}

// MARK: - ScrollViewHelper

/// We need to add this helper view to the background of the LazyHStack
fileprivate struct ScrollViewHelper: UIViewRepresentable {
    var width: CGFloat
    var spacing: CGFloat
    var itemCount: Int
    var repeatingCount: Int
    var autoScroll: Bool
    var scrollInterval: TimeInterval
    @Binding var currentPage: Int

    /// We need to create a coordinator to be able to get the scrollViewDidScroll callback
    func makeCoordinator() -> Coordinator {
        return Coordinator(
            width: width,
            spacing: spacing,
            itemCount: itemCount,
            repeatingCount: repeatingCount,
            autoScroll: autoScroll,
            scrollInterval: scrollInterval,
            currentPage: $currentPage
        )
    }

    /// We need to return an empty view here
    func makeUIView(context: Context) -> UIView {
        return .init()
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            if let
                scrollView = uiView.superview?.superview?.superview as? UIScrollView,
               !context.coordinator.isAdded
            {
                scrollView.delegate = context.coordinator
                context.coordinator.scrollView = scrollView // 保存scrollView引用
                context.coordinator.isAdded = true
                
                if autoScroll {
                    context.coordinator.startAutoScroll(interval: scrollInterval)
                }
            }
        }

        /// We need to update the coordinator with the new values
        context.coordinator.width = width
        context.coordinator.spacing = spacing
        context.coordinator.itemCount = itemCount
        context.coordinator.repeatingCount = repeatingCount
        context.coordinator.autoScroll = autoScroll
        context.coordinator.scrollInterval = scrollInterval
    }
}

class Coordinator: NSObject, UIScrollViewDelegate {
    var width: CGFloat
    var spacing: CGFloat
    var itemCount: Int
    var repeatingCount: Int
    var autoScroll: Bool = false
    var scrollInterval: TimeInterval = 3.0
    weak var scrollView: UIScrollView?
    private var autoScrollTimer: Timer?
    var currentPage: Binding<Int>
    
    private var isDragging = false
    
    init(
        width: CGFloat,
        spacing: CGFloat,
        itemCount: Int,
        repeatingCount: Int,
        autoScroll: Bool,
        scrollInterval: TimeInterval,
        currentPage: Binding<Int>
    ) {
        self.width = width
        self.spacing = spacing
        self.itemCount = itemCount
        self.repeatingCount = repeatingCount
        self.autoScroll = autoScroll
        self.scrollInterval = scrollInterval
        self.currentPage = currentPage
    }

    ///  Tell us when  whether we need to scroll to the beginning or to the end
    var isAdded: Bool = false

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isDragging = true
        stopAutoScroll()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        isDragging = false
        if autoScroll {
            startAutoScroll(interval: scrollInterval)
        }
        updateCurrentPage(scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            isDragging = false
            if autoScroll {
                startAutoScroll(interval: scrollInterval)
            }
            updateCurrentPage(scrollView)
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard itemCount > 0 else { return }
        
        let minX = scrollView.contentOffset.x
        let mainContentSize = CGFloat(itemCount) * width
        let spacingSize = CGFloat(itemCount) * spacing
        
        // 处理循环滚动
        if minX > (mainContentSize + spacingSize) {
            scrollView.contentOffset.x -= (mainContentSize + spacingSize)
        }
        if minX < 0 {
            scrollView.contentOffset.x += (mainContentSize + spacingSize)
        }
        
        // 只在用户拖动时更新页面
        if isDragging {
            updateCurrentPage(scrollView)
        }
    }
    
    private func updateCurrentPage(_ scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        let totalWidth = width + spacing
        
        // 考虑滚动方向和加速度来确定目标页面
        var page = Int(round(offsetX / totalWidth))
        
        // 确保页面索引在有效范围内
        page = page % itemCount
        if page < 0 {
            page += itemCount
        }
        
        // 使用主线程更新UI
        DispatchQueue.main.async {
            withAnimation(.easeInOut(duration: 0.2)) {
                self.currentPage.wrappedValue = page
            }
        }
    }

    func startAutoScroll(interval: TimeInterval) {
        stopAutoScroll()
        
        autoScrollTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            guard let self = self,
                  let scrollView = self.scrollView,
                  !self.isDragging else { return }
            
            let currentOffset = scrollView.contentOffset
            let targetOffset = CGPoint(
                x: currentOffset.x + self.width + self.spacing,
                y: currentOffset.y
            )
            
            // 使用动画滚动到下一页
            withAnimation(.interpolatingSpring(stiffness: 300, damping: 100)) {
                scrollView.setContentOffset(targetOffset, animated: true)
            }
            
            // 更新页面指示器
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.updateCurrentPage(scrollView)
            }
        }
        RunLoop.main.add(autoScrollTimer!, forMode: .common)
    }
    
    func stopAutoScroll() {
        autoScrollTimer?.invalidate()
        autoScrollTimer = nil
    }
    
    deinit {
        stopAutoScroll()
    }
}
