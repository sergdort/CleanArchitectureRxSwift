//
//  TodosNetwork.swift
//  CleanArchitectureRxSwift
//
//  Created by Andrey Yastrebov on 16.03.17.
//  Copyright © 2017 sergdort. All rights reserved.
//

import Domain
import RxSwift

public final class TodosNetwork {
    private let network: Network<Todo>

    init(network: Network<Todo>) {
        self.network = network
    }

    public func fetchTodos() -> Observable<[Todo]> {
        return network.getItems("todos")
    }

    public func fetchTodo(todoId: String) -> Observable<Todo> {
        return network.getItem("todos", itemId: todoId)
    }
}
