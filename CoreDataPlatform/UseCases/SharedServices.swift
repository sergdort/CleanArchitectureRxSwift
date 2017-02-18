import Foundation
import Domain

public final class SharedServices {
    public static let shared = SharedServices()

    private let coreDataStack = CoreDataStack()
    private let postRepository: Repository<Post>
    public let allPostsUseCase: AllPostsUseCase
    public let createPostUseCase: CreatePostUseCase

    private init() {
        coreDataStack.migrateStore()
        postRepository = Repository<Post>(context: coreDataStack.context)
        allPostsUseCase = CDAllPostsUseCase(repository: postRepository)
        createPostUseCase = CDCreatePostUseCase(repository: postRepository)
    }
}
