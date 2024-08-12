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
        let selectedItem = PassthroughSubject<Void, Never>()
        let tappedInsidePhoto = PassthroughSubject<IndexPath, Never>()
        let changeDisplayItem = PassthroughSubject<(title: String, subTitle: String), Never>()
        let changeItemScroll = PassthroughSubject<IndexPath, Never>()
    }
    
    struct Output {
        let changeImage = PassthroughSubject<IndexPath, Never>()
        let changeTitle = PassthroughSubject<(title: String, subTitle: String), Never>()
        let changeScroll = PassthroughSubject<IndexPath, Never>()
        let handleSelectItem = PassthroughSubject<Bool, Never>()
    }
    
    private var cancellables = Set<AnyCancellable>()
    let input: Input
    let output: Output
    var assets: [PHAsset] = []
    var selectedIndex: IndexPath? = nil
    var isItemOnly: Bool = false
    
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
        
        input.changeDisplayItem
            .sink { [weak self] title in
                self?.output.changeTitle.send(title)
            }
            .store(in: &cancellables)
        
        input.changeItemScroll
            .sink { [weak self] indexPath in
                self?.output.changeScroll.send(indexPath)
            }
            .store(in: &cancellables)
        
        input.selectedItem
            .sink { [weak self] in
                guard let self else { return }
                isItemOnly.toggle()
                output.handleSelectItem.send(isItemOnly)
            }
            .store(in: &cancellables)
    }
}
