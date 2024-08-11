//
//  AlbumItem.swift
//  PhotosClone
//
//  Created by minsong kim on 8/11/24.
//

import UIKit
import Photos

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
        case .recent:
            "최근 항목"
        case .favorite:
            "즐겨찾는 항목"
        case .person:
            "사람들"
        case .location:
            "장소"
        case .video:
            "비디오"
        case .selfie:
            "셀피"
        case .livePhoto:
            "Live Photo"
        case .personMode:
            "인물 사진"
        case .panorama:
            "파노라마"
        case .timelapse:
            "타임랩스"
        case .slowMotion:
            "슬로 모션"
        case .burst:
            "고속 연사 촬영"
        case .screenshot:
            "스크린샷"
        case .screenRecording:
            "화면 기록"
        case .gif:
            "움직이는 항목"
        case .download:
            "가져온 항목"
        case .hidden:
            "가려진 항목"
        case .removed:
            "최근 삭제된 항목"
        }
    }
    
    var image: UIImage {
        var firstImage: UIImage?
        switch self {
        case .video:
            firstImage = UIImage(systemName: "video")
        case .selfie:
            firstImage = UIImage(systemName: "person.crop.square")
        case .livePhoto:
            firstImage = UIImage(systemName: "livephoto")
        case .personMode:
            firstImage = UIImage(systemName: "florinsign.circle")
        case .panorama:
            firstImage = UIImage(systemName: "pano")
        case .timelapse:
            firstImage = UIImage(systemName: "timelapse")
        case .slowMotion:
            firstImage = UIImage(systemName: "slowmo")
        case .burst:
            firstImage = UIImage(systemName: "square.stack.3d.down.right")
        case .screenshot:
            firstImage = UIImage(systemName: "camera.viewfinder")
        case .screenRecording:
            firstImage = UIImage(systemName: "smallcircle.filled.circle")
        case .gif:
            firstImage = UIImage(systemName: "square.stack.3d.forward.dottedline")
        case .download:
            firstImage = UIImage(systemName: "square.and.arrow.down")
        case .hidden:
            firstImage = UIImage(systemName: "eye.slash")
        case .removed:
            firstImage = UIImage(systemName: "trash")
        default:
            firstImage = nil
        }
        
        return firstImage ?? UIImage(resource: .no)
    }
    
    var collection: PHAssetCollection {
        switch self {
        case .recent:
            return PHAssetCollection
                .fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumRecentlyAdded, options: nil)
                .object(at: 0)
        case .favorite:
            return PHAssetCollection
                .fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumFavorites, options: nil)
                .object(at: 0)
        case .person:
            return PHAssetCollection()
        case .location:
            return PHAssetCollection()
        case .video:
            return PHAssetCollection
                .fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumVideos, options: nil)
                .object(at: 0)
        case .selfie:
            return PHAssetCollection
                .fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumSelfPortraits, options: nil)
                .object(at: 0)
        case .livePhoto:
            return PHAssetCollection
                .fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumLivePhotos, options: nil)
                .object(at: 0)
        case .personMode:
            return PHAssetCollection
                .fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumDepthEffect, options: nil)
                .object(at: 0)
        case .panorama:
            return PHAssetCollection
                .fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumPanoramas, options: nil)
                .object(at: 0)
        case .timelapse:
            return PHAssetCollection
                .fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumTimelapses, options: nil)
                .object(at: 0)
        case .slowMotion:
            return PHAssetCollection
                .fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumSlomoVideos, options: nil)
                .object(at: 0)
        case .burst:
            return PHAssetCollection
                .fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumBursts, options: nil)
                .object(at: 0)
        case .screenshot:
            return PHAssetCollection
                .fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumScreenshots, options: nil)
                .object(at: 0)
        case .screenRecording:
            return PHAssetCollection()
        case .gif:
            return PHAssetCollection
                .fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumAnimated, options: nil)
                .object(at: 0)
        case .download:
            return PHAssetCollection()
        case .hidden:
            let fetchCollections = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
            for i in 0..<fetchCollections.count {
                let collection = fetchCollections.object(at: i)
                if let title = collection.localizedTitle, title == "Hidden" {
                    return collection
                }
            }
        case .removed:
            let fetchCollections = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
            for i in 0..<fetchCollections.count {
                let collection = fetchCollections.object(at: i)
                if let title = collection.localizedTitle, title == "Recently Deleted" {
                    return collection
                }
            }
        }
        return PHAssetCollection()
    }
}
