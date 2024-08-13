//
//  AlbumViewModel.swift
//  PhotosClone
//
//  Created by minsong kim on 8/11/24.
//

import Combine
import UIKit
import Photos

class AlbumViewModel {
    struct Input {
        let tappedAlbumItem = PassthroughSubject<(title: String, collection: PHAssetCollection), Never>()
    }
    
    private var cancellables = Set<AnyCancellable>()
    let input: Input
    var albumCollection: PHAssetCollection = PHAssetCollection()
    var albumTitle: String = ""
    var assets: [PHAsset] = []
    
    init() {
        self.input = Input()
        settingBind()
    }
    
    func settingBind() {
        input.tappedAlbumItem
            .sink { [weak self] album in
                self?.albumCollection = album.collection
                self?.albumTitle = album.title
                self?.assets = PhotoManager.shared.fetchAssetsFromCollection(album.collection)
            }
            .store(in: &cancellables)
    }
}
