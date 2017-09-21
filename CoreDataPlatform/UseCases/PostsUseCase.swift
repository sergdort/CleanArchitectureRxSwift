import Foundation
import Domain
import RxSwift

final class PostsUseCase: Domain.PostsUseCase {
    
    private let repository: AbstractRepository<Post>

    init(repository: AbstractRepository<Post>) {
        self.repository = repository
    }

    func posts() -> Observable<[Post]> {
        return repository.query(sortDescriptors: [Post.CoreDataType.uid.descending()])
    }
    
    func save(post: Post) -> Observable<Void> {
        return repository.save(entity: post)
    }
}
