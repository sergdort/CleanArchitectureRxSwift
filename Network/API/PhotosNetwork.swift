//
//  PhotosNetwork.swift
//  CleanArchitectureRxSwift
//
//  Created by Andrey Yastrebov on 16.03.17.
//  Copyright © 2017 sergdort. All rights reserved.
//

import Domain
import RxSwift

public final class PhotosNetwork {
    private let network: Network<Photo>

    init(network: Network<Photo>) {
        self.network = network
    }

    public func fetchPhotos() -> Observable<[Photo]> {
        return network.getItems("photos")
    }

    public func fetchPhoto(photoId: String) -> Observable<Photo> {
        return network.getItem("photos", itemId: photoId)
    }
}
