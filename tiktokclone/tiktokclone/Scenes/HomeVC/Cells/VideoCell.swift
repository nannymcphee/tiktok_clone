//
//  VideoCell.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 06/09/2021.
//

import UIKit
import AVKit
import RxSwift
import RxCocoa
import RxGesture

class VideoCell: CollectionViewCell, EventPublisherType {
    // MARK: - IBOutlets
    @IBOutlet weak var ivThumbnail: UIImageView!
    @IBOutlet weak var btnAvatar: UIButton!
    @IBOutlet weak var btnFollow: UIButton!
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var lbLikeCount: UILabel!
    @IBOutlet weak var btnComment: UIButton!
    @IBOutlet weak var lbCommentCount: UILabel!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var lbShareCount: UILabel!
    @IBOutlet weak var btnMore: UIButton!
    @IBOutlet weak var ivSongCover: UIImageView!
    @IBOutlet weak var lbUsername: UILabel!
    @IBOutlet weak var lbDescription: UILabel!
    @IBOutlet weak var lbHashTags: UILabel!
    @IBOutlet weak var lbSongName: MarqueeLabel!
    @IBOutlet weak var ivMusicNote: UIImageView!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var svButtons: UIStackView!
    @IBOutlet weak var svLabels: UIStackView!
    
    // MARK: - Event
    enum Event {
        case didToggleVideo(isPlay: Bool)
        case didTapAvatar(TTUser)
        case didTapFollow(TTUser)
        case didTapLike(TTVideo)
        case didTapComment(TTVideo)
        case didTapShare(TTVideo)
        case didTapMore(TTVideo)
        case didUpdatePlaybackState(VideoPlayerView.PlayerPlaybackState)
        case didUpdatePlaybackProgress((video: TTVideo, progress: Float))
        case didUpdatePlayedTime((video: TTVideo, playedTimeText: String))
    }
    
    // MARK: - Variables
    var viewModel: VideoCellVM?
    var player: AVPlayer? {
        return videoPlayerView?.player
    }
    var playerItem: AVPlayerItem? {
        return videoPlayerView?.playerItem
    }
    var currentVideo: TTVideo? {
        return currentVideoRelay.value
    }
    let eventPublisher = PublishSubject<Event>()
    
    private var videoPlayerView: VideoPlayerView?
    private var isLiked: Bool = false
    private var currentVideoRelay = BehaviorRelay<TTVideo?>(value: nil)
    private var videoAuthorRelay = BehaviorRelay<TTUser?>(value: nil)
    private var currentPlaybackState = BehaviorRelay<VideoPlayerView.PlayerPlaybackState>(value: .unknown)
    
