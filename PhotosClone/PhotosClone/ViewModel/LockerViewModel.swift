//
//  LockerViewModel.swift
//  PhotosClone
//
//  Created by minsong kim on 8/8/24.
//

import Combine
import UIKit
import Photos

class LockerViewModel {
    struct Input {
        let timePeriodSegmentControlSelected = PassthroughSubject<Int, Never>()
        let tappedPhotoItem = PassthroughSubject<(assets:[PHAsset], photoIndex: IndexPath), Never>()
        let tappedCollectionItem = PassthroughSubject<Date, Never>()
        let readyPhotos = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let handleChildViewController = PassthroughSubject<Int, Never>()
        let handlePhotoItem = PassthroughSubject<Int, Never>()
        let handleCollectionItem = PassthroughSubject<Date, Never>()
        let handleIndicator = PassthroughSubject<Void, Never>()
    }
    
    private var cancellables = Set<AnyCancellable>()
    let input: Input
    let output: Output
    
    private var currentControlNumber: Int = 3
    
    init() {
        self.input = Input()
        self.output = Output()
        settingBind()
    }
    
    func settingBind() {
        input.timePeriodSegmentControlSelected
            .sink { [weak self] selectedNumber in
                guard let self else {
                    return
                }
                output.handleChildViewController.send(currentControlNumber)
                currentControlNumber = selectedNumber
            }
            .store(in: &cancellables)
        
        input.tappedPhotoItem
            .sink { [weak self] (assets, indexPath) in
                guard let self else {
                    return
                }
                
                let photoViewModel = DIContainer.shared.resolve(PhotoViewModel.self)
                photoViewModel.input.tappedPhotoItem.send((assets, indexPath))
                output.handlePhotoItem.send(currentControlNumber)
            }
            .store(in: &cancellables)
        
        input.tappedCollectionItem
            .sink { [weak self] date in
                guard let self else {
                    return
                }
                
                output.handleCollectionItem.send(date)
                output.handlePhotoItem.send(currentControlNumber)
            }
            .store(in: &cancellables)
        
        input.readyPhotos
            .sink { [weak self] in
                self?.output.handleIndicator.send()
            }
            .store(in: &cancellables)
    }
}
