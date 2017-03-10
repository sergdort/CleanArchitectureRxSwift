import UIKit
import RxSwift
import RxCocoa
import Domain

final class EditPostViewController: UIViewController {
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var detailsTextView: UITextView!
    
    var viewModel: EditPostViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let input = EditPostViewModel.Input(editTrigger: editButton.rx.tap.asDriver(),
                                            title: titleTextField.rx.text.orEmpty.asDriver(),
                                            details: detailsTextView.rx.text.orEmpty.asDriver())
        let output = viewModel.transform(input: input)
        
        output.editButtonTitle.drive(editButton.rx.title).addDisposableTo(disposeBag)
        output.editing.drive(titleTextField.rx.isEnabled).addDisposableTo(disposeBag)
        output.editing.drive(detailsTextView.rx.isEditable).addDisposableTo(disposeBag)
        output.post.drive(postBinding).addDisposableTo(disposeBag)
        output.save.drive().addDisposableTo(disposeBag)
        output.error.drive(errorBinding).addDisposableTo(disposeBag)
    }

    
    var postBinding: UIBindingObserver<EditPostViewController, Post> {
        return UIBindingObserver(UIElement: self, binding: { (vc, post) in
            vc.titleTextField.text = post.title
            vc.detailsTextView.text = post.body
            vc.title = post.title
        })
    }
    
    var errorBinding: UIBindingObserver<EditPostViewController, Error> {
        return UIBindingObserver(UIElement: self, binding: { (vc, _) in
            let alert = UIAlertController(title: "Save Error",
                                          message: "Something went wrong",
                                          preferredStyle: .alert)
            let action = UIAlertAction(title: "Dismiss",
                                       style: UIAlertActionStyle.cancel,
                                       handler: nil)
            alert.addAction(action)
            vc.present(alert, animated: true, completion: nil)
        })
    }
}



extension Reactive where Base: UITextView {
    var isEditable: UIBindingObserver<UITextView, Bool> {
        return UIBindingObserver(UIElement: self.base, binding: { (textView, isEditable) in
            textView.isEditable = isEditable
        })
    }
}

