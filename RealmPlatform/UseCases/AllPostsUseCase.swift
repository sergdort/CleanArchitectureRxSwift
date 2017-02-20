import Foundation
import Domain
import RxSwift
import Realm
import RealmSwift

final class AllPostsUseCase: Domain.AllPostsUseCase {
    private let repository: AbstractRepository<Post>

    init(repository: AbstractRepository<Post>) {
        self.repository = repository
    }

    func posts() -> Observable<[Post]> {
        return repository.queryAll()
    }
}
