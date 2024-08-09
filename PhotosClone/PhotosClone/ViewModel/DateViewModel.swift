//
//  DateViewModel.swift
//  PhotosClone
//
//  Created by minsong kim on 8/9/24.
//

import Combine
import UIKit

class DateViewModel {
    struct Input {
        let fetchAllDailyPhotos = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let removeIndicator = PassthroughSubject<Void, Never>()
    }
    
    private var cancellables = Set<AnyCancellable>()
    let input: Input
    let output: Output
    
    init() {
        self.input = Input()
        self.output = Output()
        settingBind()
    }
    
    func settingBind() {
        input.fetchAllDailyPhotos
            .sink { [weak self] in
                self?.output.removeIndicator.send()
            }
            .store(in: &cancellables)
    }
}

