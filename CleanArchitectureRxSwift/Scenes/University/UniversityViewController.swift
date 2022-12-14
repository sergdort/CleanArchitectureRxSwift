//
//  UniversityViewController.swift
//  CleanArchitectureRxSwift
//
//  Created by Kevin on 12/13/22.
//  Copyright © 2022 sergdort. All rights reserved.
//

import UIKit
import Domain
import RxCocoa
import RxSwift

class UniversityViewController: UIViewController {

    var viewModel: UniversityViewModel!
    private let tableView = UITableView()
    private let disposeBag = DisposeBag()
    
    private let searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Search for university"
        return searchController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(MovieTableViewCell.nib, forCellReuseIdentifier: MovieTableViewCell.identifier)
        navigationItem.searchController = searchController
        navigationItem.title = "University finder"
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationController?.navigationBar.prefersLargeTitles = true
        self.configureLayout()
        self.configureTableView()
        self.bindViewModel()
    }
    
    private func configureLayout() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        tableView.contentInset.bottom = view.safeAreaInsets.bottom
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
        let input = UniversityViewModel.Input(trigger: Driver.merge(viewWillAppear, pull), searchText: searchController.searchBar.rx.text.orEmpty.asDriver(), selection: tableView.rx.itemSelected.asDriver())
        let output =  viewModel.transform(input: input)
        output.list.asObservable().bind(to: tableView.rx.items) {(tableView, items, model) in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.identifier) as? MovieTableViewCell else {return UITableViewCell()}
            print(Thread.isMainThread)
            cell.binding(data: model)
            return cell
        }.disposed(by: disposeBag)
        
        output.selected.drive().disposed(by: disposeBag)
    }
}
