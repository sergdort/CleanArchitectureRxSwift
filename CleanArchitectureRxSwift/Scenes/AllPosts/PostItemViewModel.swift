//
//  PostItemViewModel.swift
//  CleanArchitectureRxSwift
//
//  Created by Stefano Mondino on 09/08/17.
//  Copyright © 2017 sergdort. All rights reserved.
//

import Foundation
import Domain

final class PostItemViewModel   {
    let title:String
    let subtitle : String
    let post: Post
    init (with post:Post) {
        self.post = post
        self.title = post.title.uppercased()
        self.subtitle = post.body
    }
}
