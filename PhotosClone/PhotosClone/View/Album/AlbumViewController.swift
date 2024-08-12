//
//  AlbumViewController.swift
//  PhotosClone
//
//  Created by minsong kim on 8/8/24.
//

import Combine
import UIKit
import Photos

class AlbumViewController: UIViewController {
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<AlbumSection, AnyHashable>?
    
    private let imageManager = PHCachingImageManager()
    
    var viewModel: AlbumViewModel
    var cancellables = Set<AnyCancellable>()
    
    init(viewModel: AlbumViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "앨범"
        view.backgroundColor = .white
        
        configureCollectionView()
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
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    //컬렉션뷰 등록
    private func registerCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
        collectionView.register(AlbumCell.self, forCellWithReuseIdentifier: AlbumCell.identifier)
        collectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderView.identifier)
        
        collectionView.setCollectionViewLayout(createLayout(), animated: true)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
    }
    
    //컬렉션뷰 레이아웃 등록
    private func createLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout(sectionProvider: { [weak self] sectionIndex, layoutEnvironment in
            guard let self, let sectionKind = AlbumSection(rawValue: sectionIndex) else {
                return self!.createAlbumSection()
            }
            let section: NSCollectionLayoutSection
            
            if sectionKind == .myAlbum {
                section = createAlbumSection()
            } else if sectionKind == .personAndPlace {
                section = createAlbumSection()
            } else if sectionKind == .mediaType {
                section = createListSection(layoutEnvironment: layoutEnvironment)
            } else {
                section = createListSection(layoutEnvironment: layoutEnvironment)
            }

            return section
        })
    }
    
    //레이아웃에 넣을 섹션 등록
    private func createAlbumSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.48),heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 4, bottom: 8, trailing: 4)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),heightDimension: .fractionalHeight(0.35))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .estimated(30))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        sectionHeader.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        section.boundarySupplementaryItems = [sectionHeader]
        
        return section
    }
    
    private func createListSection(layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let section = NSCollectionLayoutSection.list(using: .init(appearance: .sidebarPlain), layoutEnvironment: layoutEnvironment)
        section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .estimated(30))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        sectionHeader.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)
        section.boundarySupplementaryItems = [sectionHeader]
        
        return section
    }
    
    //ListCell 구성
    func createListCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, AlbumItem> {
        return UICollectionView.CellRegistration<UICollectionViewListCell, AlbumItem> { (cell, indexPath, item) in
            let asset = PhotoManager.shared.fetchAssetsFromCollection(item.collection)
            var content = UIListContentConfiguration.valueCell()
            content.text = item.title
            content.image = item.image
            content.secondaryText = "\(asset.count)"
            cell.contentConfiguration = content
            cell.accessories = [UICellAccessory.disclosureIndicator()]
        }
    }
    
    //디퍼블 데이터 소스 세팅
    private func setDataSource() {
        let listCellRegistration = createListCellRegistration()
        
        dataSource = UICollectionViewDiffableDataSource<AlbumSection, AnyHashable>(
            collectionView: collectionView,
            cellProvider: { collectionView, indexPath, collection in
                guard let section = AlbumSection(rawValue: indexPath.section) else {
                    return UICollectionViewCell()
                }
                
                if section == .myAlbum {
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: AlbumCell.identifier,
                        for: indexPath) as? AlbumCell else {
                        return UICollectionViewCell()
                    }
                    
                    if let collection = collection as? PHAssetCollection {
                        let asset = PhotoManager.shared.fetchAssetsFromCollection(collection)
                        
                        if asset.count > 0 {
                            PhotoManager.shared.getImageFromAsset(asset[0]) { image in
                                cell.configureImage(image: image)
                                if indexPath.item < 2 {
                                    cell.configureTitle(section.items[indexPath.item].title)
                                } else {
                                    cell.configureTitle(collection.localizedTitle)
                                }
                                cell.configureCount("\(asset.count)")
                            }
                        } else {
                            cell.configureImage(image: UIImage(resource: .no))
                            cell.configureTitle(collection.localizedTitle)
                            cell.configureCount("0")
                        }
                    }
                    
                    return cell
                } else if section == .personAndPlace {
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: AlbumCell.identifier,
                        for: indexPath) as? AlbumCell else {
                        return UICollectionViewCell()
                    }
                    
                    if let collection = collection as? PHAssetCollection {
                        let asset = PhotoManager.shared.fetchAssetsFromCollection(collection)
                        
                        if asset.count > 0 {
                            PhotoManager.shared.getImageFromAsset(asset[0]) { image in
                                cell.configureImage(image: image)
                                cell.configureTitle(collection.localizedTitle)
                                cell.configureCount("\(asset.count)")
                            }
                        } else {
                            cell.configureImage(image: UIImage(resource: .no))
                            cell.configureTitle(collection.localizedTitle)
                            cell.configureCount("0")
                        }
                    } else {
                        cell.configureImage(image: .no)
                        cell.configureTitle("ERROR")
                    }
                    
                    return cell
                } else {
                    return collectionView.dequeueConfiguredReusableCell(using: listCellRegistration, for: indexPath, item: collection as? AlbumItem)
                }
        })
        
        let headerRegistration = UICollectionView.SupplementaryRegistration<HeaderView>(elementKind: UICollectionView.elementKindSectionHeader) {
            supplementaryView, elementKind, indexPath in
            supplementaryView.configureLabelUI()
            supplementaryView.configureLabel(text: AlbumSection(rawValue: indexPath.section)?.description, fontSize: 20.0)
        }
        
        dataSource?.supplementaryViewProvider = { [weak self] (view, kind, index) in
            self?.collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: index)
        }
    }
    
    //스냅샷 세팅
    private func setSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<AlbumSection, AnyHashable>()
        snapshot.appendSections([.myAlbum, .personAndPlace, .mediaType, .etc])
        
        let myAlbums = PhotoManager.shared.categorizeAlbums(section: .myAlbum)
        let personAndOthers = PhotoManager.shared.categorizeAlbums(section: .personAndPlace)
        let mediaTypes = AlbumSection.mediaType.items
        let etc = AlbumSection.etc.items
        
        snapshot.appendItems(myAlbums, toSection: .myAlbum)
        snapshot.appendItems(personAndOthers, toSection: .personAndPlace)
        snapshot.appendItems(mediaTypes, toSection: .mediaType)
        snapshot.appendItems(etc, toSection: .etc)
        
        dataSource?.apply(snapshot)
    }
}

