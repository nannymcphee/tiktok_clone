//
//  CommentUseCase.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 12/09/2021.
//

import RxSwift
import FirebaseFirestore
import Resolver

protocol CommentUseCase {
    func getComments(videoId: String) -> Single<[TTComment]>
    func submitComment(video: TTVideo, userId: String, comment: String) -> Single<TTComment>
    func toggleLikeComment(commentId: String, userId: String, isLike: Bool) -> Single<Void>
    func submitReply(comment: String, parentComment: TTComment, userId: String) -> Single<TTComment>
}

final class CommentUseCaseImpl: CommentUseCase {
    private lazy var db = Firestore.firestore().collection(DatabaseTable.comments.rawValue)
    
    func getComments(videoId: String) -> Single<[TTComment]> {
        .create { [weak self] single in
            guard let self = self else { return Disposables.create() }
            
            self.db
                .whereField("video_id", isEqualTo: videoId)
                .order(by: "created_at", descending: true)
                .getDocuments { snapshot, error in
                    if let error = error {
                        single(.failure(error))
                    }
                    
                    if let snapshot = snapshot {
                        let comments = snapshot.documents.map { TTComment(dictionary: $0.data()) }
                        single(.success(comments))
                    }
                }
            
            return Disposables.create()
        }
    }
    
    func submitComment(video: TTVideo, userId: String, comment: String) -> Single<TTComment> {
        .create { [weak self] single in
            guard let self = self else { return Disposables.create() }
            
            let dbRef = self.db.document()
            var comment = TTComment(videoId: video.id,
                                    videoOwnerId: video.ownerId,
                                    ownerId: userId,
                                    comment: comment)
            comment.id = dbRef.documentID
            comment.createdAt = Int(Date().timeIntervalSince1970)
            
            dbRef.setData(comment.asDictionary(), completion: { error in
                guard let error = error else {
                    single(.success(comment))
                    return
                }
                single(.failure(error))
            })
            return Disposables.create()
        }
    }
    
    func toggleLikeComment(commentId: String, userId: String, isLike: Bool) -> Single<Void> {
        .create { [weak self] single in
            guard let self = self else { return Disposables.create() }
            
            let fields: [String: Any] = [
                "liked_ids": isLike ? FieldValue.arrayUnion([userId]) : FieldValue.arrayRemove([userId]),
            ]
            
            self.db.document(commentId)
                .updateData(fields) { error in
                    guard let error = error else {
                        single(.success(()))
                        return
                    }
                    
                    single(.failure(error))
                }
            
            return Disposables.create()
        }
    }
    
    func submitReply(comment: String, parentComment: TTComment, userId: String) -> Single<TTComment> {
        .create { [weak self] single in
            guard let self = self else { return Disposables.create() }
            
            let dbRef = self.db.document(parentComment.id)
            var comment = TTComment(videoId: parentComment.videoId,
                                    videoOwnerId: parentComment.videoOwnerId,
                                    ownerId: userId,
                                    comment: comment)
            comment.id = UUID().uuidString
            comment.createdAt = Int(Date().timeIntervalSince1970)
            
            dbRef.updateData(["replies": FieldValue.arrayUnion([comment.asDictionary()])], completion: { error in
                guard let error = error else {
                    var updatedComment = parentComment
                    updatedComment.replies.append(comment)
                    single(.success(updatedComment))
                    return
                }
                single(.failure(error))
            })
            return Disposables.create()
        }
    }
}
