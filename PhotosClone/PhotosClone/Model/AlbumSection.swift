//
//  AlbumSection.swift
//  PhotosClone
//
//  Created by minsong kim on 8/11/24.
//

import Foundation

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
