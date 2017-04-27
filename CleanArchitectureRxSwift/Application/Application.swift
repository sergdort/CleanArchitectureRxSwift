import Foundation
import Domain
import Network
import CoreDataPlatform
import RealmPlatform

final class Application {
    static let shared = Application()
    
    private let coreDataUseCaseProvider: Domain.UseCaseProvider
    private let realmUseCaseProvider: Domain.UseCaseProvider
    private let networkProvider: Network.NetworkProvider
    
    private init() {
        self.coreDataUseCaseProvider = CoreDataPlatform.UseCaseProvider()
        self.realmUseCaseProvider = RealmPlatform.UseCaseProvider()
        self.networkProvider = Network.NetworkProvider()
    }
    
    func configureMainInterface(in window: UIWindow) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let cdNavigationController = UINavigationController()
        cdNavigationController.tabBarItem = UITabBarItem(title: "CoreData", image: nil, selectedImage: nil)
        let cdNavigator = DefaultPostsNavigator(services: coreDataUseCaseProvider,
                                                network: networkProvider,
                                                navigationController: cdNavigationController,
                                                storyBoard: storyboard)

        let rmNavigationController = UINavigationController()
        rmNavigationController.tabBarItem = UITabBarItem(title: "Realm", image: nil, selectedImage: nil)
        let rmNavigator = DefaultPostsNavigator(services: realmUseCaseProvider,
                                                network: networkProvider,
                                                navigationController: rmNavigationController,
                                                storyBoard: storyboard)

        let tabBarController = UITabBarController()
        cdNavigationController.tabBarItem.image = UIImage(named: "Box")
        rmNavigationController.tabBarItem.image = UIImage(named: "Toolbox")
        tabBarController.viewControllers = [cdNavigationController, rmNavigationController]
        window.rootViewController = tabBarController
        
        cdNavigator.toPosts()
        rmNavigator.toPosts()
    }
}
