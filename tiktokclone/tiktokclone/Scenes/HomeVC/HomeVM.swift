//
//  HomeVM.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 06/09/2021.
//

import RxSwift
import RxCocoa
import Resolver

final class HomeVM: BaseVM, ViewModelTransformable, ViewModelTrackable {
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
    }
    
    // MARK: - Variables
    let loadingIndicator = ActivityIndicator()
    let errorTracker = ErrorTracker()
    
    @Injected private var videoRepo: VideoRepo
    private let videosRelay = BehaviorRelay<[TTVideo]>(value: [])
    private let currentPlaybackStateRelay = BehaviorRelay<VideoPlayerView.PlayerPlaybackState>(value: .unknown)
    
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
            .subscribe(with: self) { viewModel, event in
                switch event {
                case .didTapAvatar(let user):
                    Logger.d("didTapAvatar \(user)")
                case .didTapFollow(let user):
                    Logger.d("didTapFollow \(user)")
                case .didTapLike(let video):
                    Logger.d("didTapLike \(video)")
                case .didTapComment(let video):
                    Logger.d("didTapComment \(video)")
                case .didTapShare(let video):
                    Logger.d("didTapShare \(video)")
                case .didTapMore(let video):
                    Logger.d("didTapMore \(video)")
                case .didUpdatePlaybackState(let playbackState):
                    viewModel.currentPlaybackStateRelay.accept(playbackState)
                }
            }
            .disposed(by: disposeBag)
        
        return Output(videos: videosRelay.asDriverOnErrorJustComplete(),
                      currenPlayerPlaybackState: currentPlaybackStateRelay.asDriverOnErrorJustComplete())
    }
}
