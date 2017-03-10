import Foundation
import Domain
import RxSwift

final class CDAllPostsUseCase: AllPostsUseCase {
    private let repository: AbstractRepository<Post>

    init(repository: AbstractRepository<Post>) {
        self.repository = repository
    }

    func posts() -> Observable<[Post]> {
        return repository.query(sortDescriptors: [Post.CoreDataType.uid.descending()])
    }
}