    // MARK: - Overrides
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpUI()
    }
    
    override func reset() {
        currentPlaybackState.accept(.unknown)
        currentVideoRelay.accept(nil)
        viewModel = nil
        isLiked = false
        lbUsername.text = nil
        lbDescription.text = nil
        lbHashTags.text = nil
        lbSongName.text = nil
        lbLikeCount.text = "0"
        lbCommentCount.text = "0"
        lbShareCount.text = "0"
        ivThumbnail.image = nil
        ivSongCover.image = nil
        btnAvatar.setImage(R.image.ic_avatar_placeholder(), for: .normal)
        btnLike.setImage(R.image.ic_heart_filled(), for: .normal)
        ivSongCover.layer.removeAllAnimations()
        ivSongCover.transform = .identity
        setInitialStateBtnPlay()
        videoPlayerView?.delegate = nil
        ivSongCover.layer.removeAllAnimations()
        super.reset()
    }
    
    // MARK: - Public functions
    func populateData(with data: TTVideo) {
        let viewModel = VideoCellVM()
        let input = VideoCellVM.Input(video: data)
        let output = viewModel.transform(input: input)
        self.viewModel = viewModel
        videoPlayerView?.delegate = self
        
        // Binding video
        output.video
            .drive(with: self, onNext: { cell, video in
                cell.currentVideoRelay.accept(video)
                cell.ivThumbnail.setImage(url: video.thumbnailURL)
                cell.lbDescription.text = video.description
                cell.lbLikeCount.text = "\(video.likedIds.count)"
                cell.lbHashTags.text = video.tags.map { "#" + $0 }.joined(separator: " ")
            })
            .disposed(by: disposeBag)
        
        // Binding video's author info
        output.videoAuthor
            .drive(with: self) { cell, user in
                cell.lbUsername.text = user.displayTikTokId
                cell.btnAvatar.imageView?.setImage(url: user.profileImage)
                cell.videoAuthorRelay.accept(user)
            }
            .disposed(by: disposeBag)
        
        // Is liked by currentUser
        output.isLiked
            .drive(with: self, onNext: {
                $0.isLiked = $1
                $0.btnLike.tintColor = $1 ? AppColors.red : .white
            })
            .disposed(by: disposeBag)
        
        // Comments count
        output.commentCount
            .map { "\($0)" }
            .drive(lbCommentCount.rx.text)
            .disposed(by: disposeBag)
        
        lbSongName.text = "Some song name...\t- Author name..."
        ivSongCover.image = R.image.ic_avatar_placeholder()
        startAnimations()
        bindingUI()
    }
    
    func setInitialUI() {
        ivThumbnail.isHidden = false
        setInitialStateBtnPlay()
    }
    
    func insertPlayerView(_ videoPlayerView: VideoPlayerView) {
        videoPlayerView.frame = bounds
        videoPlayerView.delegate = self
        insertSubview(videoPlayerView, at: 0)
    }
    
    func animateViewWhileSeeking(_ isSeeking: Bool) {
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            guard let self = self else { return }
            
            self.svLabels.alpha = isSeeking ? 0 : 1
            self.svButtons.alpha = isSeeking ? 0 : 1
            self.ivMusicNote.alpha = isSeeking ? 0 : 1
            self.lbSongName.alpha = isSeeking ? 0 : 1
            self.ivSongCover.alpha = isSeeking ? 0 : 1
        })
    }
    
    // MARK: - Private functions
    private func setUpUI() {
        setInitialStateBtnPlay()
        btnAvatar.imageView?.contentMode = .scaleAspectFill
        ivMusicNote.tintColor = .white
        btnPlay.tintColor = .white
        btnFollow.tintColor = AppColors.red
        [btnLike, btnComment, btnShare, btnMore].forEach {
            $0?.tintColor = .white
        }
        
        [lbUsername, lbDescription, lbHashTags, lbSongName,
         lbLikeCount, lbCommentCount, lbShareCount].forEach {
            $0?.textColor = .white
         }
        
        [lbLikeCount, lbCommentCount, lbShareCount].forEach {
            $0.font = R.font.milliardMedium(size: 14)
        }
        
        lbUsername.font = R.font.milliardSemiBold(size: 15)
        lbDescription.font = R.font.milliardLight(size: 14)
        lbHashTags.font = R.font.milliardSemiBold(size: 14)
        lbSongName.font = R.font.milliardLight(size: 13)
        
        lbSongName.fadeLength = 10
    }
    
    private func bindingUI() {
        // Cell tapped
        rx.tapGesture(configuration: { gestureRecognizer, delegate in
            delegate.otherFailureRequirementPolicy = .custom { gestureRecognizer, otherGestureRecognizer in
                if let otherGesture = otherGestureRecognizer as? UITapGestureRecognizer, otherGesture.numberOfTapsRequired == 2 {
                    return true
                }
                
                if otherGestureRecognizer is UILongPressGestureRecognizer {
                    return true
                }
                
                return false
            }
        })
        .when(.recognized)
        .subscribe(with: self, onNext: { cell, _ in
            switch cell.currentPlaybackState.value {
            case .playing:
                cell.eventPublisher.onNext(.didToggleVideo(isPlay: false))
                cell.animatePlayButton(isHidden: false)
            case .paused, .stopped:
                cell.eventPublisher.onNext(.didToggleVideo(isPlay: true))
                cell.animatePlayButton(isHidden: true)
            default:
                break
            }
        })
        .disposed(by: disposeBag)
        
        // Cell double tapped
        rx.tapGesture(configuration: { gestureRecognizer, _ in
            gestureRecognizer.numberOfTapsRequired = 2
        })
        .when(.recognized)
        .withLatestFrom(currentVideoRelay)
        .unwrap()
        .do(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.isLiked.toggle()
            self.viewModel?.updateIsLiked(self.isLiked)
        })
        .map { Event.didTapLike($0) }
        .bind(to: eventPublisher)
        .disposed(by: disposeBag)
        
        // Cell long pressed
        rx.longPressGesture()
            .when(.ended)
            .withLatestFrom(currentVideoRelay)
            .unwrap()
            .map { Event.didTapMore($0) }
            .bind(to: eventPublisher)
            .disposed(by: disposeBag)
        
        // Avatar button tap
        btnAvatar.rx.tap.mapToVoid()
            .withLatestFrom(videoAuthorRelay)
            .unwrap()
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .map { Event.didTapAvatar($0) }
            .bind(to: eventPublisher)
            .disposed(by: disposeBag)
        
        // Follow button tap
        btnFollow.rx.tap
            .withLatestFrom(videoAuthorRelay)
            .unwrap()
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .map { Event.didTapFollow($0) }
            .bind(to: eventPublisher)
            .disposed(by: disposeBag)
        
        // Like button tap
        btnLike.rx.tap
            .withLatestFrom(currentVideoRelay)
            .unwrap()
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .map { Event.didTapLike($0) }
            .bind(to: eventPublisher)
            .disposed(by: disposeBag)
        
        // Share button tap
        btnShare.rx.tap
            .withLatestFrom(currentVideoRelay)
            .unwrap()
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .map { Event.didTapShare($0) }
            .bind(to: eventPublisher)
            .disposed(by: disposeBag)
        
        // Comment button tap
        btnComment.rx.tap
            .withLatestFrom(currentVideoRelay)
            .unwrap()
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .map { Event.didTapComment($0) }
            .bind(to: eventPublisher)
            .disposed(by: disposeBag)
        
        // Share button tap
        btnShare.rx.tap
            .withLatestFrom(currentVideoRelay)
            .unwrap()
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .map { Event.didTapShare($0) }
            .bind(to: eventPublisher)
            .disposed(by: disposeBag)
        
        // Did update playbackState
        currentPlaybackState
            .map { Event.didUpdatePlaybackState($0) }
            .bind(to: eventPublisher)
            .disposed(by: disposeBag)
        
        // Application willEnterForeground
        UIApplication.rx.willEnterForeground
            .asDriverOnErrorJustComplete()
            .drive(with: self) { cell, _ in
                cell.startAnimations()
            }
            .disposed(by: disposeBag)
    }
    
    private func setInitialStateBtnPlay() {
        btnPlay.alpha = 0
        btnPlay.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
    }
    
    private func animatePlayButton(isHidden: Bool) {
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.btnPlay.alpha = isHidden ? 0 : 1
            if !isHidden {
                self?.btnPlay.transform = .identity
            }
        }, completion: { [weak self] _ in
            if isHidden {
                self?.setInitialStateBtnPlay()
            }
        })
    }
    
    private func startAnimations() {
        ivSongCover.rotate()
        lbSongName.type = .continuous
    }
}

