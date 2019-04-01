import Domain
import RxCocoa
import RxSwift
import UIKit

final class CreatePostViewController: UIViewController {
    private let disposeBag = DisposeBag()

    var viewModel: CreatePostViewModel!

    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var saveButton: UIBarButtonItem!
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var detailsTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        let input = CreatePostViewModel.Input(cancelTrigger: cancelButton.rx.tap.asDriver(),
                                              saveTrigger: saveButton.rx.tap.asDriver(),
                                              title: titleTextField.rx.text.orEmpty.asDriver(),
                                              details: detailsTextView.rx.text.orEmpty.asDriver())

        let output = viewModel.transform(input: input)

        output.dismiss.drive()
            .disposed(by: disposeBag)
        output.saveEnabled.drive(saveButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
}
