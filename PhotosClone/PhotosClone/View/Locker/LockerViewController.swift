//
//  LockerViewController.swift
//  PhotosClone
//
//  Created by minsong kim on 8/7/24.
//

import Combine
import UIKit

class LockerViewController: UIViewController {
    private let timePeriodSegmentControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["연", "월", "일", "모든 사진"])
        control.selectedSegmentIndex = 3
        control.selectedSegmentTintColor = .systemGray2
        control.backgroundColor = .systemGray6
        control.translatesAutoresizingMaskIntoConstraints = false
        
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.darkGray]
        let selectedTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        control.setTitleTextAttributes(titleTextAttributes, for: .normal)
        control.setTitleTextAttributes(selectedTitleTextAttributes, for: .selected)
        
        return control
    }()
    
    var viewModel: LockerViewModel
    var cancellables = Set<AnyCancellable>()
    
    init(viewModel: LockerViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        bind()
        configureTimePeriodSegmentControl()
        configureChildViewController(DIContainer.shared.resolve(AllPhotosViewController.self))
    }
    
    private func bind() {
        timePeriodSegmentControl.publisher(for: .valueChanged)
            .sink { [weak self] in
                guard let self else {
                    return
                }
                
                viewModel.input.timePeriodSegmentControlSelected.send(timePeriodSegmentControl.selectedSegmentIndex)
            }
            .store(in: &cancellables)
        
        viewModel.output.viewTransitionSubject
            .sink { [weak self] childViewControllers in
                guard let self else {
                    return
                }
                
                childViewControllers.past.removeFromParent()
                childViewControllers.past.view.removeFromSuperview()
                configureChildViewController(childViewControllers.current)
            }
            .store(in: &cancellables)
    }
    
    private func configureChildViewController(_ childViewController: UIViewController) {
        addChild(childViewController)
        view.insertSubview(childViewController.view, at: 0)
        
        childViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            childViewController.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            childViewController.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            childViewController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            childViewController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func configureTimePeriodSegmentControl() {
        view.addSubview(timePeriodSegmentControl)
        
        NSLayoutConstraint.activate([
            timePeriodSegmentControl.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            timePeriodSegmentControl.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            timePeriodSegmentControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -4),
            timePeriodSegmentControl.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
}
