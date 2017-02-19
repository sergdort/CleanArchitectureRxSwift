import UIKit
import Domain
import RxSwift
import RxCocoa
import CoreDataPlatform

final class CreatePostViewController: UIViewController {
    private let disposeBag = DisposeBag()

    var viewModel: CreatePostViewModel!

    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var detailsTextView: UITextView!
    
    let useCase = CoreDataPlatform.ServiceLocator.shared.getCreatePostUseCase()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let title = titleTextField.rx.text.orEmpty
        let details = detailsTextView.rx.text.orEmpty

        let input = CreatePostViewModel.Input(cancelTrigger: cancelButton.rx.tap.asDriver(),
                                              saveTrigger: saveButton.rx.tap.asDriver(),
                                              title: titleTextField.rx.text.orEmpty.asDriver(),
                                              details: detailsTextView.rx.text.orEmpty.asDriver())
        
        let output = viewModel.transform(input: input)
        
        output.dismiss.drive().addDisposableTo(disposeBag)
        output.saveEnabled.drive(saveButton.rx.isEnabled).addDisposableTo(disposeBag)
    }
}
