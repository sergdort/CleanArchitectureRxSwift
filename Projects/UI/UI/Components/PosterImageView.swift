import SwiftUI

public struct PosterImageView: View {
    let posterSize: PosterStyle.Size
    let posterURL: URL?

    public init(posterSize: PosterStyle.Size, posterURL: URL?) {
        self.posterSize = posterSize
        self.posterURL = posterURL
    }

    public var body: some View {
        if let posterURL = posterURL {
            URLImage(url: posterURL) { content in
                switch content {
                case .success(let image):
                    image.resizable()
                        .renderingMode(.original)
                        .transition(.opacity)
                        .posterStyle(loaded: true, size: posterSize)
                case .failure, .empty:
                    Rectangle()
                        .foregroundColor(.gray)
                        .posterStyle(loaded: false, size: posterSize)
                @unknown default:
                    Rectangle()
                        .foregroundColor(.gray)
                        .posterStyle(loaded: false, size: posterSize)
                }
            }
        } else {
            Rectangle()
                .foregroundColor(.gray)
                .posterStyle(loaded: false, size: posterSize)
        }
    }
}

public struct PosterStyle: ViewModifier {
    public enum Size {
        case small, medium, big, tv

        public var width: CGFloat {
            switch self {
            case .small: return 53
            case .medium: return 100
            case .big: return 250
            case .tv: return 333
            }
        }

        public var height: CGFloat {
            switch self {
            case .small: return 80
            case .medium: return 150
            case .big: return 375
            case .tv: return 500
            }
        }
    }

    let loaded: Bool
    let size: Size

    public func body(content: Content) -> some View {
        return content
            .frame(width: size.width, height: size.height)
            .cornerRadius(5)
            .opacity(loaded ? 1 : 0.1)
    }
}

extension View {
    func posterStyle(loaded: Bool, size: PosterStyle.Size) -> some View {
        return ModifiedContent(content: self, modifier: PosterStyle(loaded: loaded, size: size))
    }
}
