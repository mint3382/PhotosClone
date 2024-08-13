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
    
    private var photosByDate: [String: [PHAsset]] = [:]
    private var dateSection: Set<String> = []
    private var sortedDateSection: [String] = []
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<String, PHAsset>?
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        
        return dateFormatter
    }()
    private var isFirstView: Bool = true
    
    private let imageManager = PHCachingImageManager()
    
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
        configureIndicatorView()
        categorizePhotosByDate()
        bind()
        
        PHPhotoLibrary.shared().register(self)
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    private func bind() {
        viewModel.output.handleIndicator
            .sink { [weak self] in
                self?.loadingIndicatorView.removeFromSuperview()
            }
            .store(in: &cancellables)
        
        viewModel.output.handleCollectionItem
            .sink { [weak self] date in
                guard let self else { return }
                
                let day = dateFormatter.string(from: date)
                if let section = sortedDateSection.firstIndex(of: day) {
                    collectionView.scrollToItem(at: IndexPath(item: 0, section: section), at: .top, animated: false)
                }
            }
            .store(in: &cancellables)
    }
    
    private func categorizePhotosByDate() {
        Task {
            PhotoManager.shared.allPhotos.forEach { asset in
                if let creationDate = asset.creationDate {
                    let day = self.dateFormatter.string(from: creationDate)
                    self.dateSection.insert(day)
                    self.photosByDate[day, default: []].append(asset)
                }
            }
            sortedDateSection = Array(dateSection).sorted()
            
            await MainActor.run {
                if isFirstView {
                    configureCollectionView()
                    configureSectionTitleLabel()
                    scrollToBottom()
                    viewModel.input.readyPhotos.send()
                    isFirstView = false
                } else {
                    collectionView.reloadData()
                }
            }
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
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    //컬렉션뷰 등록
    private func registerCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.identifier)
        collectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderView.identifier)
        
        collectionView.setCollectionViewLayout(createLayout(), animated: true)
        collectionView.delegate = self
    }
    
    //컬렉션뷰 레이아웃 등록
    private func createLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout(sectionProvider: { [weak self] sectionIndex, _ in
            guard let self = self else {
                return NSCollectionLayoutSection(group: NSCollectionLayoutGroup(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1.0))))
            }
            
            // 섹션별 레이아웃 선택
            let dateSectionIndex = sortedDateSection[sectionIndex]
            let itemCount = photosByDate[dateSectionIndex]?.count ?? 1
            
            let layoutSection: NSCollectionLayoutSection
            if itemCount % 4 == 0 {
                layoutSection = self.create4ItemSection()
            } else {
                layoutSection = self.create1ItemSection()
            }
            
            // 마지막 섹션에만 추가적인 inset을 적용
            if sectionIndex == self.sortedDateSection.count - 1 {
                layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 0, bottom: 50, trailing: 0)
            }
            
            return layoutSection
        })
    }
    
    //레이아웃에 넣을 섹션 등록
    private func create1ItemSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1.0))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    
        let section = NSCollectionLayoutSection(group: group)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .estimated(30))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, containerAnchor: NSCollectionLayoutAnchor(edges: [.top, .leading], fractionalOffset: CGPoint(x: 4, y: -36)))
        sectionHeader.pinToVisibleBounds = true
        sectionHeader.zIndex = Int.max
        sectionHeader.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 12, bottom: 0, trailing: 12)
        section.boundarySupplementaryItems = [sectionHeader]
        section.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 0, bottom: 1, trailing: 0)

        return section
    }
    
    private func create4ItemSection() -> NSCollectionLayoutSection {
        let leadingItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.7), heightDimension: .fractionalHeight(1.0)))
        
        let trailingItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.333)))
        let trailingGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.3), heightDimension: .fractionalHeight(1.0)), subitems: [trailingItem])
        
        let nestedGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1.0)),
            subitems: [leadingItem, trailingGroup])
        
        let section = NSCollectionLayoutSection(group: nestedGroup)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .estimated(30))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, containerAnchor: NSCollectionLayoutAnchor(edges: [.top, .leading], fractionalOffset: CGPoint(x: 4, y: -36)))
        sectionHeader.pinToVisibleBounds = true
        sectionHeader.zIndex = Int.max
        sectionHeader.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 12, bottom: 0, trailing: 12)
        
        section.boundarySupplementaryItems = [sectionHeader]
        section.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 0, bottom: 1, trailing: 0)
        
        return section
    }
    
    //디퍼블 데이터 소스 세팅
    private func setDataSource() {
        dataSource = UICollectionViewDiffableDataSource<String, PHAsset>(
            collectionView: collectionView,
            cellProvider: { collectionView, indexPath, asset in
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: PhotoCell.identifier,
                    for: indexPath) as? PhotoCell else {
                    return UICollectionViewCell()
                }
                
                self.imageManager.requestImage(for: asset, targetSize: CGSize(width: 300, height: 300), contentMode: .aspectFill, options: nil) { image, _ in
                    if let image = image {
                        cell.configureImage(image: image)
                    }
                }
                
                return cell
        })
        
        let headerRegistration = UICollectionView.SupplementaryRegistration<HeaderView>(elementKind: UICollectionView.elementKindSectionHeader) {
            supplementaryView, elementKind, indexPath in
            let day = self.sortedDateSection[indexPath.section]
            supplementaryView.configureLabelUI()
            supplementaryView.configureLabel(text: day, fontSize: 20.0)
            supplementaryView.changeTitleColor(.white)
        }
        
        dataSource?.supplementaryViewProvider = { [weak self] (view, kind, index) in
            self?.collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: index)
        }
    }
    
    //스냅샷 세팅
    private func setSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<String, PHAsset>()
        snapshot.appendSections(sortedDateSection)
        
        for (date, dayAssets) in photosByDate {
            let uniqueAssets = Set(dayAssets.map { $0.localIdentifier }).map { id in
                dayAssets.first { $0.localIdentifier == id }!
            }
            snapshot.appendItems(uniqueAssets, toSection: date)
        }
            
        
        dataSource?.apply(snapshot)
    }
}

