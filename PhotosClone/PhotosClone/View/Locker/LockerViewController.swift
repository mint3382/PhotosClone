//
//  LockerViewController.swift
//  PhotosClone
//
//  Created by minsong kim on 8/7/24.
//

import UIKit
import Photos

class LockerViewController: UIViewController {
    private lazy var flowLayout = self.createFlowLayout()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.flowLayout)
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
    
    private var fetchAsset: PHFetchResult<PHAsset>?
    private let imageManager = PHCachingImageManager()
    private var imageSize: CGSize = .zero

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        if fetchAsset == nil {
            let allPhotosOptions = PHFetchOptions()
            allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
            fetchAsset = PHAsset.fetchAssets(with: allPhotosOptions)
        }
        
        configureCollectionView()
        configureCollectionViewUI()
        configureTimePeriodSegmentControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let scale = UIScreen.main.scale
        let cellSize = flowLayout.itemSize
        imageSize = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        scrollToBottom()
    }
    
    private func scrollToBottom() {
        guard let fetchAsset = fetchAsset, 
                fetchAsset.count > 0 else {
            return
        }
        
        let lastItemIndex = fetchAsset.count - 1
        let lastIndexPath = IndexPath(item: lastItemIndex, section: 0)
        
        collectionView.scrollToItem(at: lastIndexPath, at: .bottom, animated: false)
        
        let additionalScrollHeight: CGFloat = 50.0
        collectionView.contentOffset = CGPoint(x: 0, y: collectionView.contentOffset.y + additionalScrollHeight)
    }
    
    //컬렉션뷰 위치 잡기
    private func configureCollectionViewUI() {
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    //컬렉션뷰 등록하기
    private func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.id)
    }
    
    private func createFlowLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        let width = view.bounds.inset(by: view.safeAreaInsets).width / 5
        
        layout.itemSize = CGSize(width: width - 2, height: width - 2)
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        
        return layout
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

extension LockerViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return fetchAsset?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let asset = fetchAsset?.object(at: indexPath.item) else {
            fatalError("Failed Asset unwrapping")
        }
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.id, for: indexPath) as? PhotoCell else {
            fatalError("Unexpected cell in collection view")
        }
        
        cell.representedAssetIdentifier = asset.localIdentifier
        imageManager.requestImage(for: asset, targetSize: imageSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
            if cell.representedAssetIdentifier == asset.localIdentifier {
                cell.configureImage(image: image)
            }
        })
        
        return cell
    }
}

//#Preview {
//    let vc = LockerViewController()
//    
//    return vc
//}
