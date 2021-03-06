//
//  VideoUseCase.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 04/09/2021.
//

import UIKit
import RxSwift
import FirebaseFirestore
import Resolver

protocol VideoUseCase {
    func saveVideo(_ video: TTVideo) -> Single<Void>
    func getVideos() -> Single<[TTVideo]>
}

final class VideoUseCaseImpl: VideoUseCase {
    @Injected private var userRepo: UserRepo
    private lazy var dbVideo = Firestore.firestore().collection("Videos")
    private var currentUserId: String? {
        userRepo.currentUser?.id
    }
    
    func saveVideo(_ video: TTVideo) -> Single<Void> {
        .create { [weak self] single in
            guard let self = self else { return Disposables.create() }
            
            let dbRef = self.dbVideo.document()
            var _video = video
            _video.id = dbRef.documentID
            _video.createdAt = Int(Date().timeIntervalSince1970)
            
            dbRef.setData(_video.asDictionary(), completion: { error in
                guard let error = error else {
                    single(.success(()))
                    return
                }
                single(.failure(error))
            })
            return Disposables.create()
        }
    }
    
    func getVideos() -> Single<[TTVideo]> {
        return .create { [weak self] single in
            guard let self = self else { return Disposables.create() }
            
            self.dbVideo
                .order(by: "created_at", descending: true)
                .getDocuments { snapshot, error in
                    if let error = error {
                        single(.failure(error))
                    }
                    
                    if let snapshot = snapshot {
                        let videos = snapshot.documents.map { TTVideo(dictionary: $0.data()) }
                        single(.success(videos))
                    }
                }
            
            return Disposables.create()
        }
    }
}
