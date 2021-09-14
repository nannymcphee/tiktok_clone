//
//  CommentCellVM.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 14/09/2021.
//

import RxSwift
import RxCocoa
import Resolver

final class CommentCellVM: BaseVM, ViewModelTransformable {
    // MARK: - Input
    struct Input {
        let comment: TTComment
    }
    
    // MARK: - Output
    struct Output {
        let userInfo: Driver<TTUser>
        let commentTime: Driver<String>
        let isLiked: Driver<Bool>
        let isLikedByOwner: Driver<Bool>
        let likeCount: Driver<Int>
        let comment: Driver<String>
        let replies: Driver<[TTComment]>
    }
    
    // MARK: - Variables
    var commentAuthor: TTUser? {
        return userRelay.value
    }
    var commentAuthorObservable: Observable<TTUser> {
        return userRelay.unwrap().asObservable()
    }

    var comment: TTComment? {
        return commentRelay.value
    }
    var commentObservable: Observable<TTComment> {
        return commentRelay.unwrap().asObservable()
    }
    
    @Injected private var userRepo: UserRepo
    @Injected private var timeFormatter: TimeFormatter
    
    private let commentRelay = BehaviorRelay<TTComment?>(value: nil)
    private let userRelay = BehaviorRelay<TTUser?>(value: nil)
    private let isLikedRelay = BehaviorRelay<Bool>(value: false)
    private let isLikedByOwnerRelay = BehaviorRelay<Bool>(value: false)
    private let commentTimeAgoRelay = BehaviorRelay<String>(value: "")
    private let likeCountRelay = BehaviorRelay<Int>(value: 0)
    private let repliesRelay = BehaviorRelay<[TTComment]>(value: [])

    private var currentUserId: String {
        return (userRepo.currentUser?.id).orEmpty
    }
    
    // MARK: - Public functions
    func transform(input: Input) -> Output {
        let comment = input.comment
        commentRelay.accept(comment)
        isLikedRelay.accept(comment.likedIds.contains(currentUserId))
        isLikedByOwnerRelay.accept(comment.isLikedByOwner)
        commentTimeAgoRelay.accept(timeFormatter.timeAgo(from: Double(comment.createdAt), format: .fullDate))
        repliesRelay.accept(input.comment.replies)
        
        userRepo.getUserInfo(userId: comment.ownerId)
            .asObservable()
            .bind(to: userRelay)
            .disposed(by: disposeBag)
        
        return Output(userInfo: userRelay.unwrap().asDriverOnErrorJustComplete(),
                      commentTime: commentTimeAgoRelay.asDriverOnErrorJustComplete(),
                      isLiked: isLikedRelay.asDriverOnErrorJustComplete(),
                      isLikedByOwner: isLikedByOwnerRelay.asDriverOnErrorJustComplete(),
                      likeCount: likeCountRelay.asDriverOnErrorJustComplete(),
                      comment: Driver.just(comment.comment),
                      replies: repliesRelay.asDriverOnErrorJustComplete())
    }
    
    func updateLikeStatus(isLiked: Bool) {
        isLikedRelay.accept(isLiked)
    }
    
    func updateLikeByOwnerStatus(isLiked: Bool) {
        isLikedByOwnerRelay.accept(isLiked)
    }
}
