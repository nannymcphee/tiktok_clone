//
//  VideoCellVM.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 06/09/2021.
//

import RxSwift
import RxCocoa
import RxGesture
import Resolver

final class VideoCellVM: BaseVM, ViewModelTransformable, EventPublisherType {
    // MARK: - Input
    struct Input {
        let video: TTVideo
    }
    
    // MARK: - Output
    struct Output {
        let video: Driver<TTVideo>
        let videoAuthor: Driver<TTUser>
        let isLiked: Driver<Bool>
    }
    
    // MARK: - Event
    enum Event {
        case didTapAvatar(TTUser)
        case didTapFollow(TTUser)
        case didTapLike(TTVideo)
        case didTapComment(TTVideo)
        case didTapShare(TTVideo)
        case didTapMore(TTVideo)
    }
    
    // MARK: - Variables
    let eventPublisher = PublishSubject<Event>()
    
    @Injected private var userRepo: UserRepo
    
    private let videoRelay = BehaviorRelay<TTVideo?>(value: nil)
    private let authorRelay = BehaviorRelay<TTUser?>(value: nil)
    private let isLikedRelay = BehaviorRelay<Bool>(value: false)
    
    // MARK: - Public functions
    func transform(input: Input) -> Output {
        videoRelay.accept(input.video)
        
        // Video's author info
        userRepo.getUserInfo(userId: input.video.ownerId)
            .asObservable()
            .catchErrorJustComplete()
            .bind(to: authorRelay)
            .disposed(by: disposeBag)
        
        // Is liked by currentUser
        if let userId = userRepo.currentUser?.id, input.video.likedIds.contains(userId) {
            isLikedRelay.accept(true)
        }
            
        return Output(video: Driver.just(input.video),
                      videoAuthor: authorRelay.unwrap().asDriverOnErrorJustComplete(),
                      isLiked: isLikedRelay.asDriverOnErrorJustComplete())
    }
    
    func updateIsLiked(_ isLiked: Bool) {
        isLikedRelay.accept(isLiked)
    }
}
