//
//  GSXHomeRouter.swift
//  CleanArchitectureRxSwift
//
//  Created by Kevin on 12/14/22.
//  Copyright © 2022 sergdort. All rights reserved.
//

import Foundation
import Domain

protocol GSXHomeRouterProtocol: AnyObject {
    func routerToGSXHome()
    func routerToInputBorrow(flex: FlexiLoanModel)
}

class GSXHomeRouter: GSXHomeRouterProtocol {
    
    
  
    
    private let navigationController: UINavigationController
    private let services: UseCaseProvider
    init(services: UseCaseProvider,
         navigationController: UINavigationController) {
        self.services = services
        self.navigationController = navigationController
    }
    
    func routerToGSXHome() {
        let vc = GSXFlexiLoanHomeVC(nibName: "GSXFlexiLoanHomeVC", bundle: .main)
        vc.viewModel = .init(useCase: services.makePostsUseCase(), navigator: self)
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    func routerToInputBorrow(flex: FlexiLoanModel) {
        let vc = GSXFlexiBorrowViewController(nibName: "GSXFlexiBorrowViewController", bundle: .main)
        vc.flexiModel = flex
        navigationController.pushViewController(vc, animated: true)
    }
   
}