extension DayPhotosViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let date = sortedDateSection[indexPath.section]
        if let assets = photosByDate[date] {
            viewModel.input.tappedPhotoItem.send((assets, IndexPath(item: indexPath.item, section: 0)))
        }
    }
}

extension DayPhotosViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        Task { @MainActor [weak self]  in
            guard let self = self else { return }
            guard let changes = changeInstance.changeDetails(for: PhotoManager.shared.allAssets) else { return }
            
            let changeAssets = changes.fetchResultAfterChanges.objects(at: IndexSet(integersIn: 0..<changes.fetchResultAfterChanges.count))
            
            var snapshot = dataSource?.snapshot()
            
            // CollectionView 업데이트
            if changes.hasIncrementalChanges {
                if let removed = changes.removedIndexes, !removed.isEmpty {
                    snapshot?.deleteItems(removed.map { PhotoManager.shared.allPhotos[$0]})
                }
                
                if let inserted = changes.insertedIndexes, !inserted.isEmpty {
                    let assets = inserted.map { changeAssets[$0] }
                    let uniqueAssets = Set(assets.map { $0.localIdentifier }).map { id in
                        assets.first { $0.localIdentifier == id }!
                    }
                    let dates = uniqueAssets.compactMap { $0.creationDate }.map { self.dateFormatter.string(from: $0) }
                    for (index, asset) in uniqueAssets.enumerated() {
                        snapshot?.appendItems([asset], toSection: dates[index])
                    }
                }
                PhotoManager.shared.allPhotos = changeAssets
                dataSource?.apply(snapshot!)
                categorizePhotosByDate()
            } else {
                self.setSnapshot()
            }
        }
    }
}
