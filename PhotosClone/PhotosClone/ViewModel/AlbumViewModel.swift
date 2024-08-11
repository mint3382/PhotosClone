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
    
    struct Output {
        let loadingAlbumPhotos = PassthroughSubject<[PHAsset], Never>()
    }
    
    private var cancellables = Set<AnyCancellable>()
    let input: Input
    let output: Output
    var albumCollection: PHAssetCollection = PHAssetCollection()
    var albumTitle: String = ""
    var assets: [PHAsset] = []
    
    init() {
        self.input = Input()
        self.output = Output()
        settingBind()
    }
    
    func settingBind() {
        input.tappedAlbumItem
            .sink { [weak self] album in
                self?.albumCollection = album.collection
                self?.albumTitle = album.title
                self?.assets = PhotoManager.shared.fetchAssetsFromCollection(album.collection)
//                self?.output.loadingAlbumPhotos.send(assets)
            }
            .store(in: &cancellables)
    }
}


