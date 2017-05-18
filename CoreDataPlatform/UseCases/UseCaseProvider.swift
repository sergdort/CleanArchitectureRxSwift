import Foundation
import Domain

public final class UseCaseProvider: Domain.UseCaseProvider {
    private let coreDataStack = CoreDataStack()
    private let postRepository: Repository<Post>

    public init() {
        postRepository = Repository<Post>(context: coreDataStack.context)
    }

    public func makeAllPostsUseCase() -> AllPostsUseCase {
        return CDAllPostsUseCase(repository: postRepository)
    }

    public func makeCreatePostUseCase() -> SavePostUseCase {
        return CDSavePostUseCase(repository: postRepository)
    }
}
