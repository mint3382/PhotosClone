//
//  AllPhotosViewController.swift
//  PhotosClone
//
//  Created by minsong kim on 8/8/24.
//

import Combine
import UIKit
import Photos

class AllPhotosViewController: UIViewController {
    private lazy var flowLayout = self.createFlowLayout()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.flowLayout)
    
    private let imageManager = PHCachingImageManager()
    private var imageSize: CGSize = .zero
    
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
        
        let dateOptions = PHFetchOptions()
        dateOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        PhotoManager.shared.fetchPhotos(with: dateOptions)
        
        configureCollectionView()
        configureCollectionViewUI()
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
        let fetchAsset = PhotoManager.shared.allPhotos
        guard fetchAsset.count > 0 else {
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
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    //컬렉션뷰 등록하기
    private func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.identifier)
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
}

extension AllPhotosViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return PhotoManager.shared.allPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.identifier, for: indexPath) as? PhotoCell else {
            fatalError("Unexpected cell in collection view")
        }
        let asset = PhotoManager.shared.allPhotos[indexPath.item]
        
        cell.representedAssetIdentifier = asset.localIdentifier
        imageManager.requestImage(for: asset, targetSize: imageSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
            if cell.representedAssetIdentifier == asset.localIdentifier {
                cell.configureImage(image: image)
            }
        })
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let assets = PhotoManager.shared.allPhotos
        
        viewModel.input.tappedPhotoItem.send((assets, indexPath))
    }
}
