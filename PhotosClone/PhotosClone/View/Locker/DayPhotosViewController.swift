//
//  DayPhotosViewController.swift
//  PhotosClone
//
//  Created by minsong kim on 8/8/24.
//

import Combine
import UIKit
import Photos

class DayPhotosViewController: UIViewController {
    private let sectionTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 24.0)
        
        return label
    }()
    
    let loadingIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.color = .gray
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private var photosByDate: [Date: [PHAsset]] = [:]
    private var dateSection: Set<Date> = []
    private var sortedDateSection: [Date] = []
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Date, PHAsset>?
    
    private var allPhotos: PHFetchResult<PHAsset>?
    private let imageManager = PHCachingImageManager()
    
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
            let allPhotosOptions = PHFetchOptions()
            allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
            allPhotos = PHAsset.fetchAssets(with: allPhotosOptions)
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
        Task {
            allPhotos?.enumerateObjects { (asset, _, _) in
                if let creationDate = asset.creationDate {
                    self.dateSection.insert(creationDate)
                    self.photosByDate[creationDate, default: []].append(asset)
                }
            }
            sortedDateSection = Array(dateSection).sorted()
            viewModel.input.fetchAllDailyPhotos.send()
        }
        
        Task { @MainActor in
            configureCollectionView()
            configureSectionTitleLabel()
            scrollToBottom()
        }
    }
    
    private func scrollToBottom() {
        guard let lastSection = sortedDateSection.last,
              let lastItems = photosByDate[lastSection] else {
            return
        }
        
        let lastItemIndex = lastItems.count - 1
        let lastIndexPath = IndexPath(item: lastItemIndex, section: dateSection.count - 1)
        
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
    
    private func configureSectionTitleLabel() {
        view.addSubview(sectionTitleLabel)
        
        NSLayoutConstraint.activate([
            sectionTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            sectionTitleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            sectionTitleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8)
        ])
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
    
    //컬렉션뷰 등록
    private func registerCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.id)
        
        collectionView.setCollectionViewLayout(createLayout(), animated: true)
        collectionView.delegate = self
    }
    
    //컬렉션뷰 레이아웃 등록
    private func createLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout(sectionProvider: { [weak self] sectionIndex, _ in
            guard let self = self else {
                return NSCollectionLayoutSection(group: NSCollectionLayoutGroup(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1.0))))
            }
            
            // 섹션별 레이아웃 선택
            let dateSectionIndex = sortedDateSection[sectionIndex]
            let itemCount = photosByDate[dateSectionIndex]?.count ?? 1
            
            let section: NSCollectionLayoutSection
            if itemCount >= 3 {
                section = self.create3ItemSection()
            } else {
                section = self.create1ItemSection()
            }
            
            // 마지막 섹션에만 추가적인 inset을 적용
            if sectionIndex == self.sortedDateSection.count - 1 {
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 50, trailing: 0)
            }
            
            return section
        })
    }
    
    //레이아웃에 넣을 섹션 등록
    private func create1ItemSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1.0))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(8)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        
        return section
    }
    
    private func create3ItemSection() -> NSCollectionLayoutSection {
        let leadingItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.7),
                                               heightDimension: .fractionalHeight(1.0)))
        
        let trailingItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalHeight(0.3)))
        let trailingGroup = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.3),
                                               heightDimension: .fractionalHeight(1.0)),
            subitem: trailingItem, count: 2)
        
        let nestedGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalHeight(0.4)),
            subitems: [leadingItem, trailingGroup])
        let section = NSCollectionLayoutSection(group: nestedGroup)
        
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
                
                self.imageManager.requestImage(for: asset, targetSize: CGSize(width: 300, height: 300), contentMode: .aspectFill, options: nil) { image, _ in
                    if let image = image {
                        cell.configureImage(image: image)
                    }
                }
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy년 MM월 dd일"
                if let currentDate = asset.creationDate {
                    self.sectionTitleLabel.text = dateFormatter.string(from: currentDate)
                }
                
                return cell
        })
    }
    
    //스냅샷 세팅
    private func setSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Date, PHAsset>()
        snapshot.appendSections(sortedDateSection)
        
        for (date, dayAssets) in photosByDate {
            snapshot.appendItems(dayAssets, toSection: date)
        }
        
        dataSource?.apply(snapshot)
    }
}

extension DayPhotosViewController: UICollectionViewDelegate { }
