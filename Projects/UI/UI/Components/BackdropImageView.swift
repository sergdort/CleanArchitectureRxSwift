import SwiftUI

public struct BackdropImageView: View {
    let posterURL: URL?
    let height: CGFloat?

    public init(posterURL: URL?, height: CGFloat? = nil) {
        self.posterURL = posterURL
        self.height = height
    }

    public var body: some View {
        Group {
            if let posterURL = posterURL {
                URLImage(url: posterURL) { content in
                    switch content {
                    case .success(let image):
                        image.resizable()
                            .renderingMode(.original)
                            .transition(.opacity)
                    case .failure, .empty:
                        Rectangle()
                            .foregroundColor(.gray)
                    @unknown default:
                        Rectangle()
                            .foregroundColor(.gray)
                    }
                }
            } else {
                Rectangle()
                    .foregroundColor(.gray)
            }
        }
        .frame(height: height)
    }
}
