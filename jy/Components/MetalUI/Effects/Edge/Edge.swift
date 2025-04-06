import SwiftUI

extension View {
    
    /// Outlines the view at high contrast edges
    /// - Parameters:
    ///   - distance: Distance is in points.
    ///   - strength: Strength is amplitude of contrast.
    public func edge(distance: CGFloat = 1.0,
                     strength: CGFloat = 1.0,
                     isEnabled: Bool = true) -> some View {
        ColorSchemeReader { colorScheme in
            let function = ShaderFunction(library: .bundle(.main),
                                          name: "edge")
            let shader = Shader(function: function, arguments: [
                .float(distance),
                .float(strength),
                .float(CGFloat.pixelsPerPoint),
                .float(colorScheme == .dark ? 1.0 : 0.0),
            ])
            let maxSampleOffset = CGSize(width: distance, height: distance)
            self.layerEffect(shader, maxSampleOffset: maxSampleOffset, isEnabled: isEnabled)
        }
    }
}
