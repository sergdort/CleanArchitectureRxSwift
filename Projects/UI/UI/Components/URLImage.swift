import SwiftUI

public struct URLImage<Content: View>: View {
    private var model: URLImageModel
    private let content: (AsyncImagePhase) -> Content
    
    public init(url: URL, @ViewBuilder content: @escaping (AsyncImagePhase) -> Content) {
        self.model = URLImageModel(url: url)
        self.content = content
    }
    
    public var body: some View {
        content(model.image)
            .task {
                await model.load()
            }
    }
}

@Observable
final class URLImageModel: ObservableObject {
    var image: AsyncImagePhase
    
    private let url: URL
    private let cache: ImageCache
    private let loadImage: (URL) async throws -> (Data, URLResponse)
    
    init(url: URL,
         cache: ImageCache = .shared,
         loadImage: @escaping (URL) async throws -> (Data, URLResponse) = URLSession.shared.data(from:))
    {
        self.url = url
        self.cache = cache
        self.loadImage = loadImage
        
        self.image = cache.image(for: url)
            .map(Image.init(uiImage:))
            .map(AsyncImagePhase.success) ?? .empty
    }
    
    @MainActor
    func load() async {
        if case .success = image {
            return
        }
        do {
            let (data, _) = try await loadImage(url)
            guard let image = UIImage(data: data) else {
                self.image = .empty
                return
            }
            cache.set(image: image, url: url)
            self.image = .success(Image(uiImage: image))
        } catch {
            image = .failure(error)
        }
    }
}

final class ImageCache {
    private let cache = NSCache<Key, UIImage>()
    
    static let shared = ImageCache()
    
    func image(for url: URL) -> UIImage? {
        return cache.object(forKey: Key(url: url))
    }
    
    func set(image: UIImage, url: URL) {
        cache.setObject(image, forKey: Key(url: url))
    }
    
    private final class Key: NSObject {
        private let url: URL
        
        init(url: URL) {
            self.url = url
        }
        
        override func isEqual(_ object: Any?) -> Bool {
            guard let object = object as? Key else {
                return false
            }
            return url == object.url
        }
        
        override var hash: Int {
            return url.hashValue
        }
    }
}
