//
//  PhotoPageViewController.swift
//  PhotosClone
//
//  Created by minsong kim on 8/12/24.
//

import Combine
import UIKit
import Photos

class PhotoPageViewController: UIViewController {
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Int, PHAsset>?
    
    private let childViewController: UIViewController
    private let imageManager = PHCachingImageManager()
    
    var viewModel: PhotoViewModel
    var cancellables = Set<AnyCancellable>()
    
    init(viewModel: PhotoViewModel) {
        self.viewModel = viewModel
        self.childViewController = PhotoViewController(viewModel: viewModel)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        configureCollectionView()
        configureChildViewController(childViewController)
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.tintColor = .systemBlue
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.scrollToItem(at: viewModel.selectedIndex ?? IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func bind() {
        viewModel.output.changeImage
            .sink { [weak self] indexPath in
                self?.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            }
            .store(in: &cancellables)
        
        viewModel.output.changeTitle
            .sink { [weak self] text in
                self?.setupTitleView(largeText: text.title, smallText: text.subTitle)
            }
            .store(in: &cancellables)
        
        viewModel.output.changeScroll
            .sink { [weak self] indexPath in
                self?.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            }
            .store(in: &cancellables)
    }
    
    private func setupTitleView(largeText: String, smallText: String) {
        let titleParameters = [NSAttributedString.Key.font : UIFont.preferredFont(forTextStyle: .subheadline)]
        let subtitleParameters = [NSAttributedString.Key.font : UIFont.preferredFont(forTextStyle: .caption1)]

        let title:NSMutableAttributedString = NSMutableAttributedString(string: largeText, attributes: titleParameters)
        let subtitle:NSAttributedString = NSAttributedString(string: smallText, attributes: subtitleParameters)

        title.append(NSAttributedString(string: "\n"))
        title.append(subtitle)

        let size = title.size()

        let width = size.width
        guard let height = navigationController?.navigationBar.frame.size.height else {
            return
        }

        let titleLabel = UILabel(frame: CGRectMake(0,0, width, height))
        titleLabel.attributedText = title
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center

        navigationItem.titleView = titleLabel
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
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 50)
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
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.1),heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),heightDimension: .fractionalHeight(1.0))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        
        return section
    }
    
    //디퍼블 데이터 소스 세팅
    private func setDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Int, PHAsset>(
            collectionView: collectionView,
            cellProvider: { collectionView, indexPath, asset in
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: PhotoCell.identifier,
                    for: indexPath) as? PhotoCell else {
                    return UICollectionViewCell()
                }
                    
                PhotoManager.shared.getImageFromAsset(asset) { image in
                    cell.configureImage(image: image)
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

extension PhotoPageViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.input.tappedInsidePhoto.send(indexPath)
    }
}
