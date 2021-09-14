//
//  CommentRepo.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 12/09/2021.
//

import RxSwift
import RxCocoa
import Resolver

protocol CommentRepo {
    func getComments(videoId: String) -> Single<[TTComment]>
    func submitComment(video: TTVideo, userId: String, comment: String) -> Single<TTComment>
    func toggleLikeComment(commentId: String, userId: String, isLike: Bool) -> Single<Void>
    func submitReply(comment: String, parentComment: TTComment, userId: String) -> Single<TTComment>
    func getCommentsCount(videoId: String) -> Single<Int>
}

final class CommentRepoImpl: CommentRepo {
    @Injected private var commentService: CommentUseCase
    
    func getComments(videoId: String) -> Single<[TTComment]> {
        return commentService.getComments(videoId: videoId)
    }
    
    func submitComment(video: TTVideo, userId: String, comment: String) -> Single<TTComment> {
        return commentService.submitComment(video: video, userId: userId, comment: comment)
    }
    
    func toggleLikeComment(commentId: String, userId: String, isLike: Bool) -> Single<Void> {
        return commentService.toggleLikeComment(commentId: commentId, userId: userId, isLike: isLike)
    }
    
    func submitReply(comment: String, parentComment: TTComment, userId: String) -> Single<TTComment> {
        return commentService.submitReply(comment: comment, parentComment: parentComment, userId: userId)
    }
    
    func getCommentsCount(videoId: String) -> Single<Int> {
        return getComments(videoId: videoId)
            .map { comments -> Int in
                var count = comments.count
                count += comments.map { $0.replies.count }.reduce(0, +)
                return count
            }
    }
}
