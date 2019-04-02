import Domain
import Foundation
import RxSwift

final class PostsUseCase<Cache>: Domain.PostsUseCase where Cache: AbstractCache, Cache.T == Post {
    private let network: PostsNetwork
    private let cache: Cache

    init(network: PostsNetwork, cache: Cache) {
        self.network = network
        self.cache = cache
    }

    func posts() -> Observable<[Post]> {
        let fetchPosts = cache.fetchObjects().asObservable()
        let stored = network.fetchPosts()
            .flatMap {
                self.cache.save(objects: $0)
                    .asObservable()
                    .map(to: [Post].self)
                    .concat(Observable.just($0))
            }

        return fetchPosts.concat(stored)
    }

    func save(post: Post) -> Observable<Void> {
        return network.createPost(post: post)
            .map { _ in }
    }

    func delete(post: Post) -> Observable<Void> {
        return network.deletePost(postId: post.uid).map({ _ in })
    }
}

struct MapFromNever: Error {}
extension ObservableType where E == Never {
    func map<T>(to _: T.Type) -> Observable<T> {
        return flatMap { _ in
            Observable<T>.error(MapFromNever())
        }
    }
}
