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
    }
    
    // MARK: - Output
    struct Output {
        let videos: Driver<[TTVideo]>
    }
    
    // MARK: - Variables
    let loadingIndicator = ActivityIndicator()
    let errorTracker = ErrorTracker()
    
    @Injected private var videoRepo: VideoRepo
    private let videosRelay = BehaviorRelay<[TTVideo]>(value: [])
    
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
        
        return Output(videos: videosRelay.asDriverOnErrorJustComplete())
    }
}
