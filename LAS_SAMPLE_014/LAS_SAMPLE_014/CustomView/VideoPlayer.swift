//
//  VideoPlayer.swift
//  SoundMazae
//
//  Created by MaiMai on 11/05/2022.
//

import UIKit
import AVFoundation

final class VideoPlayer: UIView {
    // MARK: - Outlets
    
    @IBOutlet private var videoView: UIView!
    @IBOutlet private var closeButton: UIButton!
    @IBOutlet private var playBackView: PlayBackView!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var lockButton: UIButton!
    @IBOutlet weak var convertButton: UIButton!
    
    // MARK: - Properties
    
    private var player: AVPlayer!
    private var playerLayer: AVPlayerLayer!
    private var isShowPlayBack = true
    private var playerTimer: Timer?
    private var isLockPlayback = false
    
    var dismissClosure: (() -> Void)?
    var captureVideo: ((UIImage)-> Void)?
    var onConvertMp3:(()->Void)?
    
    // MARK: - Override Methods
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        config()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
        config()
    }
    
    // MARK: - Public Methods
    
    func playVideo(with urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let playerItem = AVPlayerItem(url: url)
        player?.replaceCurrentItem(with: playerItem)
        playBackView.playVideo()
    }
    
    func pauseVideo() {
        playBackView.pauseVideo()
    }
    
    func playVideo() {
        playBackView.playVideo()
    }
    
    func updateLayoutSubviews() {
        layoutIfNeeded()
        playerLayer.frame = videoView.bounds
    }
    
    // MARK: - Private Methods
    
    private func commonInit() {
        guard let contentView = Bundle.main.loadNibNamed(String(describing: VideoPlayer.self), owner: self, options: nil)?.first as? UIView else { return }
        contentView.frame = self.bounds
        addSubview(contentView)
    }
    
    private func config() {
        // Tap gesture
        let controlTapGesture = UITapGestureRecognizer(target: self, action: #selector(playerViewHandleTap))
        self.addGestureRecognizer(controlTapGesture)
        
        setupPlayer()
        
        playBackView.config(with: player)
        playBackView.pauseAutoHidePlayBackClosure = { [weak self] in
            self?.resetTimer()
        }
        playBackView.onFlip = { flip in
            if flip {
                self.videoView.transform = self.videoView.transform.concatenating(CGAffineTransform(scaleX: -1, y: 1))
            }
            else {
                self.videoView.transform = .identity
            }
        }
        
        startTimer()
    }
    
    private func setupPlayer() {
        player = AVPlayer()
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = videoView.bounds
        playerLayer.videoGravity = .resizeAspect
        videoView.layer.addSublayer(playerLayer)
        
    }
    
    @IBAction private func closeButtonHandleTapped(_ sender: Any) {
        dismissClosure?()
        playerTimer?.invalidate()
    }
    
    @IBAction func captureAction(_ sender: Any) {
        
        
        var videoImage = UIImage()
        
        if let url = (player.currentItem?.asset as? AVURLAsset)?.url {
            
            let asset = AVAsset(url: url)
            
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.requestedTimeToleranceAfter = CMTime.zero
            imageGenerator.requestedTimeToleranceBefore = CMTime.zero
            
            if let thumb: CGImage = try? imageGenerator.copyCGImage(at: player.currentTime(), actualTime: nil) {
                //print("video img successful")
                videoImage = UIImage(cgImage: thumb)
                
            }
            
        }
        captureVideo?(fixOrientation(img: videoImage))
    }
    
    @IBAction func convertAction(_ sender: Any) {
        onConvertMp3?()
    }
    func fixOrientation(img: UIImage) -> UIImage {
        if (img.imageOrientation == .up) {
            return img
        }
        
        UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale)
        let rect = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
        img.draw(in: rect)
        
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return normalizedImage
    }
    
    @IBAction func lockAction(_ sender: UIButton) {
        
        
        if !sender.isSelected {
            isLockPlayback = true
            isShowPlayBack = true
            showHidePlayBackView()
        } else {
            isLockPlayback = false
            isShowPlayBack = false
            showHidePlayBackView()
        }
        sender.isSelected = !sender.isSelected
        
    }
    
    
    @objc private func playerViewHandleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        let location = gestureRecognizer.location(in: self)
        guard let contentView = self.getViewsByType(type: PlayBackView.self).first else { return }
        
        if contentView.frame.contains(location) && isShowPlayBack {
            return
        }
        if isLockPlayback {
            
        } else {
            showHidePlayBackView()
        }
        
    }
}

// MARK: - Show / Hide PlayBack

private extension VideoPlayer {
    func startTimer() {
        playerTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(autoHidePlayBack), userInfo: nil, repeats: false)
    }
    
    func resetTimer() {
        playerTimer?.invalidate()
        startTimer()
    }
    
    @objc func autoHidePlayBack() {
        if isShowPlayBack {
            showHidePlayBackView()
        }
    }
    
    func showHidePlayBackView() {
        isShowPlayBack = !isShowPlayBack
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            guard let self = self else { return }
            self.closeButton.alpha = !self.isShowPlayBack ? 0 : 1
            self.captureButton.alpha = !self.isShowPlayBack ? 0 : 1
            self.playBackView.alpha = !self.isShowPlayBack ? 0 : 1
            self.convertButton.alpha = !self.isShowPlayBack ? 0 : 1
        })
        if isShowPlayBack {
            resetTimer()
        }
    }
}
