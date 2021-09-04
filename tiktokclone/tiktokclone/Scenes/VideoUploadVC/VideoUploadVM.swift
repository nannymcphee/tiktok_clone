//
//  VideoUploadVM.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 04/09/2021.
//

import RxSwift
import RxCocoa
import Resolver

final class VideoUploadVM: BaseVM, ViewModelTransformable, ViewModelTrackable, EventPublisherType {
    // MARK: - Input
    struct Input {
        let selectedVideoURL: Observable<URL?>
        let videoDescription: Observable<String>
        let hashTags: Observable<String>
        let uploadTrigger: Observable<Void>
    }
    
    // MARK: - Output
    struct Output {
        let selectedVideoThumbnail: Driver<UIImage?>
        let isFormValid: Driver<Bool>
        let resetData: Driver<Void>
    }
    
    // MARK: - Event
    enum Event {
        case uploadVideoSuccess
    }
    
    // MARK: - Variables
    let eventPublisher = PublishSubject<Event>()
    let loadingIndicator = ActivityIndicator()
    let errorTracker = ErrorTracker()
    
    @Injected private var thumbnailGenerator: VideoThumbnailGenerator
    @Injected private var videoRepo: VideoRepo
    @Injected private var userRepo: UserRepo
    
    private let videoThumbnailRelay = BehaviorRelay<UIImage?>(value: nil)
    private let videoUrlRelay = BehaviorRelay<URL?>(value: nil)
    private let descriptionRelay = BehaviorRelay<String>(value: "")
    private let hashTagsRelay = BehaviorRelay<[String]>(value: [])
    private let formValidRelay = BehaviorRelay<Bool>(value: false)
    private let selectedVideoRelay = BehaviorRelay<TTVideo?>(value: nil)
    private let resetDataSubject = PublishSubject<Void>()
    
    // MARK: - Public functions
    func transform(input: Input) -> Output {
        // Process selected video
        input.selectedVideoURL
            .unwrap()
            .flatMap(weakObj: self, { viewModel, url -> Observable<(url: URL, thumbnail: UIImage)> in
                return viewModel.thumbnailGenerator
                    .getThumbnailFromVideo(url)
                    .map { (url: url, thumbnail: $0) }
                    .trackError(viewModel.errorTracker, action: .alert)
                    .trackActivity(viewModel.loadingIndicator)
                    .catchErrorJustComplete()
            })
            .subscribe(with: self, onNext: { viewModel, data in
                viewModel.videoThumbnailRelay.accept(data.thumbnail)
                viewModel.videoUrlRelay.accept(data.url)
            })
            .disposed(by: disposeBag)
        
        // Inputted value
        let uploadVideoInfo = Observable.combineLatest(input.selectedVideoURL,
                                                       input.videoDescription,
                                                       input.hashTags)
            .share()
        
        // Validate input
        uploadVideoInfo
            .map { data in
                return data.0 != nil && !data.1.isEmpty && !data.2.isEmpty
            }
            .bind(to: formValidRelay)
            .disposed(by: disposeBag)
        
        // Process video info
        uploadVideoInfo
            .withUnretained(self)
            .compactMap { viewModel, data -> TTVideo? in
                guard let userId = viewModel.userRepo.currentUser?.id else { return nil }
                let hashTags = data.2
                    .replacingOccurrences(of: " ", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .components(separatedBy: ",")
                return TTVideo(description: data.1,
                               tags: hashTags,
                               videoURL: data.0,
                               thumbnailImage: viewModel.videoThumbnailRelay.value,
                               ownerId: userId)
            }
            .bind(to: selectedVideoRelay)
            .disposed(by: disposeBag)

        // Upload video
        input.uploadTrigger
            .withLatestFrom(selectedVideoRelay.unwrap())
            .flatMap(weakObj: self, {
                $0.0.videoRepo.uploadVideo($0.1)
                    .trackError($0.0.errorTracker, action: .alert)
                    .trackActivity($0.0.loadingIndicator)
                    .catchErrorJustComplete()
            })
            .map { Event.uploadVideoSuccess }
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: eventPublisher)
            .disposed(by: disposeBag)
        
        return Output(selectedVideoThumbnail: videoThumbnailRelay.asDriverOnErrorJustComplete(),
                      isFormValid: formValidRelay.asDriverOnErrorJustComplete(),
                      resetData: resetDataSubject.asDriverOnErrorJustComplete())
    }
    
    func resetData() {
        videoThumbnailRelay.accept(nil)
        formValidRelay.accept(false)
        resetDataSubject.onNext(())
    }
}
