//
//  PhotoViewController.swift
//  PhotosClone
//
//  Created by minsong kim on 8/12/24.
//

import Combine
import UIKit
import Photos

class PhotoViewController: UIViewController {
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Int, PHAsset>?
    
    private let imageManager = PHCachingImageManager()
    private let dateFormatter = DateFormatter()
    
    var viewModel: PhotoViewModel
    var cancellables = Set<AnyCancellable>()
    
    init(viewModel: PhotoViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        configureCollectionView()
        bind()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.scrollToItem(at: viewModel.selectedIndex ?? IndexPath(item: 0, section: 0), at: .centeredVertically, animated: false)
    }
    
    func bind() {        
        viewModel.output.changeImage
            .sink { [weak self] indexPath in
                self?.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
            }
            .store(in: &cancellables)
        
        viewModel.output.handleSelectItem
            .sink { [weak self] isItemOnly in
                if isItemOnly {
                    self?.view.backgroundColor = .black
                    self?.collectionView.backgroundColor = .black
                } else {
                    self?.view.backgroundColor = .white
                    self?.collectionView.backgroundColor = .white
                }
            }
            .store(in: &cancellables)
        
        viewModel.output.handlePage
            .sink { [weak self] data in
                guard let self else { return }
                if data.hasImage {
                    var snapshot = dataSource?.snapshot()
                    snapshot?.deleteItems([data.deletedAsset])
                    dataSource?.apply(snapshot ?? NSDiffableDataSourceSnapshot())
                } else {
                    navigationController?.popViewController(animated: true)
                }
            }
            .store(in: &cancellables)
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
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor)
        ])
    }
    
    //컬렉션뷰 등록
    private func registerCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.identifier)
        
        collectionView.setCollectionViewLayout(createLayout(), animated: true)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
    }
    
    //컬렉션뷰 레이아웃 등록
    private func createLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout(sectionProvider: { [weak self] sectionIndex, layoutEnvironment in
            return self?.createSection()
        })
    }
    
    //레이아웃에 넣을 섹션 등록
    private func createSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),heightDimension: .fractionalHeight(1.0))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        
        return section
    }
    
    //디퍼블 데이터 소스 세팅
    private func setDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Int, PHAsset>(
            collectionView: collectionView,
            cellProvider: { [self] collectionView, indexPath, asset in
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: PhotoCell.identifier,
                    for: indexPath) as? PhotoCell else {
                    return UICollectionViewCell()
                }
                
                let size = CGSize(width: cell.intrinsicContentSize.width, height: cell.intrinsicContentSize.height)
                PhotoManager.shared.getImageFromAsset(asset, targetSize: size) { image in
                    cell.configureImage(image: image, contentMode: .scaleAspectFit)
                }
                dateFormatter.dateFormat = "yyyy년 MM월 dd일"
                dateFormatter.locale = Locale(identifier: "ko_KR")
                var title = ""
                let today = dateFormatter.string(from: Date())
                let yesterday = dateFormatter.string(from: Date().addingTimeInterval(3600 * -24))
                if let date = asset.creationDate {
                    title = dateFormatter.string(from: date)
                    
                    if title == today {
                        title = "오늘"
                    } else if title == yesterday {
                        title = "어제"
                    }
                    
                    dateFormatter.dateFormat = "a hh:mm"
                    let subtitle = dateFormatter.string(from: date)
                    viewModel.input.changeDisplayItem.send((title, subtitle))
                    viewModel.input.changeItemScroll.send(indexPath)
                }
                
                return cell
            })
    }
    
    //스냅샷 세팅
    private func setSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, PHAsset>()
        snapshot.appendSections([0])
        snapshot.appendItems(viewModel.assets)
        
        dataSource?.apply(snapshot)
    }
}

extension PhotoViewController: UICollectionViewDelegate { 
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        viewModel.input.tappedInsidePhoto.send(indexPath)
        viewModel.input.selectedItem.send()
    }
}
