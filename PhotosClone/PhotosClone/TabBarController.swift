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
        setUpViewControllers()
    }
    
    private func setUpViewControllers() {
        let locker = LockerViewController()
        let forYou = ForYouViewController()
        let album = AlbumViewController()
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
}
