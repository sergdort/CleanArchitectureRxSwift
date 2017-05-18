import Foundation
import Domain
import Realm
import RealmSwift

public final class UseCaseProvider: Domain.UseCaseProvider {
    private let configuration: Realm.Configuration

    public init(configuration: Realm.Configuration = Realm.Configuration()) {
        self.configuration = configuration
    }

    public func makeAllPostsUseCase() -> Domain.AllPostsUseCase {
        let repository = Repository<Post>(configuration: configuration)
        return AllPostsUseCase(repository: repository)
    }

    public func makeCreatePostUseCase() -> Domain.SavePostUseCase {
        let repository = Repository<Post>(configuration: configuration)
        return SavePostUseCase(repository: repository)
    }

}
