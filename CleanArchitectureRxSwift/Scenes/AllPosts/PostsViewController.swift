import UIKit
import Domain
import RxSwift
import RxCocoa

class PostsViewController: UIViewController {
    private let disposeBag = DisposeBag()
    
    var viewModel: PostsViewModel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var createPostButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        bindViewModel()
    }
    
    private func configureTableView() {
        tableView.refreshControl = UIRefreshControl()
        tableView.estimatedRowHeight = 64
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    private func bindViewModel() {
        assert(viewModel != nil)
        
        let input = PostsViewModel.Input(trigger: Driver.just(),
                                       createPostTrigger: createPostButton.rx.tap.asDriver(),
                                       selection: tableView.rx.itemSelected.asDriver())
        let output = viewModel.transform(input: input)
        //Bind Posts to UITableView
        output.posts.drive(tableView.rx.items(cellIdentifier: PostTableViewCell.reuseID, cellType: PostTableViewCell.self)) { tv, item, cell in
            cell.titleLabel.text = item.title
            cell.detailsLabel.text = item.body
        }.addDisposableTo(disposeBag)
        //Connect Create Post to UI
        output.createPost.drive().addDisposableTo(disposeBag)
        output.selectedPost.drive().addDisposableTo(disposeBag)
    }
}



