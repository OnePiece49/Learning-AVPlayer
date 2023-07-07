# AVPlayer
<a name="readme-top"></a>

Ở phần này ta có 2 nội dung chính:
- Phần 1: Tìm hiểu về cách để play video, audio
<p align="right">(<a href="#buoc7">Overview Phần 1</a>)</p>
- Phần 2: Tìm hiểu vễ cách tua video, audio, cut merge video,..
<p align="right">(<a href="#phan2">Phần 2</a>)</p>



# I. How to Play Video, audio, media

In iOS, displaying images and playing audio files are easy thanks to UIImage and `AVAudioPlayer`. But how about the videos? Have you ever think about playing video in the app with Swift? If yes, you can start with the `AVPlayerViewController`, which provides some basic controls so that you can work with the player easily and quickly.

Mặc dù việc tích hợp `AVPlayerViewController` vào Project là rất dễ dàng, nhưng `AVPlayerViewController` lại không đủ flexibles để custom, vì vậy ta thường chọn 1 option khác cho playing video, đó là `AVPlayerLayer`.

Để có thể play được video, audio, media,.. điều ta cần làm là cần 3 biến: 
- `AVPlayer`: Cho việc play, pause, rate 
- `AVPlayerItem`: Là Item được truyền vào cho `AVPlayer` để play.
- `URL`: Là url trỏ tới Asset, `URL` có thể được sử dụng để khởi tạo `AVURLAsset` hoặc khởi tạo `AVPlayerItem.`
- `AVPlayerLayer`(Optional): Được sử dụng để hiển thị video khi `AVPlayer` play.

## 1.1 Understanding the Asset Model
Kiểu dữ liệu quan trọng nhất trong `AVFoundation` là `AVAsset`. `AVAsset` là 1 tập hợp các data như audio, video, title, length và nature video size. `AVAsset` cũng hỗ trợ HTTP live streaming(HLS). 

Khởi tạo asset
```php
let asset = AVAsset(url: url)
```

## 1.2 Preparing Assets for Use(Request MetaData)
`AVAsset` chứa rất nhiều thông tin như liệu rằng video có thể được played bây giờ không, độ dài video, ngày khởi tạo,... Tuy nhiên, các thuộc tính đó có thể không được xuất hiện. Để cho chắc chắn, ta có thể sẽ phải request các thông tin đó( **requests asynchronously for smooth UI operation.**)
Ta có thể kiểm tra liệu rằng các thuộc tính đã kể trên đã available chưa thông qua 2 method sau:

```php
loadValuesAsynchronously(forKeys:completionHandler:)
```

Phương thức này sẽ request 1 cách bất đồng bộ các thuộc tính được passed trong mảng **key arrays** cho instace của AVAsset đó.
và 
```php
statusOfValue(forKey:error:)
```
Phương thức này sẽ kiểm ra xem liệu rằng các thuộc tính **key** đã available chưa(maybe nếu chưa nó sẽ block thread đó.
![](images/image_requestAsset.png))

## 1.3 Working with MetaData
Tạm bỏ
https://wnstkdyu.github.io/2018/05/03/avfoundationprogrammingguide/


## 1.4 Playing Media
Mặc dù AVAsset rất quan trọng cho việc hiển thị media data, ta cũng cần thêm các classes khác cho việc play media
![](images/hirachy_media.png)

`AVPlayer`: là class trung tâm của hệ thống, có nhiệm vụ play, pause,... assets. `AVPlayer` được sử dụng trong cả locally hoặc streaming data.
`AVPlayerItem`: là 1 class được Apple cung cấp, được đại diện cho 1 media item mà có thể được play bởi `AVPlayer`. `AVPlayerItem` đóng gói các thông tin và thuộc tính liên quan tới media như media'URL, metaData và playback status.
`AVLayerLayer`: Là 1 Class được Apple cung câp cho việc displaying video content từ `AVPlayer`.

