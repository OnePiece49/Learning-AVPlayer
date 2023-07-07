//
//  HomeVC.swift
//  LAS_SAMPLE_100
//
//  Created by Minh Tuan on 12/06/2023.
//

import UIKit
import Photos

enum GenerateType: String {
    case cutterVideo, generateVideo, mergeVideo, myFlie
    
    func title() -> String {
        switch self {
            
        case .cutterVideo: return "Video Cutter"
        case .generateVideo: return "Merge Video With Audo"
        case .mergeVideo: return "Merge Video"
        case .myFlie: return "My File"
        }
    }
    
    func imageName() -> String {
        switch self {
        case .cutterVideo: return "ic_video_cutter"
        case .generateVideo: return "ic_video_audio_merge"
        case .mergeVideo: return "ic_video_merge"
        case .myFlie: return "ic_my_file"
        }
    }
}

class HomeVC: BaseVC {
    //MARK: - properties
    var layout: [GenerateType] = [.cutterVideo, .generateVideo, .mergeVideo, .myFlie]
    
    fileprivate var videoPicker = UIImagePickerController()
    
    //MARK: - outlets
    @IBOutlet weak var homeCLView: UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!
    
    //MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // setupUI
        homeCLView.register(UINib(nibName: HomeItemCell.cellId
                                  , bundle: nil), forCellWithReuseIdentifier: HomeItemCell.cellId)
        
        homeCLView.delegate = self
        homeCLView.dataSource = self
        titleLabel.font = UIFont.fontBold(24)
        titleLabel.textColor = UIColor(rgb: 0x1E2332)
    }
    
    
    func requestData() {
        if #available(iOS 14, *) {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
                
                // Handle restricted or denied state
                switch status {
                case .notDetermined:
                    self?.displayError(error: "Unknown error")
                case .restricted:
                    self?.displayError(error: "Photo gallery access restricted by corporate or parental settings")
                case .denied:
                    self?.displayError(error: "Photo gallery access denied by user")
                case .authorized:
                    self?.openVideoPicker()
                case .limited:
                    self?.displayError(error: "Limited! Please change to select all Photo")
                    //self?.openVideoPicker()
                @unknown default:
                    self?.displayError(error: "Unknown error")
                }
            }
        } else {
            // Fallback on earlier versions
            openVideoPicker()
        }
    }
    
    func displayError(error: String) {
        
        DispatchQueue.main.async {
            let controller = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            controller.addAction(UIAlertAction(title: "Open Settings", style: .default, handler: { (action) in
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                } else {
                    // Fallback on earlier versions
                }
            }))
            self.present(controller, animated: true, completion: nil)
        }
        
        
    }
    
    func openVideoPicker() {
        DispatchQueue.main.async {
            self.videoPicker = UIImagePickerController()
            self.videoPicker.delegate = self
            self.videoPicker.sourceType = .savedPhotosAlbum
            self.videoPicker.mediaTypes = ["public.movie"]
            self.videoPicker.allowsEditing = false
            self.present(self.videoPicker, animated: true, completion: nil)
        }
    }
}

extension HomeVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return layout.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeItemCell.cellId, for: indexPath) as! HomeItemCell
        cell.homeDetail = layout[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch layout[indexPath.row] {
            
        case .cutterVideo:
            self.requestData()
        case .generateVideo:
            guard let navi = UIWindow.keyWindow?.rootViewController as? UINavigationController else {
                return
            }
            let mergeVideoAudioVC: MergeVideoAudioVC = MergeVideoAudioVC()
            navi.pushViewController(mergeVideoAudioVC, animated: true)
        case .mergeVideo:
            guard let navi = UIWindow.keyWindow?.rootViewController as? UINavigationController else {
                return
            }
            
            let photoVC: PhotoVC
            photoVC = PhotoVC(type: .mergeVideo)
            photoVC.generateType = .mergeVideo
            navi.pushViewController(photoVC, animated: true)
        case .myFlie:
            guard let navi = UIWindow.keyWindow?.rootViewController as? UINavigationController else {
                return
            }
            let myFileVC: MyFileVC = MyFileVC()
            navi.pushViewController(myFileVC, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIDevice.current.is_iPhone ?
            .init(top: 20, left: 20, bottom: 0, right: 20) :
            .init(top: 30, left: 84, bottom: 0, right: 84)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return UIDevice.current.is_iPhone ? 24 : 84
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (UIScreen.main.bounds.width - (padding * 4)) / 2
        let height = width
        return CGSize(width: width, height: height)
        
    }
}

extension HomeVC : UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let videoAsset = info[.phAsset] as? PHAsset
        let videoName = videoAsset?.value(forKey: "filename") as! String
        self.dismiss(animated: true, completion: nil)
        
        guard let navi = UIWindow.keyWindow?.rootViewController as? UINavigationController else {
            return
        }
        let videoCutterVC: VideoCutterVC = VideoCutterVC()
        videoCutterVC.videoAsset = videoAsset
        videoCutterVC.videoName = videoName
        navi.pushViewController(videoCutterVC, animated: true)
        
    }
}
