import Foundation
import Domain
import RxSwift

final class AllPostsUseCase: Domain.AllPostsUseCase {
    private let network: PostsNetwork

    init(network: PostsNetwork) {
        self.network = network
    }

    func posts() -> Observable<[Post]> {
        return network.fetchPosts()
    }
}
