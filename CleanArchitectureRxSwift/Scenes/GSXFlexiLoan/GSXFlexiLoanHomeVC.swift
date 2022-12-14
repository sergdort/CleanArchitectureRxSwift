//
//  GSXFlexiLoanHomeVC.swift
//  CleanArchitectureRxSwift
//
//  Created by Kevin on 12/14/22.
//  Copyright © 2022 sergdort. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Domain
class GSXFlexiLoanHomeVC: UIViewController {

    @IBOutlet weak var vBackground: UIView!
    @IBOutlet weak var lblAvailable: UILabel!
    @IBOutlet weak var lblInterestRate: UILabel!
    
    @IBOutlet weak var btnBrower: UIButton!
    private let disposeBag = DisposeBag()

    var viewModel: GSXHomeViewModel!
    override func viewDidLoad() {
        super.viewDidLoad()

        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [UIColor.blue.cgColor, UIColor.black.cgColor]
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        self.vBackground.layer.insertSublayer(gradient, at: 0)
        
        let viewDidLoad = rx.sentMessage(#selector(UIViewController.viewDidLayoutSubviews))
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        
        
        let input = GSXHomeViewModel.Input(browerTrigger:btnBrower.rx.tap.asDriver().asDriver() , trigger: viewDidLoad.asDriver())
        
        let output = viewModel.transform(input: input)
       
        output.flexiModel.asObservable().subscribe { event in
            switch event {
            case .next(let flex):
                if let val = flex.availableLOC?.val {
                    self.lblAvailable.text = "$S \(val)"
                    self.lblInterestRate.text = "Interest @ \(String(describing: flex.offeredInterestRate ?? 0.0)) % p.a (\(flex.offeredEIR ?? 0) p.a .EIR)"
                }
            case .error(_):
                break
            case .completed:
                break
            }
        }.disposed(by: disposeBag)
        
        output.selectedBorrow.drive().disposed(by: disposeBag)
        
        
        // Do any additional setup after loading the view.
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
