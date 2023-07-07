//
//  VideoCutterVC.swift
//  LAS_SAMPLE_014
//
//  Created by Minh Tuan on 16/06/2023.
//

import UIKit
import AVFoundation
import Photos
import AVKit
import MobileCoreServices

class VideoCutterVC: BaseVC {
    //MARK: - properties
    var videoAsset: PHAsset!
    var videoName: String = ""
    
    fileprivate var playerLayer: AVPlayerLayer!
    
    var isPlaying: Bool = false
    var isSliderEnd: Bool = true
    
    let exportSession: AVAssetExportSession! = nil
    var player: AVPlayer!
    var playerItem: AVPlayerItem!
    
    var startTime: CGFloat = 0.0
    var stopTime: CGFloat  = 0.0
    var thumbTime: CMTime!
    var thumbtimeSeconds: Int!
    
    var videoPlaybackPosition: CGFloat = 0.0
    var rangeSlider: RangeSlider = RangeSlider()
    
    
    //MARK: - outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var remainTimeLabel: UILabel!
    @IBOutlet weak var rangerView: UIView!
    @IBOutlet weak var rangerSliderView: UIView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var playImageView: UIView!
    
    //MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addGradient()
    }
    
    private func setupUI() {
        rangerSliderView.layer.borderWidth = 5.0
        rangerSliderView.layer.borderColor = UIColor(rgb: 0x9BC2ED).cgColor
        playImageView.layer.cornerRadius = 48/2
        titleLabel.font = UIFont.fontBold(16)
        setupButton()
        player = AVPlayer()
        titleLabel.text = videoName
        
    }
    
    private func setupButton() {
        cancelButton.setTitleColor(UIColor(rgb: 0x4B42ED), for: .normal)
        cancelButton.titleLabel?.font = UIFont.fontMedium(14)
        saveButton.setTitleColor(UIColor(rgb: 0xFFFFFF), for: .normal)
        saveButton.titleLabel?.font = UIFont.fontBold(16)
        saveButton.layer.cornerRadius = 10
        saveButton.layer.masksToBounds = true
    }
    
    private func addGradient() {
        let colors: [UIColor] = [UIColor(rgb: 0x5900FF), UIColor(rgb: 0x67CDFF)]
        let startPoint = CGPoint(x: 0.0, y: 0.0)
        let endPoint = CGPoint(x: 1.0, y: 1.0)
        saveButton.applyGradient(colors: colors, startPoint: startPoint, endPoint: endPoint)
    }
    
    private func loadData() {
        PHCachingImageManager().requestAVAsset(forVideo: videoAsset, options: nil) { (asset, audioMix, args) in
            guard let asset = asset else { return }
            
            if asset.isKind(of: AVComposition.self) {
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: "Notice", message: " Can not support slow motion file", preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: { action in
                        self.navigationController?.popViewController(animated: true)
                        return
                    })
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
            else {
                let assetUrl = asset as! AVURLAsset
                
                DispatchQueue.main.async {
                    self.thumbTime = assetUrl.duration
                    self.thumbtimeSeconds = Int(CMTimeGetSeconds(self.thumbTime))
                    
                    self.viewAfterVideoPicked(asset: assetUrl)
                    
                    let item:AVPlayerItem = AVPlayerItem(asset: assetUrl)
                    self.player                = AVPlayer(playerItem: item)
                    self.playerLayer           = AVPlayerLayer(player: self.player)
                    self.playerLayer.frame     = self.playerView.bounds
                    
                    self.playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
                    self.player.actionAtItemEnd   = AVPlayer.ActionAtItemEnd.none
                    
                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapPlayOrPause))
                    self.playerView.addGestureRecognizer(tap)
                    self.tapPlayOrPause(tap: tap)
                    
                    self.playerView.layer.cornerRadius = 10
                    self.playerView.layer.addSublayer(self.playerLayer)
                    
                    self.player.pause()
                }
            }
        }
    }
    
    @objc func tapPlayOrPause(tap: UITapGestureRecognizer) {
        if isPlaying {
            player.play()
            shouldShowPlayImageView(should: false)
        } else {
            player.pause()
            shouldShowPlayImageView(should: true)
        }
        isPlaying = !isPlaying
    }
    
    private func shouldShowPlayImageView(should: Bool) {
        playImageView.isHidden = !should
    }
    
    func viewAfterVideoPicked(asset: AVURLAsset) {
        if playerLayer != nil {
            playerLayer.removeFromSuperlayer()
        }
        createImageFrames(asset: asset)
        
        saveButton.isHidden         = false
        // startTimeLabel.is          = false
        // endView.isHidden            = false
        rangerView.isHidden = false
        
        
        isSliderEnd = true
        startTimeLabel.text! = "\(0.0)"
        remainTimeLabel.text   = "\(thumbtimeSeconds!)"
        createRangeSlider()
        
    }
    
    func createImageFrames(asset: AVURLAsset)
    {
        //creating assets
        let assetImgGenerate : AVAssetImageGenerator    = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        assetImgGenerate.requestedTimeToleranceAfter    = CMTime.zero;
        assetImgGenerate.requestedTimeToleranceBefore   = CMTime.zero;
        
        
        assetImgGenerate.appliesPreferredTrackTransform = true
        let thumbTime: CMTime = asset.duration
        let thumbtimeSeconds  = Int(CMTimeGetSeconds(thumbTime))
        let maxLength         = "\(thumbtimeSeconds)" as NSString
        
        let thumbAvg  = thumbtimeSeconds/6
        var startTime = 1
        var startXPosition:CGFloat = 0.0
        
        //loop for 6 number of frames
        for _ in 0...5
        {
            
            let imageButton = UIButton()
            let xPositionForEach = CGFloat(rangerSliderView.frame.width)/6
            imageButton.frame = CGRect(x: CGFloat(startXPosition), y: CGFloat(0), width: xPositionForEach, height: CGFloat(rangerSliderView.frame.height))
            do {
                let time:CMTime = CMTimeMakeWithSeconds(Float64(startTime),preferredTimescale: Int32(maxLength.length))
                let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
                let image = UIImage(cgImage: img)
                imageButton.setImage(image, for: .normal)
            }
            catch
                _ as NSError
            {
                print("Image generation failed with error (error)")
            }
            
            startXPosition = startXPosition + xPositionForEach
            startTime = startTime + thumbAvg
            imageButton.isUserInteractionEnabled = false
            rangerSliderView.addSubview(imageButton)
        }
        
    }
    
    //Create range slider
    func createRangeSlider()
    {
        //Remove slider if already present
        let subViews = rangerView.subviews
        for subview in subViews{
            if subview.tag == 1000 {
                subview.removeFromSuperview()
            }
        }
        rangeSlider = RangeSlider(frame: rangerView.bounds)
        rangerView.addSubview(rangeSlider)
        rangeSlider.tag = 1000
        
        //Range slider action
        rangeSlider.addTarget(self, action: #selector(self.rangeSliderValueChanged(_:)), for: .valueChanged)
        
    }
    
    //MARK: rangeSlider Delegate
    @objc func rangeSliderValueChanged(_ rangeSlider: RangeSlider) {
        player.pause()
        
        if(isSliderEnd == true) {
            rangeSlider.minimumValue = 0.0
            rangeSlider.maximumValue = Double(thumbtimeSeconds)
            rangeSlider.upperValue = Double(thumbtimeSeconds)
            isSliderEnd = !isSliderEnd
            
        }
        
        startTimeLabel.text = String(format:"%.2f", rangeSlider.lowerValue)
        remainTimeLabel.text = String(format:"%.2f", rangeSlider.upperValue)
        
        if(rangeSlider.lowerLayerSelected) {
            seekVideo(toPos: CGFloat(rangeSlider.lowerValue))
        }
        else {
            seekVideo(toPos: CGFloat(rangeSlider.upperValue))
        }
        
        //print(startTime)
    }
    //Seek video when slide
    func seekVideo(toPos pos: CGFloat) {
        videoPlaybackPosition = pos
        let time: CMTime = CMTimeMakeWithSeconds(Float64(videoPlaybackPosition), preferredTimescale: player.currentTime().timescale)
        player.seek(to: time, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        
        if(pos == CGFloat(thumbtimeSeconds))
        {
            player.pause()
        }
    }
    
    func cropVideo(sourceURL1: NSURL, startTime:Float, endTime:Float, asset:AVURLAsset,fileName: String) {
        
        let animationConfig = LottieAnimationConfig(estimatedWidth: 144,
                                                    aspectRatio: 1,
                                                    spacingFromVerticalCenter: -50)
        let loadingView = LoadingView(config: LoadingViewConfig(messageText: "Generating video",
                                                                animationName: "animation_cut_video",
                                                                animationConfig: animationConfig))
        loadingView.show()
        
        
        let manager                 = FileManager.default
        //  guard let mediaType         = "mp4" as? String else {return}
        let mediaType = "mp4"
        //  guard sourceURL1 != nil else {return}
        
        if mediaType == kUTTypeMovie as String || mediaType == "mp4" as String
        {
            // let length = Float(asset.duration.value) / Float(asset.duration.timescale)
            //print("video length: \(length) seconds")
            
            let start = startTime
            let end = endTime
            //print(documentDirectory)
            
            let fileName = "CuterVideo_\(fileName).mp4"
            guard let outputURL = URL.videoEditorFolder()?.appendingPathComponent(fileName) else {return}
            
            //Remove existing file
            _ = try? manager.removeItem(at: outputURL)
            
            guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {return}
            exportSession.outputURL = outputURL
            exportSession.outputFileType = AVFileType.mp4
            
            let startTime = CMTime(seconds: Double(start ), preferredTimescale: 1000)
            let endTime = CMTime(seconds: Double(end ), preferredTimescale: 1000)
            let timeRange = CMTimeRange(start: startTime, end: endTime)
            
            exportSession.timeRange = timeRange
            exportSession.exportAsynchronously{
                switch exportSession.status {
                case .completed:
                    print("exported success")
                    DispatchQueue.main.async {
                        loadingView.dismiss()
                        self.view.displayToast("Video cut success!")
                        self.saveButton.isEnabled = true
                        self.rangerView.isUserInteractionEnabled = true
                        self.openMyFile()
                    }
                    // self.saveToCameraRoll(URL: outputURL as NSURL?)
                case .failed:
                    print("failed \(String(describing: exportSession.error))")
                    DispatchQueue.main.async {
                        loadingView.dismiss()
                        self.view.displayToast("Video cut error!")
                        self.saveButton.isEnabled = true
                        self.rangerView.isUserInteractionEnabled = true
                    }
                case .cancelled:
                    print("cancelled \(String(describing: exportSession.error))")
                    DispatchQueue.main.async {
                        loadingView.dismiss()
                        self.view.displayToast("Video cut error!")
                        self.saveButton.isEnabled = true
                        self.rangerView.isUserInteractionEnabled = true
                    }
                default: break
                }
            }
            
        }
        
    }
    
    //MARK: - action
    @IBAction func saveButtonTapped(_ sender: Any) {
        let start = Float(startTimeLabel.text!)
        let end   = Float(remainTimeLabel.text!)
        self.saveButton.isEnabled = false
        self.rangerView.isUserInteractionEnabled = false
        
        PHCachingImageManager().requestAVAsset(forVideo: videoAsset, options: nil) { (asset, audioMix, args) in
            let asset = asset as! AVURLAsset
            let url = asset.url as NSURL
            DispatchQueue.main.async {
                self.cropVideo(sourceURL1: url, startTime: start!, endTime: end!,asset: asset,fileName: self.videoName)
            }
        }
    }
    
    @IBAction func backClick(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
