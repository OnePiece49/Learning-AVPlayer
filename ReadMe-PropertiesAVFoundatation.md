# URL

Nội dung chính của bài viết là tìm hiểu về các thuộc tính của 1 `AVFoundation`.

# I. URL

`URL`: Trong bài viết được lấy từ audio và video trong photo library

- `absoluteString`: return `String`: Lấy ra dạng String của URL đó

```swift
let url = URL(string: "https://github.com/Vietdz123/Learning-AVPlayer/blob/main/ReadMe-Player.md#phan2")!
print("DEBUG: \(url)")

videoURLs.forEach { video in
    print("DEBUG: \(video.absoluteString)")
}
```

Output:
```
DEBUG: https://github.com/Vietdz123/Learning-AVPlayer/blob/main/ReadMe-Player.md#phan2
DEBUG: file:///var/mobile/Media/DCIM/109APPLE/IMG_9610.MOV
DEBUG: file:///var/mobile/Media/DCIM/109APPLE/IMG_9585.MOV
```

- `pathExtension` : return `String`

```swift
let url = URL(string: "https://github.com/Vietdz123/Learning-AVPlayer/blob/main/ReadMe-Player.md#phan2")!

print("DEBUG: \(url.pathExtension)")
videoURLs.forEach { video in
    print("DEBUG: \(video.pathExtension)")
}
```

Output:

```swift
DEBUG: md
DEBUG: MOV
DEBUG: MOV
```

Ta thường dùng `absoluteString` và `pathExtension` để lọc url: 

```swift
let acceptedFile = ["mp4", "mov", "m4v"]

videoURLs.filter { url in
    return !url.absoluteString.contains(".DS_Store") && acceptedFile.contains(url.pathExtension.lowercased())
}
```

- `lastPathComponent`: return `String`: In ra path cuối của URL

```swift
let url = URL(string: "https://github.com/Vietdz123/Learning-AVPlayer/blob/main/ReadMe-Player.md#phan2")

print("DEBUG: \(url?.lastPathComponent)")
videoURLs.forEach { video in
    print("DEBUG: \(video.lastPathComponent)")
}
```
    
Output:

```swift
DEBUG: Optional("ReadMe-Player.md")
DEBUG: IMG_9610.MOV
DEBUG: IMG_9585.MOV
```

## II. Properties AVFoundation

`PHAsset`: Có các thuộc tính liên quan đến 1 đối tượng:
- `duration`
- `isFavorite`
- `creationDate`
- `originalName`: lấy name của asset
- `filename`: Được lấy thông qua KVC: `PHAsset().value(forkey: "filename")`. Đôi khi `filename` sẽ khác `originalName`. Nếu mà dùng camera để tạo video, thì hai cái giống nhau, còn với video quay màn hình thì khác.
- Và đặc biệt không có **URL**, đôi khi asset của chúng ta lấy được lại là dạng video, ta muốn truy lấy URL đó thì phải sử dụng `PHImageManager.default().requestAVAsset` hoặc `PHCachingImageManager.default().requestAVAsset`. Hai method trên đếu trả về `AVAsset`, vậy để lấy được `URL` ta phải cast sang `AVURLAsset`

`AVPlayer`: Có các thuộc tính liên quan tới việc play media như:
-  `duration`
-  `currentTime`
-  `currentItem`
-  `play`
-  `playImmediately(atRate: )`
-  `pause`
-  `replaceCurrentItem(with: )`

`AVAsset`: Về cơ bản nó đ có properties nào quan trọng, nó thường được cast sang dạng `AVURLAsset`. Tuy thằng `AVAsset` được khởi tạo từ `URL`(`AVAsset(URL: )`) nhưng mà nó lại ko có properties `.url`, vì thế ta phải cast sang `AVURLAsset`.

`AVURLAsset`: Có thể truy suất tới các properties:
- `url`
- `track`

`MPMediaItem`: Chứa các thông tin liên quan đến media như:
- `artits`
- `albumTitle`
- `playbackDuration`
- `persistentID`
- `title`
- `artwork`: Ảnh media
