//
//  HomeVMTest.swift
//  tiktokcloneTests
//
//  Created by Duy Nguyen on 23/10/2021.
//

import XCTest
import RxTest
import RxBlocking
import RxSwift
import RxCocoa
import Resolver
@testable import tiktokclone

class HomeVMTest: XCTestCase {
    private var viewModel: HomeVM?
    private var input: HomeVM.Input!
    private var output: HomeVM.Output!
    private var scheduler: TestScheduler!
    private var disposeBag = DisposeBag()
    
    @Injected private var videoRepoMock: VideoRepo
    
    private let viewDidLoadTrigger = PublishSubject<Void>()
    private let refreshTrigger = PublishSubject<Void>()
    private let videoCellEventTrigger = PublishSubject<VideoCell.Event>()
    
    override func setUp() {
        super.setUp()
        scheduler = TestScheduler(initialClock: 0)
        viewModel = HomeVM()
        input = HomeVM.Input(viewDidLoadTrigger: viewDidLoadTrigger,
                             refreshTrigger: refreshTrigger,
                             videoCellEvent: videoCellEventTrigger)
        output = viewModel?.transform(input: input)
    }
    
    override func tearDown() {
        super.tearDown()
        viewModel = nil
    }
    
    func test_homeViewModel_init() {
        XCTAssertNotNil(viewModel)
    }
    
    func test_input_init() {
        XCTAssertNotNil(input)
    }
    
    func test_output_init() {
        XCTAssertNotNil(output)
    }
    
    func test_viewDidLoadTrigger_loadVideos() {
        let videos = scheduler.createObserver([TTVideo].self)
        let expectedVideosRelay = BehaviorRelay<[TTVideo]>(value: [])
        videoRepoMock.getVideos().asObservable()
            .bind(to: expectedVideosRelay)
            .disposed(by: disposeBag)

        output.videos
            .drive(videos)
            .disposed(by: disposeBag)

        scheduler.createHotObservable([.next(10, ())])
            .bind(to: viewDidLoadTrigger)
            .disposed(by: disposeBag)

        scheduler.start()
        
        /**
         - First event at `0` is [] because we're binding output.videos to a BehaviorRelay,
         which always emit its initial value as first `onNext` event
         - Second event is the `.next(10)` that we binded to `viewDidLoadTrigger`,
         and it should be equal to the `.next(10)` event of  `expectedVideosRelay`
         */
        XCTAssertEqual(videos.events, [.next(0, []),
                                       .next(10, expectedVideosRelay.value)])
    }
    
    func test_refreshTrigger_reloadVideos() {
        let videos = scheduler.createObserver([TTVideo].self)
        let expectedVideosRelay = BehaviorRelay<[TTVideo]>(value: [])
        videoRepoMock.getVideos().asObservable()
            .bind(to: expectedVideosRelay)
            .disposed(by: disposeBag)
        
        output.videos
            .drive(videos)
            .disposed(by: disposeBag)
        
        scheduler.createHotObservable([.next(10, ())])
            .bind(to: refreshTrigger)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(videos.events, [.next(0, []),
                                       .next(10, expectedVideosRelay.value)])
    }
    
    func test_viewDidLoadTrigger_loadVideos_usingRxBlocking() {
        let expected = [TTVideo].mock(from: "mock_get_videos_data") ?? []

        viewDidLoadTrigger.onNext(())

        do {
            guard let result = try output.videos.toBlocking().first() else {
                XCTFail("Result is nil")
                return
            }
            XCTAssertEqual(result, expected)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
