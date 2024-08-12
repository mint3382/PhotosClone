//
//  PhotoManager.swift
//  PhotosClone
//
//  Created by minsong kim on 8/10/24.
//

import UIKit
import Photos

class PhotoManager {
    static let shared = PhotoManager()
    
    private init() { }
    
    var allAssets = PHFetchResult<PHAsset>()
    var allPhotos = [PHAsset]()
    var userCollections = PHFetchResult<PHCollection>()
    
    func fetchPhotos(with options: PHFetchOptions?) {
        allAssets = PHAsset.fetchAssets(with: options)
        
        allAssets.enumerateObjects { (asset, index, stop) in
            self.allPhotos.append(asset)
        }
    }
    
    func categorizeForYouMemory(section: ForYouSection) {
        let persons = PHCollectionList.fetchMomentLists(with: .smartFolderFaces, options: nil)
    }
    
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
    
    func fetchAssetsFromCollection(_ collection: PHAssetCollection) -> [PHAsset] {
        var assets = [PHAsset]()
        
        let fetchOptions = PHFetchOptions()
        let fetchResult = PHAsset.fetchAssets(in: collection, options: fetchOptions)
        
        fetchResult.enumerateObjects { (asset, index, stop) in
            assets.append(asset)
        }
        
        return assets
    }
    
    func getImageFromAsset(_ asset: PHAsset, targetSize: CGSize = CGSize(width: 300, height: 300), completion: @escaping (UIImage?) -> Void) {
        let imageManager = PHImageManager.default()
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .highQualityFormat
        
        imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: requestOptions) { image, info in
            completion(image)
        }
    }
}
