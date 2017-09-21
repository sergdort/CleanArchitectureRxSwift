import Foundation
import Domain
import RxSwift
import Realm
import RealmSwift

final class PostsUseCase: Domain.PostsUseCase {
    private let repository: AbstractRepository<Post>

    init(repository: AbstractRepository<Post>) {
        self.repository = repository
    }

    func posts() -> Observable<[Post]> {
        return repository.queryAll()
    }
    
    func save(post: Post) -> Observable<Void> {
        return repository.save(entity: post)
    }
}
