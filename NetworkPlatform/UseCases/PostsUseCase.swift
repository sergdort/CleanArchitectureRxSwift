import Foundation
import Domain
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
                return self.cache.save(objects: $0)
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
        return network.deletePost(postId: post.uid).map({_ in})
    }
}

struct MapFromNever: Error {}
extension ObservableType where Element == Never {
    func map<T>(to: T.Type) -> Observable<T> {
        return self.flatMap { _ in
            return Observable<T>.error(MapFromNever())
        }
    }
}
