//
//  UniversityNavigator.swift
//  CleanArchitectureRxSwift
//
//  Created by Kevin on 12/13/22.
//  Copyright © 2022 sergdort. All rights reserved.
//

import Foundation
import UIKit
import Domain
import SafariServices
protocol UniversityNavigator: AnyObject {
    func routerToNewFeed()
    func routerToDetail(url: URL)
    func routerToDetail()

}

//DefaultCreatePostNavigator
class DefaultUniversityNavigator: UniversityNavigator {
    
    private let navigationController: UINavigationController
    private let services: UseCaseProvider

    init(navigationController: UINavigationController, service: UseCaseProvider) {
        self.navigationController = navigationController
        self.services = service
    }
    
    func routerToNewFeed() {
        let vc = UniversityViewController(nibName: "UniversityViewController", bundle: .main)
        vc.viewModel = .init(useCase: services.makePostsUseCase(), navigator: self)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func routerToDetail(url: URL) {
        let safariController = SFSafariViewController(url: url)
        self.navigationController.present(safariController, animated: true)
    }
    
    func routerToDetail() {
        
    }
    
}
