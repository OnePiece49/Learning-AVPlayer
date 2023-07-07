//
//  PhotoVC.swift
//  LAS_SAMPLE_100
//
//  Created by Minh Tuan on 12/06/2023.
//

import UIKit
import Photos

enum PhotoVCType {
    case mergeVideo
    case mergeAudio
}

class PhotoVC: BaseVC {
    //MARK: - properties
    let type: PhotoVCType
    var navigationBar: NavigationCustomView!
    var generateType: GenerateType = .cutterVideo
    var bottomPhotoConstraint: NSLayoutConstraint!
    let heightBottom: CGFloat = 140
    let bottomPhoto = BottomSheetPhotoView(frame: .zero)
    var loadingView: LoadingView!
    
    var selectedVideo: ((AVURLAsset?, String?) -> Void)?
    
    var allPhotos: [PHAsset] = []
    fileprivate var selectedPhoto: [PHAsset] = []
    
    var onSelectedPhotos:((_ photos: [PHAsset])->Void)?
    
    //MARK: - outlets
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var photoCLView: UICollectionView!
    @IBOutlet weak var mergeButton: UIButton!
    
    init(type: PhotoVCType) {
        self.type = type
        super.init(nibName: "PhotoVC", bundle: nil)
        self.generateType = .mergeVideo
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("DEBUG: photo deinit")
    }
    
    //MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        // Do any additional setup after loading the view.
        //setup UI
        let config = LoadingViewConfig(messageText: "Merge Video",
                                       animationName: "animation_merge_video",
                                       animationConfig: LottieAnimationConfig(estimatedWidth: 168,
                                                                              aspectRatio: 168 / 158,
                                                                              spacingFromVerticalCenter: -40))
        loadingView = LoadingView(config: config)
        