## 1.5 Observing Playback State
`AVPlayer` và `AVPlayerItem` là các dynamic object, nghĩa là các trạng thái của chúng sẽ liên tục thay đổi. Ta luôn muốn react và xử lý các thay đổi đó. Trong trường hợp này, **Key-Value Observing(KVO)** sẽ được sử dụng, ta sẽ sử dụng **KVO** cho việc quản lý các trạng thái của **AVPlayer và AVPlayerItem**.
Một trong các thuộc tính quan trọng của `AVPlayerItem` là **status**. Thuộc tính này thường được sử dụng để kiểm tra xem `AVPlayerItem` có thể được played hay không.

```swift
private var playerItemContext = 0
private func setUpPlayerItem(with asset: AVAsset) {
    playerItem = AVPlayerItem(asset: asset)
    playerItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.old, .new], context: &playerItemContext)
        
    DispatchQueue.main.async { [weak self] in
        self?.player = AVPlayer(playerItem: self?.playerItem!)
    }
}
    
override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    guard context == &playerItemContext else {
        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        return
    }
        
    if keyPath == #keyPath(AVPlayerItem.status) {
        let status: AVPlayerItem.Status
        if let statusNumber = change?[.newKey] as? NSNumber {
            status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
        } else {
            status = .unknown
        }
        switch status {
        case .readyToPlay:
            print(".readyToPlay")
            player?.play()
        case .failed:
            print(".failed")
        case .unknown:
            print(".unknown")
        @unknown default:
            print("@unknown default")
        }
    }
}
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## 1.6 Performing Time-Based Operations.
Ta có thể controll timing cyar media thông qua các thuộc tính của AVPlayer và AVPlayerItem. Để có thể handle các thông tin liên quan đến time của media, ta phải hiểu `CMTime`.

`CMTime` là 1 Struct thuộc Core Media framework. Nó đại diện cho chính xác thời gian của audio hoặc video media. CMTime được thiết kế để xử lý, tính toán, hiển thị duration, time intervel,..
 - CMTime bao gồm 2 thành properties chính: **value** và **timescale.**
 ```php
 // 0.25 seconds
let quarterSecond = CMTime(value: 1, timescale: 4)
 
// 10 second mark in a 44.1 kHz audio file
let tenSeconds = CMTime(value: 441000, timescale: 44100)
 
// 3 seconds into a 30fps video
let cursor = CMTime(value: 90, timescale: 30)

```
<a name="buoc7"></a>

## 1.7 Tổng kết
Để có thể playVideo, lấy các thông tin creationDate, duration,... ta cần có 1 biến asset thuộc kiểu `AVAsset` hoặc 1 `URL` của asset nào đó. Sau khi có được biến asset rồi, ta sẽ cần 1 biến `playItem` thuộc kiểu `AVPlayItem`, biến này se đại diện cho 1 media item và có thể được play bởi player.

Sau khi có playItem, ta sẽ khởi tạo player để playItem đó.

```php
playerItem = AVPlayerItem(asset: asset) ///Hoặc AVPlayerItem(url: URL)
player = AVPlayer(playerItem: playerItem)
```    

Lúc này, ta có thể sử dụng `player.play()` để play Video hoặc `player.pause()` để pause video. Tuy video đã được played nhưng ta sẽ không nhìn thấy gì. Lúc này để hiển thị video, player cần add 1 sublay thuộc kiểu `AVPlayerLayer` như sau:

```php
self.playerLayer = AVPlayerLayer(player: self.player)
self.playerLayer.frame = self.playerContainerView.bounds
```

Hmm, nhưng mà chúng ta lấy asset thuộc kiểu AVAsset từ đâu :))) Ta có vài cách để lấy Asset:

Cách 1: Tạo Asset từ Url

```swift
private let videoURL = "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
guard let url = URL(string: videoURL) else { return }
playerView.play(with: url)
```

Cách 2: Tạo Asset từ UIImagePicker

```swift
Đầu tiên ta phải requestAuthorization() để lấy asset
imagePick = UIImagePickerController()
imagePick.delegate = self
imagePick.sourceType = .savedPhotosAlbum
imagePick.mediaTypes = ["public.movie"]
imagePick.allowsEditing = false
present(imagePick, animated: true, completion: .none)

