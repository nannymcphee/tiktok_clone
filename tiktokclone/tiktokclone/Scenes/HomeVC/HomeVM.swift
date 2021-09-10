//
//  HomeVM.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 06/09/2021.
//

import RxSwift
import RxCocoa
import Resolver

final class HomeVM: BaseVM, ViewModelTransformable, ViewModelTrackable, EventPublisherType {
    // MARK: - Input
    struct Input {
        let viewDidLoadTrigger: Observable<Void>
        let refreshTrigger: Observable<Void>
        let videoCellEvent: Observable<VideoCell.Event>
    }
    
    // MARK: - Output
    struct Output {
        let videos: Driver<[TTVideo]>
        let currenPlayerPlaybackState: Driver<VideoPlayerView.PlayerPlaybackState>
        let playVideo: Driver<Bool>
        let sliderValueUpdated: Driver<(video: TTVideo, progress: Float)>
        let playedTimeUpdated: Driver<(video: TTVideo, playedTimeText: String)>
    }
    
    // MARK: - Event
    enum Event {
        case didTapComment(TTVideo)
    }
    
    // MARK: - Variables
    let loadingIndicator = ActivityIndicator()
    let errorTracker = ErrorTracker()
    let eventPublisher = PublishSubject<Event>()
    
    @Injected private var videoRepo: VideoRepo
    @Injected private var userRepo: UserRepo
    
    private let videosRelay = BehaviorRelay<[TTVideo]>(value: [])
    private let currentPlaybackStateRelay = BehaviorRelay<VideoPlayerView.PlayerPlaybackState>(value: .unknown)
    private let playVideoSubject = PublishSubject<Bool>()
    private let sliderValueUpdateSubject = PublishSubject<(video: TTVideo, progress: Float)>()
    private let playedTimeUpdateSubject = PublishSubject<(video: TTVideo, playedTimeText: String)>()

    // MARK: - Public functions
    func transform(input: Input) -> Output {
        // Initial load
        Observable.merge(input.viewDidLoadTrigger, input.refreshTrigger)
            .flatMap(weakObj: self) { viewModel, _ in
                viewModel.videoRepo
                    .getVideos()
                    .trackError(viewModel.errorTracker, action: .alert)
                    .trackActivity(viewModel.loadingIndicator)
                    .catchErrorJustComplete()
            }
            .bind(to: videosRelay)
            .disposed(by: disposeBag)
        
        input.videoCellEvent
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self) { viewModel, event in
                switch event {
                case .didTapAvatar(let user):
                    Logger.d("didTapAvatar \(user)")
                case .didTapFollow(let user):
                    Logger.d("didTapFollow \(user)")
                case .didTapLike(let video):
//                    viewModel.handleLikeVideo(video)
                    Logger.d("didTapLike \(video)")
                case .didTapComment(let video):
                    viewModel.eventPublisher.onNext(.didTapComment(video))
                case .didTapShare(let video):
                    Logger.d("didTapShare \(video)")
                case .didTapMore(let video):
                    Logger.d("didTapMore \(video)")
                case .didUpdatePlaybackState(let playbackState):
                    viewModel.currentPlaybackStateRelay.accept(playbackState)
                case let .didUpdatePlaybackProgress((video, progress)):
                    viewModel.sliderValueUpdateSubject.onNext((video: video, progress: progress))
                case let .didUpdatePlayedTime((video, playedTimeText)):
                    viewModel.playedTimeUpdateSubject.onNext((video: video, playedTimeText: playedTimeText))
                case .didToggleVideo(let isPlay):
                    viewModel.playVideoSubject.onNext(isPlay)
                }
            }
            .disposed(by: disposeBag)
        
        return Output(videos: videosRelay.asDriverOnErrorJustComplete(),
                      currenPlayerPlaybackState: currentPlaybackStateRelay.asDriverOnErrorJustComplete(),
                      playVideo: playVideoSubject.asDriverOnErrorJustComplete(),
                      sliderValueUpdated: sliderValueUpdateSubject.asDriverOnErrorJustComplete(),
                      playedTimeUpdated: playedTimeUpdateSubject.asDriverOnErrorJustComplete())
    }
}

// MARK: - Private functions
private extension HomeVM {
    func handleLikeVideo(_ video: TTVideo) {
        guard let userId = userRepo.currentUser?.id else {
            Logger.e("Like video failed: currentUser not found")
            return
        }
        
        let isLike = !video.likedIds.contains(userId)
        
        videoRepo.toggleLikeVideo(videoId: video.id, userId: userId, isLike: isLike)
            .subscribe(with: self, onSuccess: { viewModel, _ in
                var updatedVideo = video
                if isLike {
                    updatedVideo.likedIds.append(userId)
                    updatedVideo.commentCount = updatedVideo.commentCount + 1
                } else {
                    updatedVideo.likedIds.removeAll(where: { $0 == userId })
                    updatedVideo.commentCount = updatedVideo.commentCount - 1
                }
                
                var _videos = viewModel.videosRelay.value
                if let index = _videos.firstIndex(of: video) {
                    _videos[index] = updatedVideo
                }
                
                viewModel.videosRelay.accept(_videos)
            })
            .disposed(by: disposeBag)
    }
}
