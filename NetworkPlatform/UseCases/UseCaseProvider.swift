import Foundation
import Domain

public final class UseCaseProvider: Domain.UseCaseProvider {
    private let networkProvider: NetworkProvider

    public init() {
        networkProvider = NetworkProvider()
    }

    public func makePostsUseCase() -> Domain.PostsUseCase {
        return PostsUseCase(network: networkProvider.makePostsNetwork(),
                               cache: Cache<Post>(path: "allPosts"))
    }
}
