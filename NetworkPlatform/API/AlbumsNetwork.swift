//
//  AlbumsNetwork.swift
//  CleanArchitectureRxSwift
//
//  Created by Andrey Yastrebov on 16.03.17.
//  Copyright © 2017 sergdort. All rights reserved.
//

import Domain
import RxSwift

public final class AlbumsNetwork {
    private let network: Network<Album>

    init(network: Network<Album>) {
        self.network = network
    }

    public func fetchAlbums() -> Observable<[Album]> {
        return network.getItems("albums")
    }

    public func fetchAlbum(albumId: String) -> Observable<Album> {
        return network.getItem("albums", itemId: albumId)
    }
}