        photoCLView.register(UINib(nibName: PhotoItemCell.cellId, bundle: nil), forCellWithReuseIdentifier: PhotoItemCell.cellId)
        photoCLView.delegate = self
        photoCLView.dataSource = self
        bottomPhoto.delegate = self
        requestData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
                    self?.fetchPhotos()
                case .limited:
                    self?.displayError(error: "limited")
                @unknown default:
                    self?.displayError(error: "Unknown error")
                }
            }
        } else {
            // Fallback on earlier versions
            self.fetchPhotos()
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
    
    private func fetchPhotos() {
        // Fetch all video assets from the Photos Library as fetch results
        let option = PHFetchOptions()
        let sort = NSSortDescriptor(key: "creationDate", ascending: false)
        option.sortDescriptors = [sort]
        if generateType == .cutterVideo {
            let fetchResults = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: option)
            allPhotos = Array(_immutableCocoaArray: fetchResults)
        } else {
            let fetchResults = PHAsset.fetchAssets(with: PHAssetMediaType.video, options: option)
            allPhotos = Array(_immutableCocoaArray: fetchResults)
        }
        
        // Reload the table view on the main thread
        DispatchQueue.main.async {
            self.photoCLView.reloadData()
        }
    }
    
    func configureUI() {
        view.backgroundColor = .clear
        let attributeRightButton = AttibutesButton(tilte: "Cancel",
                                                   font: UIFont.fontMedium(14) ?? UIFont.systemFont(ofSize: 14),
                                                   titleColor: UIColor(rgb: 0x4B42ED)) { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        
        let attributed = NSAttributedString(attributedString: NSAttributedString(string: "Choose Video",
                                                                                 attributes: [.foregroundColor: UIColor.black, .font : UIFont.fontBold(16)]))
        self.navigationBar = NavigationCustomView(attributedTitle: attributed,
                                                  attributeLeftButtons: [],
                                                  attributeRightBarButtons: [attributeRightButton],
                                                  isHiddenDivider: true,
                                                  beginSpaceRightButton: 15)
        
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        photoCLView.translatesAutoresizingMaskIntoConstraints = false
        navigationBar.backgroundColor = .white
        photoCLView.backgroundColor = .white
        view.backgroundColor = .white
        
        view.addSubview(navigationBar)
        view.addSubview(bottomPhoto)
        bottomPhoto.translatesAutoresizingMaskIntoConstraints = false
        
        bottomPhotoConstraint = bottomPhoto.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: heightBottom)
        
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBar.leftAnchor.constraint(equalTo: view.leftAnchor),
            navigationBar.rightAnchor.constraint(equalTo: view.rightAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: 45),
            
            photoCLView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            photoCLView.leftAnchor.constraint(equalTo: view.leftAnchor),
            photoCLView.rightAnchor.constraint(equalTo: view.rightAnchor),
            photoCLView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            bottomPhotoConstraint,
            bottomPhoto.leftAnchor.constraint(equalTo: view.leftAnchor),
            bottomPhoto.rightAnchor.constraint(equalTo: view.rightAnchor),
            bottomPhoto.heightAnchor.constraint(equalToConstant: heightBottom),
        ])
        
        view.layoutIfNeeded()
        bottomPhoto.applyGradient()
    }
    
    private func updateLayoutBottomPhotos() {
        if selectedPhoto.isEmpty {
            UIView.animate(withDuration: 0.3) {
                self.bottomPhotoConstraint.constant = self.heightBottom
                self.view.layoutIfNeeded()
                self.photoCLView.contentInset = .init(top: 0, left: 0, bottom: 0, right: 0)
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                let y = self.photoCLView.contentOffset.y
                
                if y + self.view.frame.height - 45 - self.insetTop >= self.photoCLView.contentSize.height && self.bottomPhotoConstraint.constant == self.heightBottom {
                    self.bottomPhoto.backgroundColor = UIColor(rgb: 0xB0C4DE)
                    self.photoCLView.contentOffset.y = self.photoCLView.contentOffset.y + self.heightBottom
                }
                
                self.bottomPhotoConstraint.constant = 0
                self.view.layoutIfNeeded()
                self.photoCLView.contentInset = .init(top: 0, left: 0, bottom: self.heightBottom, right: 0)
            }
        }
    }
    
    func mergeClick() {
        var videoUrls: [URL] = []
        if selectedPhoto.count > 1 {
            loadingView.show()
            let dispathGroup = DispatchGroup()
            
            for video in selectedPhoto {
                dispathGroup.enter()
                let options: PHVideoRequestOptions = PHVideoRequestOptions()
                
                options.version = .original
                
                PHImageManager.default().requestAVAsset(forVideo: video, options: options, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
                    if let urlAsset = asset as? AVURLAsset {
                        let localVideoUrl: URL = urlAsset.url as URL
                        videoUrls.append(localVideoUrl)
                    }
                    dispathGroup.leave()
                })
            }
            
            dispathGroup.notify(queue: .main) {
                let fileName = "Merge_\(self.selectedPhoto[0].originalName ?? "")"
                VideoGenerator.presetName = AVAssetExportPresetPassthrough
                VideoGenerator.fileName = fileName
                
//                self.mergeMovie(videoURLs: videoUrls)
                self.mergeVideosByViet(videoURLs: videoUrls)
            }
            
        } else {
            self.view.displayToast("Please choose more than 2 videos!")
        }
    }
    
    private func mergeMovie(videoURLs: [URL]) {
        VideoGenerator.mergeMovies(videoURLs: videoURLs) { (result) in
            self.loadingView.dismiss()
            switch result {
            case .success(let url):
                print(url)
                DispatchQueue.main.async {
                    self.navigationController?.pushViewController(MyFileVC(), animated: true)
                    self.view.displayToast("Merge successfully: \(url.path.fileName)")
                }
            case .failure(let error):
                print(error)
                self.view.displayToast("Merge error!!!")
            }
        }
    }
    
    func mergeVideosByViet(videoURLs: [URL]) {
//        let url = URL(string: "https://github.com/Vietdz123/Learning-AVPlayer/blob/main/ReadMe-Player.md#phan2")
//        print("DEBUG: \(url?.lastPathComponent)")
//        videoURLs.forEach { video in
//            print("DEBUG: \(video.lastPathComponent)")
//        }
        
        for i in 0...2 {
            print("DEBUG: \(self.allPhotos[i].value(forKey: "filename"))")
        }
        
        

        let acceptedFile = ["mp4", "mov", "m4v"]
        
    
        
        let _videoUrls = videoURLs.filter { url in
            return !url.absoluteString.contains(".DS_Store") && acceptedFile.contains(url.pathExtension.lowercased())
        }
        
        if videoURLs.isEmpty {
            return
        }
        
        let mergeVideo = AVMutableComposition()
        let mergeVideoTrack = mergeVideo.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        let mergeAudioTrack = mergeVideo.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        var videoAVUrl: [AVURLAsset] = []
        var insertTime = CMTime(seconds: 0, preferredTimescale: 1)
        
        _videoUrls.forEach { url in
            let avurl = AVURLAsset(url: url)
            videoAVUrl.append(avurl)
        }
        
        videoAVUrl.forEach { avurl in
            guard let videoTrack = avurl.tracks(withMediaType: .video).first, let audioTrack = avurl.tracks(withMediaType: .audio).first else {return}

            let frameRange = CMTimeRange(start: CMTime(seconds: 0, preferredTimescale: 1), duration: avurl.duration)
            try? mergeAudioTrack?.insertTimeRange(frameRange, of: videoTrack, at: insertTime)
            try? mergeAudioTrack?.insertTimeRange(frameRange, of: audioTrack, at: insertTime)
        }
        
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {return}
        let folder = url.appendingPathExtension("videoEditor").appendingPathExtension("Merge_\(AVAsset(url: url))")
        let data = AVAsset(url: url) as? AVURLAsset
        
    }
    
    @IBAction func addClick(_ sender: Any) {
        if selectedPhoto.count > 0 {
            onSelectedPhotos?(selectedPhoto)
            self.navigationController?.popViewController(animated: true)
        } else {
            let ac = UIAlertController(title: "Please choose image!!!", message: nil, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { _ in
                // don't nothing
                
            }))
            self.present(ac, animated: true)
        }
    }
    
    @IBAction func backClick(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
}

