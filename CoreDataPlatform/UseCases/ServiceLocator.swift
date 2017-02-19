import Foundation
import Domain

public final class ServiceLocator: Domain.ServiceLocator {
    public static let shared = ServiceLocator()

    private let coreDataStack = CoreDataStack()
    private let postRepository: Repository<Post>

    private init() {
        postRepository = Repository<Post>(context: coreDataStack.context)
    }

    public func getAllPostsUseCase() -> AllPostsUseCase {
        return CDAllPostsUseCase(repository: postRepository)
    }

    public func getCreatePostUseCase() -> CreatePostUseCase {
        return CDCreatePostUseCase(repository: postRepository)
    }
}
