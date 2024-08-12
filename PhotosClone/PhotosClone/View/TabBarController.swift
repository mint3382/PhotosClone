//
//  TabBarController.swift
//  PhotosClone
//
//  Created by minsong kim on 8/8/24.
//

import UIKit

class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        registerViewControllers()
        setUpViewControllers()
        UITabBar.appearance().backgroundColor = .white
        tabBar.barTintColor = .white
                
        //그림자 및 테두리 제거
        tabBar.backgroundImage = nil
        tabBar.shadowImage = nil
    }
    
    private func setUpViewControllers() {
        let locker = UINavigationController(rootViewController: DIContainer.shared.resolve(LockerViewController.self))
        let forYou = ForYouViewController()
        let album = UINavigationController(rootViewController: AlbumViewController(viewModel: AlbumViewModel()))
        let search = SearchViewController()
        
        locker.tabBarItem.image = UIImage(systemName: "photo.fill.on.rectangle.fill")
        locker.tabBarItem.title = "보관함"
        
        forYou.tabBarItem.image = UIImage(systemName: "heart.text.square.fill")
        forYou.tabBarItem.title = "For You"
        
        album.tabBarItem.image = UIImage(systemName: "square.stack.fill")
        album.tabBarItem.title = "앨범"
        
        search.tabBarItem.image = UIImage(systemName: "magnifyingglass")
        search.tabBarItem.title = "검색"
        
        viewControllers = [locker, forYou, album, search]
    }
    
    private func registerViewControllers() {
        let photoViewModel = PhotoViewModel()
        DIContainer.shared.register(PhotoViewModel.self, dependency: photoViewModel)
        
        registerLockerViewControllers()
    }
    
    private func registerLockerViewControllers() {
        let lockerViewModel = LockerViewModel()
        let allPhotosViewController = AllPhotosViewController(viewModel: lockerViewModel)
        let dayPhotosViewController = DayPhotosViewController(viewModel: lockerViewModel)
        let monthPhotosViewController = MonthPhotosViewController(viewModel: lockerViewModel)
        let yearPhotosViewController = YearPhotosViewController(viewModel: lockerViewModel)
        
        DIContainer.shared.register(AllPhotosViewController.self, dependency: allPhotosViewController)
        DIContainer.shared.register(DayPhotosViewController.self, dependency: dayPhotosViewController)
        DIContainer.shared.register(MonthPhotosViewController.self, dependency: monthPhotosViewController)
        DIContainer.shared.register(YearPhotosViewController.self, dependency: yearPhotosViewController)
        
        let lockerViewController = LockerViewController(viewModel: lockerViewModel)
        DIContainer.shared.register(LockerViewController.self, dependency: lockerViewController)
    }
}
