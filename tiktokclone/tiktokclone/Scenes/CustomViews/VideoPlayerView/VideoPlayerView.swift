//
//  VideoPlayerView.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 06/09/2021.
//

import UIKit
import AVKit
import AVFoundation

protocol VideoPlayerViewDelegate: AnyObject {
    func playerView(_ playerView: VideoPlayerView, didUpdatePlaybackTime time: Double)
    func playerView(_ playerView: VideoPlayerView, didUpdate status: AVPlayerItem.Status)
    func playerView(_ playerView: VideoPlayerView, didUpdate playbackState: VideoPlayerView.PlayerPlaybackState)
    func playerView(_ playerView: VideoPlayerView, didFinishConfiguring asset: AVAsset, playerLayer: AVPlayerLayer)
}

extension VideoPlayerViewDelegate {
    func playerView(_ playerView: VideoPlayerView, didUpdatePlaybackTime time: Double) {}
    func playerView(_ playerView: VideoPlayerView, didUpdate status: AVPlayerItem.Status) {}
    func playerView(_ playerView: VideoPlayerView, didUpdate playbackState: VideoPlayerView.PlayerPlaybackState) {}
    func playerView(_ playerView: VideoPlayerView, didFinishConfiguring asset: AVAsset, playerLayer: AVPlayerLayer) {}
}

class VideoPlayerView: BaseView {
    // MARK: - IBOUTLETS
    @IBOutlet weak var vPlayerContainer: UIView!
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    
    enum PlayerPlaybackState {
        case loading
        case playing
        case paused
        case stopped
        case finished
        case failed
        case readyToPlay
        case unknown
    }
    
    // MARK: - VARIABLES
    weak var delegate: VideoPlayerViewDelegate?
    var player: AVPlayer?
    
    var playerLayer: AVPlayerLayer!
    
    var videoURL: URL!
    
    var isPlaying: Bool {
        return player != nil && player?.rate != 0
    }
    
    var currentPlayerStatus: AVPlayerItem.Status = .unknown {
        didSet {
            delegate?.playerView(self, didUpdate: currentPlayerStatus)
        }
    }
    private var isSeekInProgress = false {
        didSet {
            if isSeekInProgress {
                playerPlaybackState = .loading
            } else {
                playerPlaybackState = isPlaying ? .playing : .paused
            }
        }
    }
    private var chaseTime: CMTime = CMTime.zero
    private var asset: AVAsset!
    private var playerItemContext = 0
    private var timeObserverToken: Any?
    // Keep the reference and use it to observe the loading status.
    public var playerItem: AVPlayerItem?
    private var playerPlaybackState = PlayerPlaybackState.paused {
        didSet {
            handlePlayerPlaybackState(playerPlaybackState)
            delegate?.playerView(self, didUpdate: playerPlaybackState)
        }
    }
    var autoPlay: Bool = false
    var isMuted: Bool = false
    var parentView: UIView!
    var viewFrame = CGRect.zero
    var videoDuration: Double {
        return CMTimeGetSeconds(self.player?.currentItem?.asset.duration ?? .zero)
    }

    deinit {
        playerItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        removeBoundaryTimeObserver()
    }
    
    // MARK: - OVERRIDES
    override func layoutSubviews() {
        super.layoutSubviews()
        self.playerLayer?.frame = self.bounds
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        setUpView()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        // Only handle observations for the playerItemContext
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
                self.currentPlayerStatus = .unknown
            }
            
            self.currentPlayerStatus = status
            self.loadingActivityIndicator.stopAnimating()

