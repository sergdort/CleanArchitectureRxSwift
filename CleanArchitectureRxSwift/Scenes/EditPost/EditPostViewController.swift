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
                let yesAction = UIAlertAction(title: "Yes", style: .destructive, handler: { _ -> () in observer.onNext(()) })
                let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
                alert.addAction(yesAction)
                alert.addAction(noAction)

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
            .forEach({$0.disposed(by: disposeBag)})
    }

    var postBinding: Binder<Post> {
        return Binder(self, binding: { (vc, post) in
            vc.titleTextField.text = post.title
            vc.detailsTextView.text = post.body
            vc.title = post.title
        })
    }
    
    var errorBinding: Binder<Error> {
        return Binder(self, binding: { (vc, _) in
            let alert = UIAlertController(title: "Save Error",
                                          message: "Something went wrong",
                                          preferredStyle: .alert)
            let action = UIAlertAction(title: "Dismiss",
                                       style: UIAlertAction.Style.cancel,
                                       handler: nil)
            alert.addAction(action)
            vc.present(alert, animated: true, completion: nil)
        })
    }
}



extension Reactive where Base: UITextView {
    var isEditable: Binder<Bool> {
        return Binder(self.base, binding: { (textView, isEditable) in
            textView.isEditable = isEditable
        })
    }
}
