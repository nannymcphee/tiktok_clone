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
    case invalidUserId
}

protocol VideoRepo {
    func uploadVideo(_ video: TTVideo) -> Single<Void>
    func getVideos() -> Single<[TTVideo]>
    func toggleLikeVideo(videoId: String, userId: String, isLike: Bool) -> Single<Void>
}

final class VideoRepoImpl: VideoRepo {
    @Injected private var storageService: StorageUseCase
    @Injected private var videoService: VideoUseCase
    
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
    
    func getVideos() -> Single<[TTVideo]> {
        return videoService.getVideos()
    }
    
    func toggleLikeVideo(videoId: String, userId: String, isLike: Bool) -> Single<Void> {
        return videoService.toggleLikeVideo(videoId: videoId, userId: userId, isLike: isLike)
    }
}

class VideoRepoMock: VideoRepo {
    func uploadVideo(_ video: TTVideo) -> Single<Void> {
        return .just(())
    }
    
    func getVideos() -> Single<[TTVideo]> {
        guard let mockVideos = [TTVideo].mock(from: "mock_get_videos_data") else { return .just([]) }
        return Single.just(mockVideos)
    }
    
    func toggleLikeVideo(videoId: String, userId: String, isLike: Bool) -> Single<Void> {
        return .just(())
    }
}

extension Decodable {
    static func mock(from jsonFile: String) -> Self? {
        guard let path = Bundle.main.path(forResource: jsonFile, ofType: "json"),
              let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
        else {
            return nil
        }
        return try? JSONDecoder().decode(WrappedBaseResult<Self>.self, from: jsonData).data
    }
}

struct WrappedBaseResult<T: Decodable>: Decodable {
    let data: T?
    
    enum CodingKeys: String, CodingKey {
        case data = "data"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        data = try? values.decodeIfPresent(T.self, forKey: .data)
    }
}
