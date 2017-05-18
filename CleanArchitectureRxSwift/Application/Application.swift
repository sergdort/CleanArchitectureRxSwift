import Foundation
import Domain
import Network
import CoreDataPlatform
import RealmPlatform

final class Application {
    static let shared = Application()

    private let coreDataUseCaseProvider: Domain.UseCaseProvider
    private let realmUseCaseProvider: Domain.UseCaseProvider
    private let networkUseCaseProvider: Network.UseCaseProvider

    private init() {
        self.coreDataUseCaseProvider = CoreDataPlatform.UseCaseProvider()
        self.realmUseCaseProvider = RealmPlatform.UseCaseProvider()
        self.networkUseCaseProvider = Network.UseCaseProvider()
    }

    func configureMainInterface(in window: UIWindow) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let cdNavigationController = UINavigationController()
        cdNavigationController.tabBarItem = UITabBarItem(title: "CoreData",
                image: UIImage(named: "Box"),
                selectedImage: nil)
        let cdNavigator = DefaultPostsNavigator(services: coreDataUseCaseProvider,
                navigationController: cdNavigationController,
                storyBoard: storyboard)

        let rmNavigationController = UINavigationController()
        rmNavigationController.tabBarItem = UITabBarItem(title: "Realm",
                image: UIImage(named: "Toolbox"),
                selectedImage: nil)
        let rmNavigator = DefaultPostsNavigator(services: realmUseCaseProvider,
                navigationController: rmNavigationController,
                storyBoard: storyboard)

        let networkNavigationController = UINavigationController()
        networkNavigationController.tabBarItem = UITabBarItem(title: "Network",
                image: UIImage(named: "Toolbox"),
                selectedImage: nil)
        let networkNavigator = DefaultPostsNavigator(services: networkUseCaseProvider,
                navigationController: networkNavigationController,
                storyBoard: storyboard)

        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [
                cdNavigationController,
                rmNavigationController,
                networkNavigationController
        ]
        window.rootViewController = tabBarController

        cdNavigator.toPosts()
        rmNavigator.toPosts()
        networkNavigator.toPosts()
    }
}
