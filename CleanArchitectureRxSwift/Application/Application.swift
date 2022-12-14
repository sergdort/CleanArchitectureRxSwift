import Foundation
import Domain
import NetworkPlatform
import CoreDataPlatform
import RealmPlatform

final class Application {
    static let shared = Application()

    private let coreDataUseCaseProvider: Domain.UseCaseProvider
    private let realmUseCaseProvider: Domain.UseCaseProvider
    private let networkUseCaseProvider: Domain.UseCaseProvider

    private init() {
        self.coreDataUseCaseProvider = CoreDataPlatform.UseCaseProvider()
        self.realmUseCaseProvider = RealmPlatform.UseCaseProvider()
        self.networkUseCaseProvider = NetworkPlatform.UseCaseProvider()
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
//        let universityController = UniversityViewController(nibName: "UniversityViewController", bundle: .main)
        
//        universityController.viewModel = .
        let universityNavigator = DefaultUniversityNavigator(navigationController: networkNavigationController, service: networkUseCaseProvider)
        
        let flexiloanVC = GSXFlexiLoanHomeVC(nibName: "GSXFlexiLoanHomeVC", bundle: .main)
        
        let flexiRouter = GSXHomeRouter(services: networkUseCaseProvider, navigationController: networkNavigationController)
        
        window.rootViewController = networkNavigationController

        cdNavigator.toPosts()
        rmNavigator.toPosts()
//        networkNavigator.toPosts()
        flexiRouter.routerToGSXHome()
//        universityNavigator.routerToNewFeed()
//        universityNavigator.toNewFeed()
    }
}