//MARK: - delegate
extension ShowingController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: .none)

        guard let asset = info[.phAsset] as? PHAsset else {
            print("DEBUG: failed and \(info[.phAsset])")
            return
        }

        ///Ta đã lấy được asset thuộc kiểu PHAsset
    }
}

Từ asset thuộc kiểu `PHAsset`, ta phải request `AVAsset` với hàm fetchAVAsset() như dưới
///Cuối cùng ta cũng đã lấy được asset thuộc kiểu AVAsset
```

Cách 3: Fetch asset từ PhotosKit

```swift
Đầu tiên ta vẫn phải requestAuthorization() để lấy asset
let allPhotos: [PHAsset] = []
let fetchResults = PHAsset.fetchAssets(with: PHAssetMediaType.video, options: option) ///fetchResult thuộc type: PHFetchResult<PHAsset>
allPhotos = Array(_immutableCocoaArray: fetchResults)  ///Ta sẽ convert type PHFetchResult<PHAsset> sang Array [PHAsset] 

Từ asset thuộc kiểu `PHAsset`, ta cũng phải request `AVAsset` với hàm fetchAVAsset() như dưới
```

Từ đây, ta lại có 2 cách để fetch `AVAsset` từ `PHAsset`:

Cách 1:

```swift
PHCachingImageManager().requestAVAsset(forVideo: asset, options: .none) { asset, auio, dictionaries in
//            if asset?.isKind(of: AVComposition.self) != nil {
//                print("DEBUG: siuuuu")
//                return
//            }

guard let asset = asset else {
    return
}
/// Lấy AVAsset successfully
```

Cách 2:

```swift
PHImageManager.default().requestAVAsset(forVideo: video, options: options, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
    guard let asset = asset else {
        return
    }
})
```

<a name="buoc8"></a>
<p align="right">(<a href="#readme-top">back to top</a>)</p>

<a name="phan2"></a>

# II. Multiple Action with Video, Audio, Media

## 2.1 Slide Video
Để có thể slide Video đến vị trí chúng ta muốn, ta có thể làm như sau:

```swift
@objc func handleSliderMoved(slider: UISlider) {
    guard let durationTime = durationTime else {
        return
    }

    let time = CMTimeGetSeconds(durationTime)
    let current = Double(time) * Double(slider.value)
    let currentTime =  CMTimeMakeWithSeconds(current, preferredTimescale: 1000)
    updateProgressLabel(time: currentTime)
    updateVideo(time: currentTime)
}
```

Với duration là tổng thời gian Video, và có kiểu `CMTime`:

- Để có thể convert từ `CMTime` sang second, ta sử dụng `CMTimeGetSeconds()`, VD duration = CMTime(value: 100, scale: 1), thì time = 100

- Để có thể convert từ 64s sang kiểu `CMTime`, ta sử dụng `CMTimeMakeWithSeconds()`, VD current = 64, thì currentTime sau khi được gán trong vd trên thì sẽ bằng CMTime(value: 64000, scale: 1000).
  
Sau đó để có thể để Video đến thời gian ta muốn, ta dùng hàm seek()
```php
func updateVideo(time: CMTime) {
    player?.seek(to: time)
}
```

Ta có thể convert CMtime sang dạng String thông qua hàm sau:
func getTimeString(time: CMTime) -> String? {
    let totalSeconds = CMTimeGetSeconds(time)
    guard !(totalSeconds.isNaN || totalSeconds.isInfinite) else {
        return nil
    }
    let hours = Int(totalSeconds / 3600)
    let minutes = Int(totalSeconds / 60) % 60
    let seconds = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
    if hours > 0 {
        return String(format: "%i:%02i:%02i",arguments: [hours, minutes, seconds])
    } else {
        return String(format: "%02i:%02i", arguments: [minutes, seconds])
    }
}

## 2.2 CropVideo

Để có thể CropVideo ta sẽ sử dụng `AVAssetExportSession()`

`AVAssetExportSession` là 1 class của `AVFoundation` mà cho phép ta export `AVAsset`(Như là Video hoặc image) sang một dạng format hoặc configuration mới.

Ta khởi tạo AVAsset như sau:

```php
AVAssetExportSession(asset:presetName:)
```

Để có thể cut được video, ta cần cấu hình các properties sau của `AVAssetExportSession`: 

- `outputURL`: URL?(Ta muốn export file đó ra đâu)

- `outputFileType`: AVFileType? (Kiểu đầu ra của file đó)

- `timeRange`: CMTimeRange(Optional)

```swift
@objc func handleExportButtonTapped() {
    guard let asset = asset, let avasset = player?.currentItem?.asset else {
        return
    }
    let filename = asset.value(forKey: "filename") as! String
    guard let urlAsset = (avasset as? AVURLAsset)?.url else {return}
    
    let fileManage = FileManager.default
 
    guard let document = fileManage.urls(for: .documentDirectory, in: .userDomainMask).first else {return}
    let pathFoloder = document.appendingPathComponent("Folder-Luffy")
    try? fileManage.createDirectory(at: pathFoloder, withIntermediateDirectories: true, attributes: .none)
    let outputURL = pathFoloder.appendingPathComponent("\(filename).mp4")
    
    guard let exportSession = AVAssetExportSession(asset: avasset, presetName: AVAssetExportPresetHighestQuality) else {return}
    exportSession.outputURL = outputURL
    exportSession.outputFileType = .mp4
    exportSession.timeRange = CMTimeRange(start: CMTime(value: 30, timescale: 10), end: CMTime(value: 10, timescale: 1))
    
    exportSession.exportAsynchronously {
        switch exportSession.status {
        case .completed:
            print("DEBUG: complete")
        case .failed:
            print("DEBUG: failed")
        default:
            break
        }
    }
}
```

Ở đây ta sẽ lưu Video vào trong `fileManager`

Ta sẽ lấy filename của video thông qua asset thuộc kiểu `PHAsset`.

Trong VD trên ta export video từ giây thứ 3 đến giây thứ 10. Nếu ko truyền timeRange, ta sẽ export toàn bộ Video. `AVAssetExportPresetHighestQuality`: Có nghĩa là ta mong muốn export ra file video với chất lượng cao nhất.

Để lấy được URL của asset, ta làm như trên:
```php
guard let urlAsset = (avasset as? AVURLAsset)?.url else {return}
print("DEBUG: \(urlAsset) siuuuu")
```
<p align="right">(<a href="#readme-top">back to top</a>)</p>

<a name="buoc10"></a>

## 2.3 Merge Video

Bất cứ khi nào ta muốn edit media hoặc thêm effect, ta có thể sử dụng `AVComposition`. `AVComposition` là một class của `AVFoundation`, nó cung cấp các chức năng cho việc kết hợp, sắp xếp các assets khác nhau hoặc các **type assets** khác nhau thành 1 asset. **Asset types** có thể bao gồm các audio, video subtitle, metadata, và text. Khi làm việc với `AVComposition`, ta sẽ phải làm việc với `AVAsset`, và `AVAssetTrack`. (`AVComposition` là 1 subclass của `AVAsset`.) Khi thay đổi `AVAsset` bằng `AVComposition` sẽ không ảnh hưởng tới gốc media file. 

`AVAsset` chứa 1 tập các đối tượng `AVTrack`. `AVTrack` có thể là video track, audio track, subtitle track,...

```php
let asset: AVAsset = // Your AVAsset object

