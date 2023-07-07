//
//  SongModel.swift
//  PcynoMusic
//
//  Created by HanhLCI on 19/04/2023.
//

import Foundation
import MediaPlayer

enum SongType: Int {
    case audio = 0
    case video = 1
}

struct SongModel {
    let songId:  NSNumber
    let albumTitle: String?
    let artistName: String?
    let songTitle: String?
    let artWork: MPMediaItemArtwork?
    let songURL: URL?
    let mediaType: MPMediaType
    
    var getThumb: UIImage? {
        guard let artWork = artWork else {return UIImage(named: "ic_thumb")}
        
        return artWork.image(at: CGSize(width: 200,height: 200))
        
    }
    
    var songType: SongType {
        
        if mediaType == .movie || mediaType == .tvShow || mediaType == .videoPodcast || mediaType == .musicVideo || mediaType == .videoITunesU || mediaType == .homeVideo   || mediaType == .anyVideo    {
            return .video
        } else {
            return .audio
        }
    }
    
}

struct AlbumModel {
    let albumTitle: String
    let artWork: MPMediaItemArtwork?
    let songIDs: [String]
    
    var getThumb: UIImage? {
        guard let artWork = artWork else {return UIImage(named: "ic_thumb")}
        
        return artWork.image(at: CGSize(width: 200,height: 200))
        
    }
    var songTotalStr: String {
        return songIDs.count > 1 ? "\(songIDs.count) songs" : "\(songIDs.count) song"
    }
}

