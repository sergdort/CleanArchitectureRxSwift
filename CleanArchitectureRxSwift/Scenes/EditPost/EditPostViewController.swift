import UIKit
import RxSwift
import RxCocoa
import Domain

final class EditPostViewController: UIViewController {
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var detailsTextView: UITextView!
    
    var viewModel: EditPostViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let deleteTrigger = deleteButton.rx.tap.flatMap {
            return Observable<Void>.create { observer in

                let alert = UIAlertController(title: "Delete Post",
                    message: "Are you sure you want to delete this post?",
                    preferredStyle: .alert
                )

                [("Yes", UIAlertActionStyle.destructive, { _ -> () in observer.onNext() }),
                 ("No", UIAlertActionStyle.cancel, { _ -> () in observer.onCompleted() })]
                .map({ UIAlertAction(title: $0, style: $1, handler: $2) })
                .forEach(alert.addAction)

                self.present(alert, animated: true, completion: nil)

                return Disposables.create()
            }
        }

        let input = EditPostViewModel.Input(
            editTrigger: editButton.rx.tap.asDriver(),
            deleteTrigger: deleteTrigger.asDriverOnErrorJustComplete(),
            title: titleTextField.rx.text.orEmpty.asDriver(),
            details: detailsTextView.rx.text.orEmpty.asDriver()
        )

        let output = viewModel.transform(input: input)

        [output.editButtonTitle.drive(editButton.rx.title),
        output.editing.drive(titleTextField.rx.isEnabled),
        output.editing.drive(detailsTextView.rx.isEditable),
        output.post.drive(postBinding),
        output.save.drive(),
        output.error.drive(errorBinding),
        output.delete.drive()]
        .forEach({$0.addDisposableTo(disposeBag)})
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
