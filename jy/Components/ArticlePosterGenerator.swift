import SwiftUI
import CoreImage.CIFilterBuiltins

struct ArticlePosterGenerator: View {
    @Environment(\.theme) private var theme
    
    let article: ArticleContent
    @State private var qrCode: UIImage? = nil
    @State private var posterImage: UIImage? = nil
    
    private let posterSize = CGSize(width: 375, height: 667)
    
    @State private var isGenerating = false
    @State private var isImage = false
    
    var body: some View {
        VStack(spacing: 16) {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 24) {
                    ForEach(0..<5) { index in
                        posterPreview
                            .scaleEffect(0.35)
                            .frame(width: 131, height: 233)
                    }
                }
                .padding(.horizontal, 16)
            }
            .frame(height: 240)
        }
        .compositingGroup()
        .shadow(color: Color.black.opacity(0.35), x: 0, y: 0, blur: 4)
//        .overlay(alignment: .bottomTrailing) {
//            ZStack {
//                if let image = posterImage {
//                    ShareLink(item: Image(uiImage: image), preview: SharePreview("文章海报", image: Image(uiImage: image))) {
//                        Image(systemName: "square.and.arrow.up.circle.fill")
//                            .themeFont(theme.fonts.title)
//                            .foregroundColor(theme.jyxqPrimary)
//                        .foregroundColor(.white)
//                        .frame(width: 44, height: 44)
//                        .background(.bar)
//                        .cornerRadius(22)
//                    }
//                    .onDisappear {
//                        self.isShareQRCard = false
//                    }
//                } else {
//                    ProgressView()
//                        .progressViewStyle(CircularProgressViewStyle(tint: theme.jyxqPrimary))
//                        .frame(width: 44, height: 44)
//                        .background(.bar)
//                        .cornerRadius(22)
//                }
//            }
//            .padding()
//        }
//        .task {
//            generatePoster()
//        }
        .onAppear {
            generateQRCode()
        }
    }
    
    private var posterPreview: some View {
        ZStack {
            // 背景层
            theme.background
                .ignoresSafeArea()
            // 文章缩略图
            KFImage(URL(string: article.imageUrl))
                .resizable()
                .placeholder {
                    Rectangle()
                        .fill(theme.subText2.opacity(0.1))
                        .overlay {
                            ProgressView()
                        }
                }
                .fade(duration: 0.35)
                .scaledToFill()
                .frame(width: posterSize.width - 20, height: posterSize.height - 20)
                .cornerRadius(theme.defaultCornerRadius)
                .overlay (alignment: .bottom) {
                    Rectangle()
                        .fill(theme.background)
                        .frame(height: 160)
                }
                .padding(10)
            VStack(spacing: 20) {
                // 文章标题
                Text(article.title)
                    .font(.system(size: 32), weight: .heavy)
                    .foregroundColor(theme.background)
                    .multilineTextAlignment(.center)
                    .shadow(color: Color.black.opacity(0.35), x: 0, y: 0, blur: 32)
                    .padding(.horizontal)
                    .padding(40)
                Spacer()
                // 二维码和底部信息
                VStack(spacing: 16) {
                    if let qrCode = qrCode {
                        Image(uiImage: qrCode)
                            .interpolation(.none)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .padding(8)
                            .background(theme.background.cornerRadius(6))
                    }
                    
                    VStack(spacing: 8) {
                        Text(article.source)
                            .font(.system(size: 14))
                            .foregroundColor(theme.subText)
                            .padding(.horizontal, 32)
                            .multilineTextAlignment(.center)
                        
                        Text("长按识别二维码，查看完整文章")
                            .font(.system(size: 12))
                            .foregroundColor(theme.subText2)
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .frame(width: posterSize.width, height: posterSize.height)
        .compositingGroup()
        .cornerRadius(16)
    }
    
    private func generateQRCode() {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        
        // 这里使用一个示例URL，实际应用中应该使用真实的文章URL
        let articleURL = "https://example.com/article/\(article.title)"
        
        filter.message = Data(articleURL.utf8)
        filter.correctionLevel = "M"
        
        if let outputImage = filter.outputImage {
            let scale = 120.0 / outputImage.extent.width
            let transformedImage = outputImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
            
            if let cgImage = context.createCGImage(transformedImage, from: transformedImage.extent) {
                qrCode = UIImage(cgImage: cgImage)
            }
        }
    }
    
    @State private var isImageLoaded = false
    
    private func generatePoster() {
        isGenerating = true
        isImageLoaded = false
        
        // 创建一个和海报预览大小相同的图形上下文
        let format = UIGraphicsImageRendererFormat()
        format.scale = 3.0 // 提高渲染质量
        format.preferredRange = .extended // 使用扩展色彩范围
        
        let renderer = UIGraphicsImageRenderer(size: posterSize, format: format)
        
        // 创建一个临时的 UIView 用于渲染
        let tempView = UIView(frame: CGRect(origin: .zero, size: posterSize))
        
        // 创建一个临时的 UIHostingController 用于渲染 SwiftUI 视图
        let hostingController = UIHostingController(rootView: posterPreview)
        hostingController.view.frame = tempView.bounds
        
        // 确保背景色正确设置
        let backgroundColor = UIColor(theme.background)
        tempView.backgroundColor = backgroundColor
        hostingController.view.backgroundColor = backgroundColor
        
        tempView.addSubview(hostingController.view)
        
        // 确保视图已经完成布局
        hostingController.view.setNeedsLayout()
        hostingController.view.layoutIfNeeded()
        
        // 等待图片加载完成
        if let imageUrl = URL(string: article.imageUrl) {
            Task {
                do {
                    _ = try await KingfisherManager.shared.retrieveImage(with: imageUrl)
                    // 在主线程更新 UI 相关状态
                    await MainActor.run {
                        self.isImageLoaded = true
                        // 增加延迟时间，确保视图完全渲染
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                            // 再次确保所有视图都已经布局完成
                            hostingController.view.setNeedsLayout()
                            hostingController.view.layoutIfNeeded()
                            
                            // 强制更新视图层级
                            hostingController.view.layer.setNeedsDisplay()
                            hostingController.view.layer.displayIfNeeded()
                            
                            self.renderPoster(tempView: tempView, renderer: renderer, hostingController: hostingController)
                            self.isImage = true
                        }
                    }
                } catch {
                    print("Image loading failed: \(error)")
                    // 在主线程更新 UI 相关状态
                    await MainActor.run {
                        self.isGenerating = false
                        self.isImage = false
                    }
                }
            }

        } else {
            self.isGenerating = false
            isImage = false
        }
    }
    
    private func renderPoster(tempView: UIView, renderer: UIGraphicsImageRenderer, hostingController: UIHostingController<some View>) {
        // 确保在主线程中执行渲染
        DispatchQueue.main.async {
            // 再次确保布局已更新
            tempView.setNeedsLayout()
            tempView.layoutIfNeeded()
            hostingController.view.setNeedsLayout()
            hostingController.view.layoutIfNeeded()
            
            // 使用 drawHierarchy 替代 layer.render
            self.posterImage = renderer.image { context in
                tempView.drawHierarchy(in: tempView.bounds, afterScreenUpdates: true)
            }
            
            // 清理视图
            hostingController.view.removeFromSuperview()
            
            self.isGenerating = false
            if self.posterImage != nil {
                
            }
        }
    }
}
