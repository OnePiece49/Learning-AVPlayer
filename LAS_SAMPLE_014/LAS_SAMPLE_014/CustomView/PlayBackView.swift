//
//  PlayBackView.swift
//  SoundMazae
//
//  Created by MaiMai on 11/05/2022.
//

import AVFoundation
import UIKit

final class PlayBackView: UIView {
    // MARK: - Outlets
    
    @IBOutlet private var playPauseButton: UIButton!
    @IBOutlet private var timeSlider: UISlider!
    @IBOutlet private var timeRemainingLabel: UILabel!
    @IBOutlet weak var timeCurrentLabel: UILabel!
    
    
    
    
    // MARK: - Controls & Properties
    
    var pauseAutoHidePlayBackClosure: (() -> Void)?
    var onFlip:((Bool)->Void)?
    private var player: AVPlayer?
    private var isVideoFinished: Bool = false
    private var statusObserver: NSKeyValueObservation?
    
    // MARK: - Override Methods
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadFromNib()
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadFromNib()
        setup()
    }
    
    // MARK: - Deinit
    
    deinit {
        statusObserver?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Public Methods
    
    func config(with player: AVPlayer) {
        self.player = player
        addObservers()
    }
    
    // MARK: - Private Methods
    
    private func setup() {
        // timeSlider.setThumbImage(Constant.icTrack, for: .normal)
        timeSlider.addTarget(self, action: #selector(timeSliderValueChanged(_:event:)), for: .valueChanged)
    }
    
    @objc private func timeSliderValueChanged(_ sender: UISlider, event: UIEvent) {
        guard let duration = player?.currentItem?.duration else { return }
        let totalSeconds = CMTimeGetSeconds(duration)
        guard !(totalSeconds.isNaN || totalSeconds.isInfinite) else { return }
        let value = Float64(sender.value) * totalSeconds
        let seekTime = CMTime(value: CMTimeValue(value), timescale: 1)
        
        // Seek and scrub video
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began:
                pauseVideo()
            case .moved:
                player?.seek(to: seekTime, toleranceBefore: .zero, toleranceAfter: .zero)
            case .ended:
                playVideo()
                isVideoFinished = false
            default:
                break
            }
        }
        
        // Update time remaining label
        let timeRemaining = duration - seekTime
        guard let timeRemainingString = timeRemaining.getTimeString() else { return }
        timeCurrentLabel.text = seekTime.getTimeString()
        timeRemainingLabel.text = timeRemainingString
        
        // Delay auto hide playback
        pauseAutoHidePlayBackClosure?()
    }
    
    @IBAction private func playPauseButtonTapped(_ sender: Any) {
        guard let player = player else { return }
        if player.isPlaying {
            pauseVideo()
        } else {
            if isVideoFinished {
                replayVideo()
            } else {
                playVideo()
            }
        }
        
        pauseAutoHidePlayBackClosure?()
    }
    
    
    @IBAction func prev10Action(_ sender: Any) {
        backwardTime(second: 10.0)
    }
    
    @IBAction func prevAction(_ sender: Any) {
        backwardTime(second: 2.0)
        
    }
    
    @IBAction func nextAction(_ sender: Any) {
        forwardTime(second: 2.0)
    }
    
    @IBAction func next10Action(_ sender: Any) {
        forwardTime(second: 10.0)
    }
    
    @IBAction func flipAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            onFlip?(true)
        } else {
            onFlip?(false)
        }
        
    }
    private func backwardTime(second: Float64) {
        
        guard let currentTime = player?.currentTime() else { return }
        let currentSecond = CMTimeGetSeconds(currentTime)
        guard !(currentSecond.isNaN || currentSecond.isInfinite) else { return }
        var newTime = currentSecond - second
        if newTime < 0 {
            newTime = 0
        }
        let time: CMTime = CMTimeMake(value: Int64(newTime*1000), timescale: 1000)
        player?.seek(to: time)
        
        // Delay auto hide playback
        pauseAutoHidePlayBackClosure?()
        
    }
    
    private func forwardTime(second: Float64) {
        
        guard let duration = player?.currentItem?.duration else { return }
        guard let currentTime = player?.currentTime() else {return}
        let currentSecond = CMTimeGetSeconds(currentTime)
        let newTime  =  currentSecond + second
        
        if newTime < (CMTimeGetSeconds(duration) - second) {
            let time: CMTime = CMTimeMake(value: Int64(newTime*1000), timescale: 1000)
            player?.seek(to: time)
        } else if newTime >= (CMTimeGetSeconds(duration) - second) {
            player?.seek(to: duration)
        }
    }
    
    
}

// MARK: - Play, Pause, Replay Video

extension PlayBackView {
    func playVideo() {
        player?.play()
        playPauseButton.setImage(UIImage(named: "ic_pause"), for: .normal)
    }
    
    func pauseVideo() {
        player?.pause()
        playPauseButton.setImage(UIImage(named: "ic_play"), for: .normal)
    }
    
    func stopVideo() {
        player?.pause()
        player?.replaceCurrentItem(with: nil)
        //player = nil
    }

    
    func replayVideo() {
        isVideoFinished = false
        player?.seek(to: CMTime.zero, completionHandler: { [weak self] isFinished in
            self?.player?.play()
        })
        playPauseButton.setImage(UIImage(named: "ic_pause"), for: .normal)
    }
}

// MARK: - Observers

private extension PlayBackView {
    func addObservers() {
        // Observer player's status
        addPlayerStatusObserver()
        
        addTimeObserver()
        addNotificationObserver()
    }
    
    func addPlayerStatusObserver() {
        statusObserver = player?.observe(\.status, options: .new) { [weak self] currentPlayer, _ in
            guard let self = self else { return }
            if currentPlayer.status == .readyToPlay {
                self.playPauseButton.setImage(UIImage(named: "ic_pause"), for: .normal)
            }
        }
    }
    
    func addTimeObserver() {
        let interval = CMTime(value: 1, timescale: 2)
        player?.addPeriodicTimeObserver(forInterval: interval, queue: .main, using: { [weak self] progressTime in
            self?.updateVideoPlayerState(progressTime: progressTime)
        })
    }
    
    func updateVideoPlayerState(progressTime: CMTime) {
        // Update time slider's value
        guard let duration = player?.currentItem?.duration else { return }
        timeSlider.value = Float(progressTime.seconds / duration.seconds)
        
        // Update time remaining label
        let timeRemaining = duration - progressTime
        guard let timeRemainingString = timeRemaining.getTimeString() else { return }
        timeCurrentLabel.text = progressTime.getTimeString()
        timeRemainingLabel.text = timeRemainingString
    }
    
    func addNotificationObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didEnterBackground(_:)),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(stopPlayer(_:)),
                                               name: .stop_player,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerDidFinishPlaying),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: nil)
    }
    
    @objc func didEnterBackground(_: Notification) {
        player?.pause()
        playPauseButton.setImage(UIImage(named: "ic_play"), for: .normal)
        NotificationCenter.default.post(name: .check_video_compress_status, object: nil)
    }
    
    @objc func playerDidFinishPlaying() {
        isVideoFinished = true
        playPauseButton.setImage(UIImage(named: "ic_play"), for: .normal)
    }
    
    @objc func stopPlayer(_: Notification) {
        self.stopVideo()
        playPauseButton.setImage(UIImage(named: "ic_play"), for: .normal)
    }

}
