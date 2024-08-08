//
//  LockerViewModel.swift
//  PhotosClone
//
//  Created by minsong kim on 8/8/24.
//

import Combine
import UIKit

class LockerViewModel {
    struct Input {
        let timePeriodSegmentControlSelected = PassthroughSubject<Int, Never>()
    }
    
    struct Output {
        let viewTransitionSubject = PassthroughSubject<(past: UIViewController, current: UIViewController), Never>()
    }
    
    private var cancellables = Set<AnyCancellable>()
    let input: Input
    let output: Output
    
    private var pastChildViewController: UIViewController = DIContainer.shared.resolve(AllPhotosViewController.self)
    
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
                
                switch selectedNumber {
                case 0:
                    let currentViewController = DIContainer.shared.resolve(YearPhotosViewController.self)
                    output.viewTransitionSubject.send((pastChildViewController,currentViewController))
                    pastChildViewController = currentViewController
                case 1:
                    let currentViewController = DIContainer.shared.resolve(MonthPhotosViewController.self)
                    output.viewTransitionSubject.send((pastChildViewController,currentViewController))
                    pastChildViewController = currentViewController
                case 2:
                    let currentViewController = DIContainer.shared.resolve(DayPhotosViewController.self)
                    output.viewTransitionSubject.send((pastChildViewController,currentViewController))
                    pastChildViewController = currentViewController
                default:
                    let currentViewController = DIContainer.shared.resolve(AllPhotosViewController.self)
                    output.viewTransitionSubject.send((pastChildViewController,currentViewController))
                    pastChildViewController = currentViewController
                }
            }
            .store(in: &cancellables)
    }
}
