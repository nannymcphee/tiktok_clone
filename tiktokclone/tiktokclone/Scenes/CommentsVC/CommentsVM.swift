//
//  CommentsVM.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 12/09/2021.
//

import RxSwift
import RxCocoa
import Resolver

final class CommentsVM: BaseVM, ViewModelTransformable, ViewModelTrackable, EventPublisherType {
    // MARK: - Input
    struct Input {
        let viewDidLoadTrigger: Observable<Void>
        let dismissTrigger: Observable<Void>
        let submitCommentTrigger: Observable<Void>
        let commentText: Observable<String>
        let toggleLikeCommentTrigger: Observable<(comment: TTComment, isLike: Bool)>
        let commentCellEvent: Observable<CommentCell.Event>
    }
    
    // MARK: - Output
    struct Output {
        let comments: Driver<[TTComment]>
        let commentCount: Driver<String>
        let userAvatar: Driver<String>
        let replyComment: Driver<(comment: TTComment, user: TTUser)>
    }
    
    // MARK: - Event
    enum Event {
        case dismiss
    }
    
    // MARK: - Initializers
    init(video: TTVideo) {
        self.video = video
    }
    
    // MARK: - Variables
    @Injected private var userRepo: UserRepo
    @Injected private var commentRepo: CommentRepo
    
    let eventPublisher = PublishSubject<Event>()
    let loadingIndicator = ActivityIndicator()
    let errorTracker = ErrorTracker()
    
    private var video: TTVideo
    private var currentUserId: String? {
        return userRepo.currentUser?.id
    }
    
    private let commentsRelay = BehaviorRelay<[TTComment]>(value: [])
    private let avatarRelay = BehaviorRelay<String>(value: "")
    private let replyCommentSubject = PublishSubject<(comment: TTComment, user: TTUser)>()
    private var replyingCommentRelay = BehaviorRelay<TTComment?>(value: nil)
    
    // MARK: - Public functions
    func transform(input: Input) -> Output {
        // Load data
        input.viewDidLoadTrigger
            .flatMapLatest(weakObj: self, { viewModel, _ -> Observable<[TTComment]> in
                return viewModel.commentRepo
                    .getComments(videoId: viewModel.video.id)
                    .trackError(viewModel.errorTracker, action: .log)
                    .trackActivity(viewModel.loadingIndicator)
                    .catchErrorJustComplete()
            })
            .bind(to: commentsRelay)
            .disposed(by: disposeBag)
        
        // Binding avatar
        avatarRelay.accept((userRepo.currentUser?.profileImage).orEmpty)
        
        // Dismiss
        input.dismissTrigger
            .map { Event.dismiss }
            .bind(to: eventPublisher)
            .disposed(by: disposeBag)
        
        // Submit comment
        input.submitCommentTrigger
            .withLatestFrom(input.commentText)
            .flatMapLatest(weakObj: self) { viewModel, comment -> Observable<TTComment> in
                guard let userId = viewModel.currentUserId else { return .error(VideoUploadError.invalidUserId) }
                guard let parentComment = viewModel.replyingCommentRelay.value else {
                    // Submit new comment
                    return viewModel.commentRepo
                        .submitComment(video: viewModel.video, userId: userId, comment: comment)
                        .trackError(viewModel.errorTracker, action: .alert)
                        .trackActivity(viewModel.loadingIndicator)
                        .catchErrorJustComplete()
                }
                
                // Submit Reply comment
                return viewModel.commentRepo.submitReply(comment: comment, parentComment: parentComment, userId: userId)
                    .trackError(viewModel.errorTracker, action: .alert)
                    .trackActivity(viewModel.loadingIndicator)
                    .catchErrorJustComplete()
            }
            .subscribe(with: self, onNext: { viewModel, submittedComment in
                viewModel.replyingCommentRelay.accept(nil)
                viewModel.loadComments()
            })
            .disposed(by: disposeBag)
        
        // Comment cell event
        input.commentCellEvent
            .subscribe(with: self, onNext: { viewModel, event in
                switch event {
                case .didTapAvatar(let user):
                    Logger.d("didTapAvatar \(user.username)")
                case let .didTapReply((comment, user)):
                    viewModel.replyingCommentRelay.accept(comment)
                    viewModel.replyCommentSubject.onNext((comment, user))
                case let .toggleLikeComment((comment, isLike)):
                    Logger.d("toggleLikeComment \(comment.comment), isLike: \(isLike)")
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        
        let commentCountObservable = commentRepo
            .getCommentsCount(videoId: video.id)
            .map { "\($0) comments" }
            .asObservable()
        
        return Output(comments: commentsRelay.asDriver(),
                      commentCount: commentCountObservable.asDriverOnErrorJustComplete(),
                      userAvatar: avatarRelay.asDriver(),
                      replyComment: replyCommentSubject.asDriverOnErrorJustComplete())
    }
}

// MARK: - Private functions
private extension CommentsVM {
    func insertComment(_ comment: TTComment, at index: Int) {
        var _comments = commentsRelay.value
        _comments.insert(comment, at: index)
        commentsRelay.accept(_comments)
    }
    
    func updateComment(_ comment: TTComment) {
        var _comments = commentsRelay.value
        if let index = _comments.firstIndex(of: comment) {
            _comments[index] = comment
        }
        commentsRelay.accept(_comments)
    }
    
    func loadComments() {
        commentRepo.getComments(videoId: video.id)
            .trackError(errorTracker, action: .log)
            .trackActivity(loadingIndicator)
            .catchErrorJustComplete()
            .subscribe(with: self, onNext: { viewModel, comments in
                viewModel.commentsRelay.accept(comments)
            })
            .disposed(by: disposeBag)
    }
}
