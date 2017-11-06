import Foundation
import Domain
import RxSwift
import Realm
import RealmSwift

final class PostsUseCase<Repository>: Domain.PostsUseCase where Repository: AbstractRepository, Repository.T == Post {

    private let repository: Repository

    init(repository: Repository) {
        self.repository = repository
    }

    func posts() -> Observable<[Post]> {
        return repository.queryAll()
    }
    
    func save(post: Post) -> Observable<Void> {
        return repository.save(entity: post)
    }

    func delete(post: Post) -> Observable<Void> {
        return repository.delete(entity: post)
    }
}
