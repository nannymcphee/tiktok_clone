//
//  VideoRepo.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 04/09/2021.
//

import RxSwift
import RxCocoa
import Resolver

enum VideoUploadError: Error {
    case invalidVideo
}

protocol VideoRepo {
    func uploadVideo(_ video: TTVideo) -> Single<Void>
}

final class VideoRepoImpl: VideoRepo {
    @Injected private var userRepo: UserRepo
    @Injected private var storageService: StorageUseCase
    @Injected private var videoService: VideoUseCase

    private var currentUserId: String? {
        return userRepo.currentUser?.id
    }
    
    func uploadVideo(_ video: TTVideo) -> Single<Void> {
        guard let videoURL = video.selectedVideoURL,
              let thumbnailImage = video.videoThumbnail else {
            return .error(VideoUploadError.invalidVideo)
        }
        
        let videoUploadTask = storageService.uploadVideo(url: videoURL)
        let thumbnailUploadTask = storageService.uploadImage(image: thumbnailImage)
        
        return Single.zip(videoUploadTask, thumbnailUploadTask)
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .map { data -> TTVideo in
                var updatedVideo = video
                updatedVideo.videoURL = data.0
                updatedVideo.thumbnailURL = data.1
                updatedVideo.selectedVideoURL = nil
                updatedVideo.videoThumbnail = nil
                return updatedVideo
            }
            .flatMap { [weak self] video -> Single<Void> in
                guard let self = self else { return .error(VideoUploadError.invalidVideo) }
                return self.videoService.saveVideo(video)
            }
    }
}
