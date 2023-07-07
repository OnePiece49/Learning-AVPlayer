//
//  SongService.swift
//  PcynoMusic
//
//  Created by HanhLCI on 19/04/2023.
//

import Foundation
import MediaPlayer


class SongService {
    
    func getItem( songId: String ) -> SongModel? {
        
        let property: MPMediaPropertyPredicate = MPMediaPropertyPredicate( value: songId, forProperty: MPMediaItemPropertyPersistentID )
        
        let query: MPMediaQuery = MPMediaQuery()
        query.addFilterPredicate( property )
        var songInfo: SongModel?
        
        let items: [MPMediaItem] = query.items! as [MPMediaItem]
        if items.count >= 1 {
            let song = items[items.count - 1]
            songInfo = SongModel(
                songId: song.persistentID as NSNumber,
                albumTitle: song.albumTitle,
                artistName: song.artist,
                songTitle: song.title,
                artWork: song.artwork,
                songURL: song.assetURL,
                mediaType: song.mediaType
            )
        }
        return songInfo
    }
    
    func getSongURL( songId: String ) -> URL? {
        //NumberFormatter().number(from: currentItem)!
        let property: MPMediaPropertyPredicate = MPMediaPropertyPredicate( value: songId, forProperty: MPMediaItemPropertyPersistentID )
        
        let query: MPMediaQuery = MPMediaQuery()
        query.addFilterPredicate( property )
        
        let items: [MPMediaItem] = query.items! as [MPMediaItem]
        let song: MPMediaItem?
        var url: NSURL = NSURL()
        if items.count >= 1 {
            song = items[items.count - 1]
            
            url = song?.value( forProperty: MPMediaItemPropertyAssetURL ) as? NSURL ?? NSURL()
        }
        return url as URL
    }
    
    func getAudio() -> [MPMediaItem] {
        
        var musics: [MPMediaItem] = []
        let albumsQuery: MPMediaQuery
        albumsQuery = MPMediaQuery.songs()
        let albumItems: [MPMediaItemCollection] = albumsQuery.collections! as [MPMediaItemCollection]
        for album in albumItems {
            let albumItems: [MPMediaItem] = album.items as [MPMediaItem]
            // var song: MPMediaItem
            for song in albumItems {
                let mediaType = song.mediaType
                if !(mediaType == .movie || mediaType == .tvShow || mediaType == .videoPodcast || mediaType == .musicVideo || mediaType == .videoITunesU || mediaType == .homeVideo   || mediaType == .anyVideo)    {
                    musics.append(song)
                }
            }
        }
        return musics
        
    }
    
}