            switch status {
            case .readyToPlay:
                playerPlaybackState = .readyToPlay
                if autoPlay {
                    player?.play()
                    playerPlaybackState = .playing
                }
            case .failed:
                playerPlaybackState = .failed
            case .unknown:
                playerPlaybackState = .unknown
            @unknown default:
                playerPlaybackState = .unknown
            }
        }
    }
    
    // MARK: - PUBLIC FUNCTIONS
    static func instance(with delegate: VideoPlayerViewDelegate?) -> VideoPlayerView {
        let nib = UINib(nibName: "VideoPlayerView", bundle: Bundle(for: VideoPlayerView.self))
        guard let videoPlayerView = nib.instantiate(withOwner: nil, options: nil).first as? VideoPlayerView else {
            return VideoPlayerView()
        }
        videoPlayerView.delegate = delegate
        return videoPlayerView
    }
    
    func play(with url: URL) {
        autoPlay = true
        setUpAsset(with: url) { [weak self] (asset) in
            guard let self = self else { return }
            self.setUpPlayerItem(with: asset)
            self.videoURL = url
        }
    }
    
    func preparePlayerItem(with url: URL) {
        self.setUpAsset(with: url, completion: { [weak self] (asset) in
            guard let self = self else { return }
            self.setUpPlayerItem(with: asset)
            self.videoURL = url
        })
    }
    
    func pause() {
        player?.pause()
        playerPlaybackState = .paused
    }
    
    func resume() {
        guard playerPlaybackState != .playing else {
            Logger.e("Invalid playBackState: Resume video while playing")
            return
        }
        player?.play()
        playerPlaybackState = .playing
    }
    
    func stop() {
        player?.pause()
        player?.seek(to: CMTime.zero)
        playerPlaybackState = .stopped
    }
    
    func replayVideo() {
        stopPlayingAndSeekSmoothlyToTime(newChaseTime: CMTime.zero, isReplay: true)
    }
    
    func toggleMute(isMuted: Bool) {
        player?.isMuted = isMuted
        self.isMuted = isMuted
    }
    
    func resetPlayer() {
        self.pause()
        self.player?.seek(to: CMTime.zero)
        self.player?.isMuted = self.isMuted
        self.player?.replaceCurrentItem(with: nil)
    }
    
    func showLoading() {
        self.loadingActivityIndicator.startAnimating()
    }
    
    func hideLoading() {
        self.loadingActivityIndicator.stopAnimating()
    }
    
    // MARK: - PRIVATE FUNCTIONS
    @objc private func playerDidFinishPlaying() {
        self.playerPlaybackState = .finished
    }
    
    private func setUpView() {
        playerPlaybackState = .loading
    }
    
    private func setUpAsset(with url: URL, completion: ((_ asset: AVAsset) -> Void)?) {
        asset = AVAsset(url: url)
        asset.loadValuesAsynchronously(forKeys: ["playable"]) {
            var error: NSError? = nil
            let status = self.asset.statusOfValue(forKey: "playable", error: &error)
            switch status {
            case .loaded:
                completion?(self.asset)
            case .failed:
                print(".failed")
            case .cancelled:
                print(".cancelled")
            default:
                print("default")
            }
        }
    }
    
    private func setUpPlayerItem(with asset: AVAsset) {
        playerItem = AVPlayerItem(asset: asset)
        playerItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.old, .new], context: &playerItemContext)
                    
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.player = AVPlayer(playerItem: self.playerItem!)
            self.player?.isMuted = self.isMuted
            self.playerLayer = AVPlayerLayer(player: self.player)
            self.playerLayer.frame = self.vPlayerContainer.bounds
            self.playerLayer.videoGravity = .resizeAspect
            self.vPlayerContainer.layer.addSublayer(self.playerLayer)
            self.addPeriodicTimeObserver()
            self.delegate?.playerView(self, didFinishConfiguring: asset, playerLayer: self.playerLayer)
        }
    }
    
    private func addPeriodicTimeObserver() {
        // Notify every half second
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 0.5, preferredTimescale: timeScale)

        timeObserverToken = player?.addPeriodicTimeObserver(forInterval: time, queue: .main) { [weak self] time in
            guard let self = self else { return }
            self.delegate?.playerView(self, didUpdatePlaybackTime: time.seconds)
        }
    }

    private func removeBoundaryTimeObserver() {
        if let timeObserverToken = timeObserverToken {
            player?.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
    
    private func handlePlayerPlaybackState(_ state: PlayerPlaybackState) {
        switch state {
        case .loading:
            self.loadingActivityIndicator.startAnimating()
        case .playing:
            self.loadingActivityIndicator.stopAnimating()
        default:
            self.loadingActivityIndicator.stopAnimating()
        }
    }
    
    private func handlePlayPauseVideo() {
        if self.isPlaying {
            self.pause()
        } else {
            self.resume()
        }
    }
    
    private func stopPlayingAndSeekSmoothlyToTime(newChaseTime: CMTime, isReplay: Bool) {
        self.pause()
        
        if CMTimeCompare(newChaseTime, chaseTime) != 0 || isReplay {
            chaseTime = newChaseTime;
            
            if !isSeekInProgress {
                trySeekToChaseTime(isReplay: isReplay)
            }
        }
    }
    
    private func trySeekToChaseTime(isReplay: Bool) {
        if currentPlayerStatus == .unknown {
            // wait until item becomes ready (KVO player.currentItem.status)
        } else if currentPlayerStatus == .readyToPlay {
            actuallySeekToTime(isReplay: isReplay)
        }
    }
    
    private func actuallySeekToTime(isReplay: Bool) {
        isSeekInProgress = true
        let seekTimeInProgress = chaseTime
        player?.seek(to: seekTimeInProgress, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero, completionHandler: { [weak self] (isFinished) in
            guard let self = self else { return }
            if CMTimeCompare(seekTimeInProgress, self.chaseTime) == 0 {
                if isReplay {
                    self.resume()
                }
                self.isSeekInProgress = false
            } else {
                self.trySeekToChaseTime(isReplay: isReplay)
            }
        })
    }
}
