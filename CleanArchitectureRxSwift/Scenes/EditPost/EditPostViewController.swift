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
            vc.detailsTextView.text = post.content
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

final class EditPostViewModel: ViewModelType {
    private let post: Post
    private let useCase: SavePostUseCase
    
    init(post: Post, useCase: SavePostUseCase) {
        self.post = post
        self.useCase = useCase
    }
    
    func transform(input: Input) -> Output {
        let errorTracker = ErrorTracker()
        let editingState = input.editTrigger.scan(EditingState.idle) { editing, _ in
            return !editing
        }.startWith(.idle)
        
        let editing = editingState.map { $0 == EditingState.editing}
        let saveTrigger = editingState.skip(1) //we dont need initial state
            .filter { $0 == EditingState.idle}
            .mapToVoid()
        let titleAndDetails = Driver.combineLatest(input.title, input.details) {
            $0
        }
        let post = Driver.combineLatest(Driver.just(self.post), titleAndDetails) { (post, titleAndDetals) -> Post in
            return Post(uid: post.uid,
                        createDate: post.createDate,
                        updateDate: Date(),
                        title: titleAndDetals.0,
                        content: titleAndDetals.1,
                        media: post.media,
                        location: post.location)
        }.startWith(self.post)
        let editButtonTitle = editingState.map { state -> String in
            switch state {
            case .idle:
                return "Edit"
            case .editing:
                return "Save"
            }
        }
        let savePost = saveTrigger.withLatestFrom(post)
            .flatMapLatest { post in
                return self.useCase.save(post: post)
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }
        return Output(editButtonTitle: editButtonTitle,
                      save: savePost,
                      editing: editing,
                      post: post,
                      error: errorTracker.asDriver())
    }
}

extension EditPostViewModel {
    enum EditingState {
        case idle
        case editing
        
        prefix public static func !(a: EditingState) -> EditingState {
            return a == .idle ? .editing : .idle
        }
    }
    
    struct Input {
        let editTrigger: Driver<Void>
        let title: Driver<String>
        let details: Driver<String>
    }
    
    struct Output {
        let editButtonTitle: Driver<String>
        let save: Driver<Void>
        let editing: Driver<Bool>
        let post: Driver<Post>
        let error: Driver<Error>
    }
}

extension Reactive where Base: UITextView {
    var isEditable: UIBindingObserver<UITextView, Bool> {
        return UIBindingObserver(UIElement: self.base, binding: { (textView, isEditable) in
            textView.isEditable = isEditable
        })
    }
}

