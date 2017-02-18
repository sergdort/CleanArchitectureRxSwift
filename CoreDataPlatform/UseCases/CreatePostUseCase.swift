import Foundation
import Domain
import RxSwift

final class CDCreatePostUseCase: CreatePostUseCase {
    private let repository: AbstractRepository<Post>
    
    init(repository: AbstractRepository<Post>) {
        self.repository = repository
    }
    
    func create(post: Post) -> Observable<Void> {
        return repository.save(entity: post)
    }
}
