import Foundation
import Domain
import CoreDataPlatform

final class Application {
    static let shared = Application()
    
    private let coreDataServiceLocator: Domain.ServiceLocator
    
    private init(coreDataServiceLocator: Domain.ServiceLocator = CoreDataPlatform.ServiceLocator.shared) {
        self.coreDataServiceLocator = coreDataServiceLocator
    }
    
    func configureMainInterface(in window: UIWindow) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let navigationVC = UINavigationController()
        let navigator = DefaultPostsNavigator(services: coreDataServiceLocator,
                                              navigationController: navigationVC,
                                              storyBoard: storyboard)
        
        window.rootViewController = navigationVC
        
        navigator.toPosts()
    }
}
