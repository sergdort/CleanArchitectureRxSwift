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
    var title:String
    var subtitle : String
    var post: Post
    init (with post:Post) {
        self.post = post
        self.title = post.title.uppercased()
        self.subtitle = post.body
    }
}
