import Foundation
import Domain

final class SavePostUseCase: Domain.SavePostUseCase {
    private let repository: AbstractRepository<Post>

    init(repository: AbstractRepository<Post>) {
        self.repository = repository
    }

    func save(post: Post) -> Observable<Void> {
        return repository.save(entity: post)
    }
}