// Get all tracks in the asset
let allTracks = asset.tracks

// Get video tracks only
let videoTracks = asset.tracks(withMediaType: .video)

// Get audio tracks only
let audioTracks = asset.tracks(withMediaType: .audio)

// Get subtitle tracks only
let subtitleTracks = asset.tracks(withMediaType: .subtitle)
```

Tuy nói vậy nhưng ta không thể chỉnh sửa video bằng class `AVCompdosition`, thay vì đó, Apple cung cấp cho ta class `AVMutableComposition` mà được sử dụng cho việc chỉnh sửa, merge video,... Điều này làm tách biệt các cơ chế của các class khác nhau, giữa 1 bên là playback, 1 bên là các chức năng chỉnh sửa.

Phân tích cho ta biết răng, 1 video clip chỉ là 1 `AVTrack` của audio data và 1 `AVTrack` của video data.
Vì vậy để config cho AVComposition, ta làm như sau:

```php
let movie = AVMutableComposition()
let videoTrack = movie.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
let audioTrack = movie.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
```
Đoạn code phía trên tạo 1 instance `AVMutableComposition`, sau đó thêm 2 track, 1 track sẽ hold `.video` assets và 1 track hold `.audio` assets, 2 biến track thuộc kiểu `AVMutableCompositionTrack`. Sử dụng signal `kCMPersistendTrackID_Invalid` khi ta muốn 1 id mới, độc nhất cho track của chúng ta.(The `kCMPersistendTrackID_Invalid` signals that you want a new, unique track id generated.)

- Adding Video Clips:

Khi mới khởi tạo, `AVMutableComposition` có start time là CMTime.zero. Ta sẽ sử dụng `insertTimeRange(_ timeRange: CMTimeRange, of track: AVAssetTrack, at startTime: CMTime) throws` cho `videoTrack` và `audioTrack` để add data from clip. Để add data to tracks, ta sẽ load `AVAsset`

```php
let beachMovie: AVURLAsset = myAVURLasset  //1

