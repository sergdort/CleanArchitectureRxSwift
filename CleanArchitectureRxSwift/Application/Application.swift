import Foundation
import Domain
import CoreDataPlatform
import RealmPlatform

final class Application {
    static let shared = Application()
    
    private let coreDataUseCaseProvider: Domain.UseCaseProvider
    private let realmUseCaseProvider: Domain.UseCaseProvider
    
    private init() {
        self.coreDataUseCaseProvider = CoreDataPlatform.UseCaseProvider()
        self.realmUseCaseProvider = RealmPlatform.UseCaseProvider()
    }
    
    func configureMainInterface(in window: UIWindow) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let cdNavigationController = UINavigationController()
        cdNavigationController.tabBarItem = UITabBarItem(title: "CoreData", image: nil, selectedImage: nil)
        let cdNavigator = DefaultPostsNavigator(services: coreDataUseCaseProvider,
                                              navigationController: cdNavigationController,
                                              storyBoard: storyboard)

        let rmNavigationController = UINavigationController()
        rmNavigationController.tabBarItem = UITabBarItem(title: "Realm", image: nil, selectedImage: nil)
        let rmNavigator = DefaultPostsNavigator(services: realmUseCaseProvider,
                navigationController: rmNavigationController,
                storyBoard: storyboard)

        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [cdNavigationController, rmNavigationController]
        window.rootViewController = tabBarController
        
        cdNavigator.toPosts()
        rmNavigator.toPosts()
    }
}