extension AlbumViewController: UICollectionViewDelegate { 
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let section = AlbumSection(rawValue: indexPath.section)
        
        switch section {
        case .myAlbum:
            if indexPath.item < 2, let album = section?.items[indexPath.item] {
                viewModel.input.tappedAlbumItem.send((album.title, album.collection))
            } else if let collection = PhotoManager.shared.categorizeAlbums(section: section ?? .myAlbum)[indexPath.item] as? PHAssetCollection {
                viewModel.input.tappedAlbumItem.send((collection.localizedTitle ?? "", collection))
            }
        case .personAndPlace:
            if let collection = PhotoManager.shared.categorizeAlbums(section: section ?? .personAndPlace)[indexPath.item] as? PHAssetCollection {
                viewModel.input.tappedAlbumItem.send((collection.localizedTitle ?? "", collection))
            }
        case .mediaType:
            let album = section?.items[indexPath.item] ?? .video
            viewModel.input.tappedAlbumItem.send((album.title, album.collection))
        case .etc:
            let album = section?.items[indexPath.item] ?? .download
            viewModel.input.tappedAlbumItem.send((album.title, album.collection))
        case nil:
            return
        }
        
        let nextView = PhotosInAlbumViewController(viewModel: viewModel)
        navigationController?.pushViewController(nextView, animated: false)
    }
}
