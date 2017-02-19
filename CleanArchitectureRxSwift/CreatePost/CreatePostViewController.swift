import UIKit
import Domain
import RxSwift
import RxCocoa
import CoreDataPlatform

final class CreatePostViewController: UIViewController {
    let disposeBag = DisposeBag()
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var detailsTextView: UITextView!
    
    let useCase = CoreDataPlatform.ServiceLocator.shared.getCreatePostUseCase()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let title = titleTextField.rx.text.orEmpty
        let details = detailsTextView.rx.text.orEmpty
        let titleAndDetails = Observable.combineLatest(title, details) {
            $0
        }
        let activityIndicator = ActivityIndicator()
        
        let canSave = Observable.combineLatest(titleAndDetails, activityIndicator.asObservable()) {
            return !$0.0.isEmpty && !$0.1.isEmpty && !$1
        }
        
        canSave.bindTo(saveButton.rx.isEnabled).addDisposableTo(disposeBag)
        
        let save = saveButton.rx.tap.withLatestFrom(titleAndDetails)
            .map { (title, content) in
                return Post(uid: UUID().uuidString,
                            createDate: Date(),
                            updateDate: Date(),
                            title: title,
                            content: content)
            }
            .flatMapLatest { [unowned self] in
                return self.useCase.create(post: $0)
                    .trackActivity(activityIndicator)
                    .catchErrorJustComplete()
            }
            .observeOn(MainScheduler.instance)
        
        let dispmiss = Observable.of(save, cancelButton.rx.tap.asObservable()).merge()
        
        dispmiss.subscribe(onNext: { [unowned self] in
            self.dismiss(animated: true, completion: nil)
        }).addDisposableTo(disposeBag)
    }
}
