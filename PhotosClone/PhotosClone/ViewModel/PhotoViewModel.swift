//
//  PhotoViewModel.swift
//  PhotosClone
//
//  Created by minsong kim on 8/12/24.
//

import Combine
import UIKit
import Photos

class PhotoViewModel {
    struct Input {
        let tappedPhotoItem = PassthroughSubject<(assets:[PHAsset], indexPath: IndexPath), Never>()
        let tappedInsidePhoto = PassthroughSubject<IndexPath, Never>()
    }
    
    struct Output {
        let changeImage = PassthroughSubject<IndexPath, Never>()
    }
    
    private var cancellables = Set<AnyCancellable>()
    let input: Input
    let output: Output
    var assets: [PHAsset] = []
    var selectedPhoto: PHAsset? = nil
    var selectedIndex: IndexPath? = nil
    
    init() {
        self.input = Input()
        self.output = Output()
        settingBind()
    }
    
    func settingBind() {
        input.tappedPhotoItem
            .sink { [weak self] data in
                self?.assets = data.assets
                self?.selectedIndex = data.indexPath
            }
            .store(in: &cancellables)
        
        input.tappedInsidePhoto
            .sink { [weak self] indexPath in
                self?.selectedIndex = indexPath
                self?.output.changeImage.send(indexPath)
            }
            .store(in: &cancellables)
    }
}



