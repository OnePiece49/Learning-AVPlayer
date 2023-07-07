//
//  VideoPlayerView.swift
//  LAS_SAMPLE_014
//
//  Created by Đức Anh Trần on 23/06/2023.
//

import UIKit
import AVFoundation

class VideoPlayerView: UIView {

    // MARK: - Properties

    private var player: AVPlayer!
    private var playerLayer: AVPlayerLayer!
    private var statusObserver: NSKeyValueObservation?
    private var timeObserverToken: Any?
    private var isVideoFinished: Bool = false
    private var isSeeking: Bool = false

    // MARK: - Outlets

    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var remainingTimeLabel: UILabel!
    @IBOutlet weak var playVideoImageView: UIView!

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    deinit {
        statusObserver?.invalidate()
        removePeriodicTimeObserver()
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Public methods

    func updateLayoutSubviews() {
        layoutIfNeeded()
        playerLayer.frame = videoView.bounds
    }

    func playVideo(with urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let playerItem = AVPlayerItem(url: url)
        player?.replaceCurrentItem(with: playerItem)
        playVideo()
    }

    // MARK: - Private methods

    private func commonInit() {
        loadFromNib()
        setupUI()
        config()
    }

    private func setupUI() {
        currentTimeLabel.font = UIFont.fontMedium(14)
        currentTimeLabel.textColor = UIColor(rgb: 0x000000)
        remainingTimeLabel.font = UIFont.fontMedium(14)
        remainingTimeLabel.textColor = UIColor(rgb: 0x000000)
        playVideoImageView.layer.cornerRadius = 48/2
        playVideoImageView.layer.masksToBounds = true
        timeSlider.setThumbImage(UIImage(named: "ic_thumb_oval"), for: .normal)
        timeSlider.setThumbImage(UIImage(named: "ic_thumb_oval"), for: .highlighted)
    }

    private func config() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(videoViewHandleTap))
        videoView.addGestureRecognizer(tap)
        setupPlayer()
        addObservers()
    }

    private func setupPlayer() {
        player = AVPlayer()
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = videoView.bounds
        playerLayer.videoGravity = .resizeAspect
        videoView.layer.addSublayer(playerLayer)
    }

    private func shouldShowPlayImage(_ should: Bool) {
        playVideoImageView.alpha = should ? 1 : 0
    }

    private func removePeriodicTimeObserver() {
        if let timeObserverToken = timeObserverToken {
            player.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }

    // MARK: - Actions

    @objc private func videoViewHandleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        if player.isPlaying {
            pauseVideo()
        } else {
            isVideoFinished ? replayVideo() : playVideo()
        }
    }

    @IBAction func sliderValueChanged(_ sender: UISlider, forEvent event: UIEvent) {
        guard let duration = player.currentItem?.duration else { return }
        let totalTime = CMTimeGetSeconds(duration)
        let value = Float64(sender.value) * totalTime
        let seekTime = CMTime(value: CMTimeValue(value), timescale: 1)

        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
                case .began:
                    isSeeking = true
                    pauseVideo()
                case .moved:
                    player.seek(to: seekTime, toleranceBefore: .zero, toleranceAfter: .zero)
                case .ended:
                    isSeeking = false
                    playVideo()
                default:
                    break
            }
        }
        updateTimeLabel(progressTime: seekTime, remainingTime: duration - seekTime)
    }

}

// MARK: - Play, Pause, Replay Video

extension VideoPlayerView {
    func playVideo() {
        player?.play()
        isVideoFinished = false
        shouldShowPlayImage(false)
    }

    func pauseVideo() {
        player?.pause()
        shouldShowPlayImage(true)
    }

    func stopVideo() {
        player?.pause()
        player?.replaceCurrentItem(with: nil)
        shouldShowPlayImage(false)
    }

    func replayVideo() {
        player?.seek(to: CMTime.zero, completionHandler: { [weak self] isFinished in
            self?.playVideo()
        })
    }
}

// MARK: - Observer

private extension VideoPlayerView {
    func addObservers() {
        addPlayerStatusObserver()
        addTimeObserver()
        addNotificationObserver()
    }

    func addPlayerStatusObserver() {
        statusObserver = player?.observe(\.status, options: .new) { [weak self] currentPlayer, _ in
            guard let self = self else { return }
            if currentPlayer.status == .readyToPlay {
                self.shouldShowPlayImage(false)
            }
        }
    }

    func addTimeObserver() {
        let interval = CMTime(value: 1, timescale: 2)
        timeObserverToken = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main, using: { [weak self] progressTime in
            guard let self = self else { return }
            if !self.isSeeking {
                self.updateVideoPlayerState(progressTime: progressTime)
            }
        })
    }

    func updateVideoPlayerState(progressTime: CMTime) {
        guard let duration = player?.currentItem?.duration else { return }
        let remainingTime = duration - progressTime
        timeSlider.value = Float(progressTime.seconds / duration.seconds)
        updateTimeLabel(progressTime: progressTime, remainingTime: remainingTime)
    }

    func updateTimeLabel(progressTime: CMTime, remainingTime: CMTime) {
        currentTimeLabel.text = progressTime.getTimeString()
        remainingTimeLabel.text = remainingTime.getTimeString()

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
        pauseVideo()
        NotificationCenter.default.post(name: .check_video_compress_status, object: nil)
    }

    @objc func playerDidFinishPlaying() {
        isVideoFinished = true
        shouldShowPlayImage(true)
    }

    @objc func stopPlayer(_: Notification) {
        stopVideo()
    }

}
