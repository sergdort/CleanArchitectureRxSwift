//
//  GSXFlexiBorrowViewController.swift
//  CleanArchitectureRxSwift
//
//  Created by Kevin on 12/14/22.
//  Copyright © 2022 sergdort. All rights reserved.
//

import UIKit
import Domain
import RxSwift

class GSXFlexiBorrowViewController: UIViewController {

    @IBOutlet weak var txtInputAmount: UITextField!
    @IBOutlet weak var lblDescription: UILabel!
    var flexiModel: FlexiLoanModel?
    var viewModel =  GSXFlexBorrowViewModel()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUi()
        self.setUpBindModel()
        // Do any additional setup after loading the view.
    }
    
    private func setUpUi() {
        self.txtInputAmount.keyboardType = .numberPad
        self.lblDescription.text = "Enter an amount between S$\(flexiModel?.min?.val ?? 0.0) and S$ \(flexiModel?.max?.val ?? 0.0)"
    }
    
    private func setUpBindModel() {
        let input =  GSXFlexBorrowViewModel.Input(amount: txtInputAmount.rx.text.orEmpty.asDriver(),min: flexiModel?.min?.val ?? 0.0, max: flexiModel?.max?.val ?? 0.0)
        let output = viewModel.transform(input: input)
        
        output.valid.asObservable().subscribe { isValid in
            self.lblDescription.textColor =  isValid ? .white : .red
        }.disposed(by: disposeBag)
    }

}
