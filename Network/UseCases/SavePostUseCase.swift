import Foundation
import Domain
import RxSwift

final class SavePostUseCase: Domain.SavePostUseCase {
    private let network: PostsNetwork

    init(network: PostsNetwork) {
        self.network = network
    }

    func save(post: Post) -> Observable<Void> {
        return network.createPost(post: post)
                .map { _ in }
    }
}
