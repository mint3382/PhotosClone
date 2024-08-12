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
    
    private var childViewController: UIViewController = DIContainer.shared.resolve(AllPhotosViewController.self)
    
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
        self.navigationController?.navigationBar.topItem?.title = ""

        bind()
        configureTimePeriodSegmentControl()
        configureChildViewController(DIContainer.shared.resolve(AllPhotosViewController.self))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
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
        
        viewModel.output.handleChildViewController
            .sink { [weak self] pastControlNumber in
                guard let self else { return }
                childViewController.removeFromParent()
                childViewController.view.removeFromSuperview()
                
                if timePeriodSegmentControl.selectedSegmentIndex == 0 {
                    childViewController = DIContainer.shared.resolve(YearPhotosViewController.self)
                } else if timePeriodSegmentControl.selectedSegmentIndex == 1 {
                    childViewController = DIContainer.shared.resolve(MonthPhotosViewController.self)
                } else if timePeriodSegmentControl.selectedSegmentIndex == 2 {
                    childViewController = DIContainer.shared.resolve(DayPhotosViewController.self)
                } else {
                    childViewController = DIContainer.shared.resolve(AllPhotosViewController.self)
                }
                configureChildViewController(childViewController)
            }
            .store(in: &cancellables)
        
        viewModel.output.handlePhotoItem
            .sink { [weak self] controlNumber in
                if controlNumber > 1 {
                    let photoViewModel = DIContainer.shared.resolve(PhotoViewModel.self)
                    let next = PhotoPageViewController(viewModel: photoViewModel)
                    self?.navigationController?.pushViewController(next, animated: false)
                } else {
                    self?.timePeriodSegmentControl.selectedSegmentIndex = controlNumber + 1
                    self?.viewModel.input.timePeriodSegmentControlSelected.send(controlNumber + 1)
                }
            }
            .store(in: &cancellables)
    }
    
    private func configureChildViewController(_ childViewController: UIViewController) {
        addChild(childViewController)
        view.insertSubview(childViewController.view, at: 0)
        
        childViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            childViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            childViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            childViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            childViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
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