let beachAudioTrack = beachMovie.tracks(withMediaType: .audio).first! //2
let beachVideoTrack = beachMovie.tracks(withMediaType: .video).first!
let beachRange = CMTimeRangeMake(start: CMTime.zero, duration: beachMovie.duration) //3
try videoTrack?.insertTimeRange(beachRange, of: beachVideoTrack, at: CMTime.zero) //4
try audioTrack?.insertTimeRange(beachRange, of: beachAudioTrack, at: CMTime.zero)
```

Phân tích 2 đoạn code, ta có 1 biến movie thuộc kiểu `AVMutableComposition()`. Từ đây, ta sẽ tạo 2 biến track là `videotrack` và `audioTrack`.
Sau đó ta sẽ có 1 beachMovie thuộc kiểu `AVURLAsset`, ta muốn merge video này, thì ta cùng cần tạo 2 biến track audio và video là beachAudioTrack và beachVideoTrack. Sau đó ta tạo 1 biến beachRange, cho việc track toàn bộ data của beachMovie đó. Sau khi khởi tạo 2 biến track của beachMovie xong, từ sẽ add track đó vào 2 track tổng là videoTrack và audioTrack:

```php
try videoTrack?.insertTimeRange(beachRange, of: beachVideoTrack, at: CMTime.zero) //4
try audioTrack?.insertTimeRange(beachRange, of: beachAudioTrack, at: CMTime.zero)
```

Từ đây, ta đã track được toàn bộ data của asset beachMovie.

Sau khi add xong, nhiệm vụ của ta là expore video đó ra:

```php
let exporter = AVAssetExportSession(asset: movie, 
                                    presetName: AVAssetExportPresetHighestQuality) //1
//configure exporter
exporter?.outputURL = outputMovieURL //2
exporter?.outputFileType = .mp4
//export!
exporter?.exportAsynchronously(completionHandler: { [weak exporter] in
DispatchQueue.main.async {
    if let error = exporter?.error { //3
    print("failed \(error.localizedDescription)")
    } else {
    print("movie has been exported to \(outputMovieURL)")
    }
}
})
```