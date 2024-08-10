//
//  YearPhotosViewController.swift
//  PhotosClone
//
//  Created by minsong kim on 8/8/24.
//

import Combine
import UIKit
import Photos

class YearPhotosViewController: UIViewController {
    let loadingIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.color = .gray
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private var photosByDate: [Date: PHAsset] = [:]
    private var dateSection: Set<Date> = []
    private var sortedDateSection: [Date] = []
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Date, PHAsset>?
    
    private var allPhotos: PHFetchResult<PHAsset>?
    private let imageManager = PHCachingImageManager()
    let dateFormatter = DateFormatter()
    
    var viewModel: DateViewModel
    var cancellables = Set<AnyCancellable>()
    
    init(viewModel: DateViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureIndicatorView()
        
        if allPhotos == nil {
            allPhotos = PHAsset.fetchAssets(with: nil)
            categorizePhotosByDate()
        }
        
        bind()
    }
    
    private func bind() {
        viewModel.output.removeIndicator
            .sink { [weak self] in
                self?.loadingIndicatorView.removeFromSuperview()
            }
            .store(in: &cancellables)
    }
    
    private func categorizePhotosByDate() {
        var dayDateSet = Set<Date>()
        Task {
            allPhotos?.enumerateObjects { [weak self] (asset, _, _) in
                self?.dateFormatter.dateFormat = "yyyy년"
                
                guard let self, let creationDate = asset.creationDate else {
                    return
                }
                
                let yearDate = dateFormatter.string(from: creationDate)
                let creationYearDate = dateFormatter.date(from: yearDate)
                
                if let creationYearDate, (photosByDate[creationYearDate] == nil) {
                    self.dateSection.insert(creationYearDate)
                    self.photosByDate[creationYearDate] = asset
                }
            }
            
            sortedDateSection = Array(dateSection).sorted()
            viewModel.input.fetchAllDailyPhotos.send()
        }
        
        Task { @MainActor in
            configureCollectionView()
            scrollToBottom()
        }
    }
    
    private func scrollToBottom() {
        guard let lastSection = sortedDateSection.last else {
            return
        }
        
        let lastIndexPath = IndexPath(item: 0, section: dateSection.count - 1)
        
        collectionView.scrollToItem(at: lastIndexPath, at: .bottom, animated: false)
        
        let additionalScrollHeight: CGFloat = 50.0
        collectionView.contentOffset = CGPoint(x: 0, y: collectionView.contentOffset.y + additionalScrollHeight)
    }
    
    private func configureIndicatorView() {
        view.addSubview(loadingIndicatorView)
        loadingIndicatorView.startAnimating()
        
        NSLayoutConstraint.activate([
            loadingIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    //컬렉션뷰 설정
    private func configureCollectionView() {
        registerCollectionView()
        configureCollectionViewUI()
        setDataSource()
        setSnapshot()
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
    
    //컬렉션뷰 등록
    private func registerCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.id)
        collectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderView.identifier)
        
        collectionView.setCollectionViewLayout(createLayout(), animated: true)
        collectionView.delegate = self
    }
    
    //컬렉션뷰 레이아웃 등록
    private func createLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout(sectionProvider: { [weak self] sectionIndex, _ in
            let section = self?.create1ItemSection()
            
            // 마지막 섹션에만 추가적인 inset을 적용
            if sectionIndex == (self?.sortedDateSection.count ?? 1) - 1 {
                section?.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 50, trailing: 0)
            }
            
            return section
        })
    }
    
    //레이아웃에 넣을 섹션 등록
    private func create1ItemSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.7))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 24, bottom: 12, trailing: 24)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.7))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                     heightDimension: .estimated(50))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        sectionHeader.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 32, bottom: 0, trailing: 32)
        section.boundarySupplementaryItems = [sectionHeader]
        
        return section
    }
    
    //디퍼블 데이터 소스 세팅
    private func setDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Date, PHAsset>(
            collectionView: collectionView,
            cellProvider: { collectionView, indexPath, asset in
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: PhotoCell.id,
                    for: indexPath) as? PhotoCell else {
                    return UICollectionViewCell()
                }
                
                let options = PHImageRequestOptions()
                options.deliveryMode = .opportunistic
                options.isNetworkAccessAllowed = true
                options.isSynchronous = false
                
                self.imageManager.requestImage(for: asset, targetSize: CGSize(width: 300, height: 300), contentMode: .aspectFill, options: nil) { image, _ in
                    Task {
                        if let image = image {
                            cell.configureImage(image: image)
                        }
                    }
                }
                
                cell.configureCellShadowAndCornerRadius()
                
                return cell
        })
        
        let headerRegistration = UICollectionView.SupplementaryRegistration<HeaderView>(elementKind: UICollectionView.elementKindSectionHeader) { [weak self]
            supplementaryView, elementKind, indexPath in
            guard let self else {
                return
            }
            
            let date = sortedDateSection[indexPath.section]
            dateFormatter.dateFormat = "yyyy년"
            
            let titleDate = dateFormatter.string(from: date)
            
            supplementaryView.configureLabel(text: titleDate)
        }
        
        dataSource?.supplementaryViewProvider = { [weak self] (view, kind, index) in
            self?.collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: index)
        }
    }
    
    //스냅샷 세팅
    private func setSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Date, PHAsset>()
        snapshot.appendSections(sortedDateSection)

        for (date, yearlyAssets) in photosByDate {
            snapshot.appendItems([yearlyAssets], toSection: date)
        }
        
        dataSource?.apply(snapshot)
    }
}

extension YearPhotosViewController: UICollectionViewDelegate { }
