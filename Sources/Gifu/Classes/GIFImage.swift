#if os(iOS) || os(tvOS)
import SwiftUI

/// An image view for displaying animated images.
@available(iOS 13, tvOS 13, *)
public struct GIFImage: UIViewRepresentable {
    private enum Source {
        case data(Data)
        case url(URL)
        case imageName(String)
    }

    private let source: Source
    private var loopCount = 0

    /// Initializes the view with the given GIF image data.
    public init(data: Data) {
        self.source = .data(data)
    }

    /// Initialzies the view with the given GIF image url.
    public init(url: URL) {
        self.source = .url(url)
    }

    /// Initialzies the view with the given GIF image name.
    public init(imageName: String) {
        self.source = .imageName(imageName)
    }

    /// Sets the desired number of loops. By default, the number of loops infinite.
    public func loopCount(_ value: Int) -> GIFImage {
        var copy = self
        copy.loopCount = value
        return copy
    }

    public func makeUIView(context: Context) -> GIFImageView {
        GIFImageView(frame: .zero)
    }

    public func updateUIView(_ view: GIFImageView, context: Context) {
        switch source {
        case .data(let data):
            view.animate(withGIFData: data, loopCount: loopCount)
        case .url(let url):
            view.animate(withGIFURL: url, loopCount: loopCount)
        case .imageName(let imageName):
            view.animate(withGIFNamed: imageName, loopCount: loopCount)
        }
    }
}
#endif
