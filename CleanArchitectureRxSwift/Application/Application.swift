import Foundation
import Domain
import CoreDataPlatform
import RealmPlatform

final class Application {
    static let shared = Application()
    
    private let coreDataServiceLocator: Domain.ServiceLocator
    private let realmServiceLocator: Domain.ServiceLocator
    
    private init() {
        self.coreDataServiceLocator = CoreDataPlatform.ServiceLocator.shared
        self.realmServiceLocator = RealmPlatform.ServiceLocator.shared
    }
    
    func configureMainInterface(in window: UIWindow) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let cdNavigationController = UINavigationController()
        cdNavigationController.tabBarItem = UITabBarItem(title: "CoreData", image: nil, selectedImage: nil)
        let cdNavigator = DefaultPostsNavigator(services: coreDataServiceLocator,
                                              navigationController: cdNavigationController,
                                              storyBoard: storyboard)

        let rmNavigationController = UINavigationController()
        rmNavigationController.tabBarItem = UITabBarItem(title: "Realm", image: nil, selectedImage: nil)
        let rmNavigator = DefaultPostsNavigator(services: realmServiceLocator,
                navigationController: rmNavigationController,
                storyBoard: storyboard)

        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [cdNavigationController, rmNavigationController]
        window.rootViewController = tabBarController
        
        cdNavigator.toPosts()
        rmNavigator.toPosts()
    }
}
