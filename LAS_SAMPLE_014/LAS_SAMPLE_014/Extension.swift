//
//  Extend.swift
//  LAS_SAMPLE_100
//
//  Created by Minh Tuan on 12/06/2023.
//

import UIKit
import Photos

let columns: CGFloat = UIDevice.current.is_iPhone ? 3 : 5
let spacing: CGFloat = UIDevice.current.is_iPhone ? 5 : 16
let padding: CGFloat = UIDevice.current.is_iPhone ? 16 : 64

extension Notification.Name {
    static let stop_player = Notification.Name("stop_video")
    static let check_video_compress_status = Notification.Name("check_video_compress_status")
}

extension UIFont {

    static func fontRegular(_ size: CGFloat) -> UIFont? {
        return UIFont(name: "ClashDisplay-Regular", size: size)
    }
    
    static func fontMedium(_ size: CGFloat) -> UIFont? {
        return UIFont(name: "ClashDisplay-Medium", size: size)
    }
    
    static func fontBold(_ size: CGFloat) -> UIFont? {
        return UIFont(name: "ClashDisplay-Bold", size: size)
    }
    
}

extension UIColor {
    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(red: (rgb >> 16) & 0xFF, green: (rgb >> 8) & 0xFF, blue: rgb & 0xFF)
    }
}

extension UICollectionViewCell {
    static var cellId: String {
        return String(describing: self)
    }
}


extension UITableViewCell {
    static var cellId: String {
        return String(describing: self)
    }
}

extension UIDevice {
    var is_iPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
}

extension UIDevice {
    var is_iPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
}

extension UIWindow {
    static var keyWindow: UIWindow? {
        // iOS13 or later
        if #available(iOS 13.0, *) {
            guard let scene = UIApplication.shared.connectedScenes.first,
                  let sceneDelegate = scene.delegate as? SceneDelegate else { return nil }
            return sceneDelegate.window
        } else {
            // iOS12 or earlier
            guard let appDelegate = UIApplication.shared.delegate else { return nil }
            return appDelegate.window ?? nil
        }
    }
}
extension PHAsset {

    var getImageMaxSize : UIImage {
        var thumbnail = UIImage()
        let imageManager = PHImageManager.default()
        let option = PHImageRequestOptions()
        option.isSynchronous = true
        imageManager.requestImage(for: self, targetSize: CGSize.init(width: 720, height: 1080), contentMode: .aspectFit, options: option, resultHandler: { image, _ in
            thumbnail = image!
        })
        return thumbnail
    }
    
    
    var getImageThumb : UIImage {
        var thumbnail = UIImage()
        let imageManager = PHImageManager.default()
        let option = PHImageRequestOptions()
        option.isSynchronous = true
        imageManager.requestImage(for: self, targetSize: CGSize.init(width: 400, height: 400), contentMode: .aspectFit, options: option, resultHandler: { image, _ in
            thumbnail = image!
        })
        return thumbnail
    }
    
    
    
    
    var originalFilename: String? {
        return PHAssetResource.assetResources(for: self).first?.originalFilename
    }
    var originalName: String? {
        let str = PHAssetResource.assetResources(for: self).first?.originalFilename.dropLast(4)
        return "\(str ?? "Video")"
    }
    
    func getDuration(videoAsset: PHAsset?) -> String {
        guard let asset = videoAsset else { return "00:00" }
        let duration: TimeInterval = asset.duration
        let s: Int = Int(duration) % 60
        let m: Int = Int(duration) / 60
        let formattedDuration = String(format: "%02d:%02d", m, s)
        return formattedDuration
    }
}

extension URL {
    static func cache() -> URL {
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    static func document() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    static func createFolder(folderName: String) -> URL? {
        let fileManager = FileManager.default
        // Get document directory for device, this should succeed
        if let documentDirectory = fileManager.urls(for: .documentDirectory,
                                                    in: .userDomainMask).first {
            // Construct a URL with desired folder name
            let folderURL = documentDirectory.appendingPathComponent(folderName)
            // If folder URL does not exist, create it
            if !fileManager.fileExists(atPath: folderURL.path) {
                do {
                    // Attempt to create folder
                    try fileManager.createDirectory(atPath: folderURL.path,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
                } catch {
                    // Creation failed. Print error & return nil
                    print(error.localizedDescription)
                    return nil
                }
            }
            // Folder either exists, or was created. Return URL
            return folderURL
        }
        // Will only be called if document directory not found
        return nil
    }
    
    
    static func videoEditorFolder() -> URL? {
        return self.createFolder(folderName: "videoEditor")
    }
}

extension String {
    var fileURL: URL {
        return URL(fileURLWithPath: self)
    }
    
    var pathExtension: String {
        return fileURL.pathExtension
    }
    
    var lastPathComponent: String {
        return fileURL.lastPathComponent
    }
    
    var fileName: String {
        return fileURL.deletingPathExtension().lastPathComponent
    }
    
    var json: [String:Any]? {
        let data = Data(self.utf8)
        
        do {
            // make sure this JSON is in the format we expect
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any]
            return json
        } catch let error as NSError {
            print("Failed to load: \(error.localizedDescription)")
            return nil
        }
    }
    
}
import Toast_Swift

extension UIView {
    
    func getViewsByType<T: UIView>(type _: T.Type) -> [T] {
        return getAllSubViews().compactMap { $0 as? T }
    }
    
    func displayToast(_ message: String) {
        guard let window = UIWindow.keyWindow else { return }
        
        window.hideAllToasts()
        window.makeToast(message, duration: 3.0, position: .top )
    }
    
    private func getAllSubViews() -> [UIView] {
        var subviews = self.subviews
        if subviews.isEmpty {
            return subviews
        }
        for view in subviews {
            subviews += view.getAllSubViews()
        }
        return subviews
    }
    
    @discardableResult
    func loadFromNib<T: UIView>() -> T? {
        guard let contentView = Bundle(for: type(of: self)).loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)?.first as? T else { return nil }
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        contentView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        contentView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        return contentView
    }

    func applyGradient(colors: [UIColor],
                       locations: [NSNumber]? = nil,
                       startPoint: CGPoint,
                       endPoint: CGPoint) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.locations = locations
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        gradientLayer.frame = self.bounds
        self.layer.insertSublayer(gradientLayer, at: 0)
    }

    func applyBlurBackground() {
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(blurEffectView)
    }

}

extension CMTime {
    func getTimeString() -> String? {
        let totalSeconds = CMTimeGetSeconds(self)
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
}

extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}

extension PHFetchOptions {
    
    func sort(key: String)-> PHFetchOptions {
        let option = PHFetchOptions()
        let sort = NSSortDescriptor(key: key, ascending: false)
        option.sortDescriptors = [sort]
        return option
    }
    
    func getUserVideo()-> PHFetchOptions {
        let option = PHFetchOptions()
        option.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.video.rawValue)
        option.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        return option
    }
}


extension UIView {
    func setDimensions(width: CGFloat, height: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: width),
            heightAnchor.constraint(equalToConstant: height),
        ])
    }

}

extension UIViewController {
    var insetTop: CGFloat {
          if #available(iOS 11.0, *) {
              let window = UIApplication.shared.keyWindow
              let topPadding = window?.safeAreaInsets.top ?? 0
              return topPadding
          }
          
          return 0
      }
}

extension Date {
    func convertToString(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}

