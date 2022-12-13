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
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    private func bindViewModel() {
        assert(viewModel != nil)
        let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        let pull = tableView.refreshControl!.rx
            .controlEvent(.valueChanged)
            .asDriver()
        
        let input = PostsViewModel.Input(trigger: Driver.merge(viewWillAppear, pull),
                                       createPostTrigger: createPostButton.rx.tap.asDriver(),
                                       selection: tableView.rx.itemSelected.asDriver())
        
        let output = viewModel.transform(input: input)
        
        //Bind Posts to UITableView
        output.posts.drive(tableView.rx.items(cellIdentifier: PostTableViewCell.reuseID, cellType: PostTableViewCell.self)) { tv, viewModel, cell in
            cell.bind(viewModel)
        }.disposed(by: disposeBag)
        //Connect Create Post to UI
        
        output.fetching
            .drive(tableView.refreshControl!.rx.isRefreshing)
            .disposed(by: disposeBag)
        output.createPost
            .drive()
            .disposed(by: disposeBag)
        output.selectedPost
            .drive()
            .disposed(by: disposeBag)
    }
}



