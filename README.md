# 🏙️ Photos Clone
> 프로젝트 기간: 24.08.08 ~ 24.08.13

## 📖 목차
1. [🍀 소개](#소개)
2. [🛠️ 기술 스택](#기술-스택)
3. [💻 실행 화면](#실행-화면)
4. [🧨 트러블 슈팅](#트러블-슈팅)
5. [📚 참고 링크](#참고-링크)
6. [📕 회고](#회고)

</br>

<a id="소개"></a>

## 🍀 소개
기능은 많이 부족하지만, iOS Photos와 같은 사진앱.
사진을 추가하거나 삭제할 수 있고 날짜 범위나 앨범 카테고리 별로 사진을 볼 수 있다.


</br>
<a id="기술-스택"></a>

## 🛠️ 기술 스택
`UIKit`
- 성능 최적화: 오랜 기간 사용되어 온 만큼 SwiftUI보다 더 안정적인 성능 최적화

`MVVM`
- 재사용성: 서로 다른 View가 같은 ViewModel을 공유함으로서 코드 중복 줄임
- 책임의 명확성: Model, View, ViewModel의 역할 분리
- 데이터 바인딩: ViewModel의 상태 변화에 따라 View 업데이트

`Combine`
- 데이터 스트림 관리: MVVM에서 필요한 데이터 바인딩을 간단하게 표현 가능
- 반응형: MVVM과 연계하여 데이터 상태에 따라 자동으로 UI 업데이트

`Swift Concurrency`
- 성능 향상: 필요한 경우에만 스레드 생성, 시스템 리소스 효율적으로 사용
- 가독성: async, await 키워드를 통해 동기 코드처럼 비동기 코드 작성

</br>

<a id="실행-화면"></a>

## 💻 실행 화면
### 보관함

| 모든 사진 화면 | 모든 사진 화면 스크롤 | 사진 클릭시 |
|:--------:|:--------:|:--------:|
|<img src="https://velog.velcdn.com/images/mintsong/post/065c7ef8-0024-4394-b4a7-8e348d98a019/image.jpeg" alt="diary_scroll" width="300">|<img src="https://velog.velcdn.com/images/mintsong/post/576c5f3b-02a8-4e67-9d97-2bbb495438d2/image.gif" alt="diary_scroll" width="300">|<img src="https://velog.velcdn.com/images/mintsong/post/f9a12184-e93b-4765-8a7f-6e6faba9a3f5/image.gif" alt="diary_scroll" width="300">|

| 모든 사진에서 사진 추가 | 사진 삭제 후 모든 사진 되돌아 갔을 때 | 
|:--------:|:--------:|
|<img src="https://velog.velcdn.com/images/mintsong/post/0d575d06-e968-404d-b39a-38467b091ba6/image.gif" alt="diary_scroll" width="300">|<img src="https://velog.velcdn.com/images/mintsong/post/fc5b4064-1c8c-4d6f-aee0-a6dfa8bd6a04/image.gif" alt="diary_scroll" width="300">|


| 일별 화면 | 일별 화면 스크롤 | 일별 사진 클릭시 |
|:--------:|:--------:|:--------:|
|<img src="https://velog.velcdn.com/images/mintsong/post/81abe85a-545f-4620-9897-986f2a4f88ff/image.png" alt="diary_scroll" width="300">|<img src="https://velog.velcdn.com/images/mintsong/post/296795dc-b2f6-4057-a0cc-3332915c8f6a/image.gif" alt="diary_scroll" width="300">|<img src="https://velog.velcdn.com/images/mintsong/post/09912fdc-9885-475d-9b81-c753b7e5073e/image.gif" alt="diary_scroll" width="300">|

| 월별 화면 | 월별 화면 스크롤 | 월별 카테고리 클릭시 |
|:--------:|:--------:|:--------:|
|<img src="https://velog.velcdn.com/images/mintsong/post/5e8bad47-d07c-4bb9-b14a-25c56c78b45a/image.png" alt="diary_scroll" width="300">|<img src="https://velog.velcdn.com/images/mintsong/post/c2a05b51-e19d-489d-8a91-3cab9a017063/image.gif" alt="diary_scroll" width="300">|<img src="https://velog.velcdn.com/images/mintsong/post/89df3e2e-7336-4f8a-abfa-c600efa1861c/image.gif" alt="diary_scroll" width="300">|

| 연도별 화면 | 연도별 화면 스크롤 | 연도별 카테고리 클릭시 |
|:--------:|:--------:|:--------:|
|<img src="https://velog.velcdn.com/images/mintsong/post/cf876826-6e46-4c21-b9a6-69242e007f1e/image.png" alt="diary_scroll" width="300">|<img src="https://velog.velcdn.com/images/mintsong/post/34111c05-91ce-4ce9-a611-c1542d5f7872/image.gif" alt="diary_scroll" width="300">|<img src="https://velog.velcdn.com/images/mintsong/post/11490baa-96cf-4322-949f-092ff931f16b/image.gif" alt="diary_scroll" width="300">|


### 앨범

| 앨범 카테고리 화면 | 개수가 많은 앨범 화면 | 개수가 적은 앨범 화면 |
|:--------:|:--------:|:--------:|
|<img src="https://velog.velcdn.com/images/mintsong/post/091e0db8-648e-41ba-895c-331a8ab6ba7a/image.gif" alt="diary_scroll" width="300">|<img src="https://velog.velcdn.com/images/mintsong/post/0fc6d862-4414-4921-b70d-8f04424a7355/image.jpeg" alt="diary_scroll" width="300">|<img src="https://velog.velcdn.com/images/mintsong/post/a1442e1d-495e-44ed-9477-0ea620eba2ef/image.png" alt="diary_scroll" width="300">|

| 앨범 카테고리 클릭시 (사진 많을 때) | 앨범 카테고리 클릭시 (사진 적을 때) | 앨범에서 사진 클릭시 |
|:--------:|:--------:|:--------:|
|<img src="https://velog.velcdn.com/images/mintsong/post/82661248-5148-4c52-8367-2ed4fa947d66/image.gif" alt="diary_scroll" width="300">|<img src="https://velog.velcdn.com/images/mintsong/post/cb4ae8ed-e9d3-4fe8-bff0-c3cb6b1ba341/image.gif" alt="diary_scroll" width="300">|<img src="https://velog.velcdn.com/images/mintsong/post/a4b4783c-78c4-45b6-a71e-19dde8272c85/image.gif" alt="diary_scroll" width="300">|

### 디테일 화면

| 페이지네이션 스크롤 | 사진 스크롤 | 사진 삭제 |
|:--------:|:--------:|:--------:|
|<img src="https://velog.velcdn.com/images/mintsong/post/b8bba1f2-a32e-48ba-bba1-afd2719b3108/image.gif" alt="diary_scroll" width="300">|<img src="https://velog.velcdn.com/images/mintsong/post/29781968-2dcc-42e6-ab3d-a21818655512/image.gif" alt="diary_scroll" width="300">|<img src="https://velog.velcdn.com/images/mintsong/post/8eadb7dc-62a3-476a-b04b-c9b9a9e4594a/image.gif" alt="diary_scroll" width="300">|

</br>

<a id="고민한-점"></a>

## 🧨 고민한 점
###### 핵심 위주로 작성됨.
1️⃣ **보관함 탭과 디테일 뷰의 PageControl** <br>
-
🔒 **문제점** <br>
[보관함 탭]에서는 UISegmentedControl을 사용해서 [모든 사진, 일, 월, 연] 이렇게 시간 별로 사진들을 구분해야했다. 특히 DiffableDataSource의 Section과 Item을 사용하기 위해 매번 [PHAsset]을 새롭게 가져와야 했다. 

[디테일 뷰]에서는 페이지네이션을 위해 컬렉션뷰를 사용하고 싶었다. 크게 보이는 사진과 페이지네이션을 위해 작게 보여지는 사진 두개가 별개의 컬렉션뷰로 구현해 가로 방향 스크롤이 가능하고 select했을 때 viewModel을 통해 서로 binding하고 있게 하고 싶었다. 

🔑 **해결방법** <br>
때문에 고민하다 두 경우 모두 addChild를 사용하였다. 
[보관함 탭]의 경우는 크게 LockerViewController가 존재하고, LockerViewController 내부에 UISegmentedControl과 childViewController가 존재하여 UISegmentedControl이 눌리면, childViewController가 바뀐다. 

```swift
viewModel.output.handleChildViewController
        .sink { [weak self] pastControlNumber in
            guard let self else { return }
            childViewController.removeFromParent()
            childViewController.view.removeFromSuperview()
                
            if timePeriodSegmentControl.selectedSegmentIndex == 0 {
                childViewController = DIContainer.shared.resolve(YearPhotosViewController.self)
            } else if timePeriodSegmentControl.selectedSegmentIndex == 1 {
                childViewController = DIContainer.shared.resolve(MonthPhotosViewController.self)
            } else if timePeriodSegmentControl.selectedSegmentIndex == 2 {
                childViewController = DIContainer.shared.resolve(DayPhotosViewController.self)
            } else {
                childViewController = DIContainer.shared.resolve(AllPhotosViewController.self)
            }
            configureChildViewController(childViewController)
        }
        .store(in: &cancellables)
```

[디테일 뷰]는 PhotoPageViewController가 존재하고 여기서 pageControl을 위한 작은 collectionView, 삭제할 때 사용하는 Toolbar, 날짜와 시간이 표시된 navigationBar 등이 존재한다. 그리고 내부에 childViewController로 PhotoViewController를 가져 PhotoViewController를 클릭하는 경우 PhotoViewModel로 PassthroughSubject를 보내 PhotoViewController는 배경색이 검정으로, PhotoPageViewController에서는 Toolbar, pageControl을 위한 CollectionView, navigationBar 등을 화면에서 내리는 등의 상호작용을 한다.

```swift
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
```

<br>


2️⃣ **사진 삭제 시 CollectionView** <br>
-
🔒 **문제점** <br>
현재 이 앱에서는 사진을 삭제하고 싶다면, 디테일뷰(PhotoPageViewController)에 있는 Toolbar의 deleteButton을 사용하는 방법 뿐이다. 때문에 사진을 삭제 후 backButton이나 뒤로가는 제스처를 사용하여 디테일뷰를 내렸을 때 AllPhotosViewController에서도 삭제된 사진이 내려갈 수 있도록 하는 과정에서 문제가 생겼다. 스크린샷을 사용한 경우에 사진이 추가될 수 있도록 PHPhotoLibrary를 사용해서 변화를 감지하도록 했는데, viewDidAppear에서 불리는 scrollToBottom()과 시점의 차이가 나면서 DataSource가 문제가 있어 앱이 멈추는 일이 발생했다.

🔑 **해결방법** <br>
scrollToBottom()은 처음에만 실행되면 되는 함수기에 Flag를 하나 만들어서 처음 실행되는 순간에만 적용해주었다. 
```swift
override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
        
    if isFirstView {
        scrollToBottom()
        isFirstView = false
    } else {
        collectionView.reloadData()
    }
}

extension AllPhotosViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard let changes = changeInstance.changeDetails(for: PhotoManager.shared.allAssets) else { return }
            
            let changeAssets = changes.fetchResultAfterChanges.objects(at: IndexSet(integersIn: 0..<changes.fetchResultAfterChanges.count))
            var snapshot = self.dataSource?.snapshot() ?? NSDiffableDataSourceSnapshot<Int, PHAsset>()
            
            // CollectionView 업데이트
            if changes.hasIncrementalChanges {
                if let removed = changes.removedIndexes, !removed.isEmpty {
                    snapshot.deleteItems(removed.map { PhotoManager.shared.allPhotos[$0] })
                }
                if let inserted = changes.insertedIndexes, !inserted.isEmpty {
                    snapshot.appendItems(inserted.map { changeAssets[$0] })
                }
                PhotoManager.shared.allPhotos = changeAssets
                self.dataSource?.apply(snapshot)
            } else {
                self.setSnapshot()
            }
        }
    }
}

```

<br>

3️⃣ **앨범 구분** <br>
-
🔒 **문제점** <br>
앨범 탭을 구현할 때, AlbumSection과 AlbumItem을 구현하여 Model 타입을 따로 생성하여 만들어주었다. 이때 첫번째 Section의 [PHCollection]에 문제가 생겼다. 원하는 [PHAssetCollectionSubtype](https://developer.apple.com/documentation/photokit/phassetcollectionsubtype)에 따라 Section을 나누었는데, 첫번째 Section인 '나의 앨범'에서는 UserCollections도 표시해주어야 했다. 때문에 단순히 AlbumSection의 [AlbumItem]만으로는 구현할 수 없었다. 
```swift
enum AlbumSection: Int, Hashable, CaseIterable {
    case myAlbum
    case personAndPlace
    case mediaType
    case etc
    
    var description: String {
        switch self {
        case .myAlbum:
            return "나의 앨범"
        case .personAndPlace:
            return "사람들 및 장소"
        case .mediaType:
            return "미디어 유형"
        case .etc:
            return "기타"
        }
    }
    
    var items: [AlbumItem] {
        switch self {
        case .myAlbum:
            [.recent, .favorite]
        case .personAndPlace:
            [.person, .location]
        case .mediaType:
            [.video, .selfie, .livePhoto, .personMode, .panorama, .timelapse, .slowMotion, .burst, .screenshot, .screenRecording, .gif]
        case .etc:
            [.download, .hidden, .removed]
        }
    }
}

enum AlbumItem: Int, Hashable {
    case recent
    case favorite
    case person
    case location
    case video
    case selfie
    case livePhoto
    case personMode
    case panorama
    case timelapse
    case slowMotion
    case burst
    case screenshot
    case screenRecording
    case gif
    case download
    case hidden
    case removed
    
    var title: String {
        switch self {
        //앨범 탭에서 구분할 때 각각 보여줄 Title
        }
    }
    
    var image: UIImage {
        var firstImage: UIImage?
        switch self {
        //앨범 탭에서 구분할 때 각각 보여줄 로고 이미지 
        }
        
        return firstImage ?? UIImage(resource: .no)
    }
    
    var collection: PHAssetCollection {
        switch self {
        //각각에 맞는 subtype을 사용해 PHAssetCollection 반환
        }
        return PHAssetCollection()
    }
}
```

🔑 **해결방법** <br>
PhotoManager에서 categorize 함수를 구현할 때, UserCollection 배열을 받아 더할 수 있도록 구현했다. 
```swift
class PhotoManager {
    func categorizeAlbums(section: AlbumSection) -> [PHCollection] {
        var albums: [PHCollection] = []
        switch section {
        case .myAlbum:
            for item in section.items {
                albums.append(item.collection)
            }
            let userCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)
            albums += (0..<userCollections.count).map { userCollections.object(at: $0) }
        case .personAndPlace:
            let persons = PHCollectionList.fetchMomentLists(with: .smartFolderFaces, options: nil)
            albums += (0..<persons.count).map { persons.object(at: $0) }
        case .mediaType:
            for item in section.items {
                albums.append(item.collection)
            }
        case .etc:
            for item in section.items {
                albums.append(item.collection)
            }
        }
        
        return albums
    }
}

```
<br>

4️⃣ **날짜 별로 카테고리 분류, indicatorView** <br>
-
🔒 **문제점** <br>
Cache를 사용하고 싶었으나 아직 온전히 이해하지 못하였기에 제대로 사용하여 구현할 수 있을 것 같지 않아 사용하지 않았다. 때문에 화면들을 처음 구현할 때 2만장이 넘는 사진들을 날짜에 따라 새롭게 배열을 만들고 하려니 굉장히 로딩이 오래 걸렸다. 

🔑 **해결방법** <br>
임시방편으로 UIActivityIndicatorView를 사용하여 사용자가 앱이 진행이 되고 있다는 점을 인식할 수 있게 하였다. 그러나 Cache를 사용하는 방법과, 날짜 별로 구분한 [PHAsset]을 PhotoManager가 들고 있었다면 더 빠르게 될 수 있었을 것 같은 아쉬움이 있다.



<br>

<a id="참고-링크"></a>

## 📚 참고 링크
- [🍎Apple Docs: PhotoKit](https://developer.apple.com/documentation/photokit)
- [🍎Apple Docs: DateFormatter](https://developer.apple.com/documentation/foundation/dateformatter)
- [🍎Apple Docs: UIListContentConfiguration](https://developer.apple.com/documentation/uikit/uilistcontentconfiguration)
- [🍎Apple Docs: PHAssetCollection](https://developer.apple.com/documentation/photokit/phassetcollection)
- [🍎Apple Docs: PHCollection](https://developer.apple.com/documentation/photokit/phcollection)
- [🍎Apple Docs: PHAsset](https://developer.apple.com/documentation/photokit/phasset)
- [🍎Apple Docs: NSCollectionLayoutBoundarySupplementaryItem](https://developer.apple.com/documentation/uikit/nscollectionlayoutboundarysupplementaryitem)
- <Img src = "https://hackmd.io/_uploads/ByTEsGUv3.png" width="20"/> [blog: DateFormatter](https://formestory.tistory.com/6)



</br>

<a id="회고"></a>

## 📕 회고
사진 앱에는 디테일한 부분이 굉장히 많았다. 사람의 얼굴 별로 구분된 앨범이나, location별로 구분된 앨범, 공유하는 기능, 앨범을 만드는 기능 등 다양했다. 모든 것을 구현하기에는 굉장히 짧은 시간이었기에 우선 사용자가 앱을 사용할 때 불편함이 없도록 하는 부분에 집중하였다. 때문에 일단 Tab별로 크게 구현할 기능들을 나누어 보았다. 
````
사진 앱
├── 보관함: 사진 로드하여 보여주는 Tab
├── ForYou: memory Collection 로드하여 보여주는 Tab
├── 앨범: 미디어 타입, 나의 앨범 등 PHAssetCollectionSubtype을 사용하여 구분한 Tab
└── 검색: 앨범의 title이 검색 결과로 뜨는 Tab
````


### 👨‍💻 팀원
| 😈MINT😈 |
| :--------: |
| <img src="https://hackmd.io/_uploads/SyRrQ-AYR.png"  width="200" height="200"> |
|[Github Profile](https://github.com/mint3382) |

</br>