extension VideoCell: VideoPlayerViewDelegate {
    func playerView(_ playerView: VideoPlayerView, didUpdate playbackProgress: Float) {
        guard let video = currentVideo else { return }
        eventPublisher.onNext(.didUpdatePlaybackProgress((video: video, progress: playbackProgress)))
    }
    
    func playerView(_ playerView: VideoPlayerView, didUpdatePlaybackTime time: Double) {
        guard let video = currentVideo else { return }
        let playedTime = CMTime(seconds: time, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        eventPublisher.onNext(.didUpdatePlayedTime((video: video, playedTimeText: playedTime.durationFormatted())))
    }
    
    func playerView(_ playerView: VideoPlayerView, didUpdate playbackState: VideoPlayerView.PlayerPlaybackState) {
        switch playbackState {
        case .stopped, .failed:
            playerView.isHidden = true
            setInitialUI()
            
        case .paused:
            playerView.isHidden = false
            ivThumbnail.isHidden = true
            
        case .playing:
            playerView.isHidden = false
            ivThumbnail.isHidden = true
            animatePlayButton(isHidden: true)
            
        default:
            break
        }
        
        currentPlaybackState.accept(playbackState)
    }
    
    func playerView(_ playerView: VideoPlayerView,
                    didFinishConfiguring asset: AVAsset,
                    playerLayer: AVPlayerLayer) {
        playerLayer.videoGravity = .resizeAspectFill
    }
}