extension PhotoVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoItemCell.cellId,
                                                      for: indexPath) as! PhotoItemCell
        
        cell.delegate = self
        cell.photo = allPhotos[indexPath.row]
        cell.hasAddPhoto()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoItemCell
        
        cell.checkClick()
        if type == .mergeAudio {
            guard let asset = selectedPhoto.first else {
                self.selectedVideo?(nil, nil);
                return
            }
            let filename = asset.value(forKey: "filename") as! String
            let options: PHVideoRequestOptions = PHVideoRequestOptions()
            options.version = .original
            
            PHImageManager.default().requestAVAsset(forVideo: asset, options: options, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
                if let avasset = asset as? AVURLAsset  {
                    DispatchQueue.main.async {
                        self.selectedVideo?(avasset, filename)
                        self.navigationController?.popViewController(animated: true)
                        
                    }
                }
            })
            return
        }
        bottomPhoto.selectedPhotos = self.selectedPhoto
        if cell.isRemoved() {
            bottomPhoto.reloadData()
        } else {
            bottomPhoto.insertData()
        }
        updateLayoutBottomPhotos()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 0,
                     left: spacing,
                     bottom: 0,
                     right: spacing)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spacing / 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (UIScreen.main.bounds.width - spacing * 2 - ((columns - 1) * (padding/2))) / columns
        let height = width
        return CGSize(width: width, height: height)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.photoCLView  && self.bottomPhotoConstraint.constant == 0 {
            let y = scrollView.contentOffset.y
            
            if y + self.view.frame.height - heightBottom - 45 - self.insetTop >= self.photoCLView.contentSize.height {
                self.bottomPhoto.backgroundColor = UIColor(rgb: 0xB0C4DE)
            } else {
                self.bottomPhoto.backgroundColor = .clear
            }
        }
    }
    
}

extension PhotoVC: PhotoItemCellDelegate {
    func addOrRemove(_ photo: PHAsset) {
        if let index = selectedPhoto.firstIndex(where: { $0.localIdentifier == photo.localIdentifier }) {
            selectedPhoto.remove(at: index)
        }
        else {
            selectedPhoto.append(photo)
        }
    }
    
    func isExists(_ photo: PHAsset) -> Bool {
        return selectedPhoto.first(where: { $0.localIdentifier == photo.localIdentifier }) != nil
    }
}

extension PhotoVC: BottomSheetPhotoDelegate {
    func didSelectMergeButton() {
        self.mergeClick()
    }
    
    func didSelectDeleteButton(photo: PHAsset) {
        guard let index = self.allPhotos.firstIndex(of: photo) else {return}
        let indexPath = IndexPath(row: index, section: 0)
        
        let cell = photoCLView.cellForItem(at: indexPath) as? PhotoItemCell
        
        selectedPhoto.removeAll { $0.localIdentifier == photo.localIdentifier }
        cell?.updateCheckList(photo: photo)
        updateLayoutBottomPhotos()
    }
}
