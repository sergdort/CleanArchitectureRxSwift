import Foundation
import Domain
import Realm
import RealmSwift

public final class ServiceLocator: Domain.ServiceLocator {
    public static let shared = ServiceLocator()

    private let configuration: Realm.Configuration

    private init() {
        configuration = Realm.Configuration()
    }

    func getAllPostsUseCase() -> Domain.AllPostsUseCase {
        let repository = Repository(configuration: configuration)
        return AllPostsUseCase(repository: repository)
    }

    func getCreatePostUseCase() -> Domain.SavePostUseCase {
        let repository = Repository(configuration: configuration)
        return SavePostUseCase(repository: repository)
    }

}
