//
//  HomeVC.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 03/09/2021.
//

import UIKit
import RxSwift

class HomeVC: RxBaseViewController<HomeVM> {
    // MARK: - IBOutlets
    @IBOutlet weak var cvVideos: UICollectionView!
    @IBOutlet weak var vNavigationContainer: UIView!
    @IBOutlet weak var cvVideosBottomConstraint: NSLayoutConstraint!
    
    private lazy var vHeader: HomeHeaderView = {
        let view = HomeHeaderView(frame: CGRect(x: 0, y: 0,
                                              width: Device.screenWidth,
                                              height: 60))
        return view
    }()
    
    // MARK: - Variables
    private lazy var bottomBarHeight: CGFloat = tabBarHeight
    private let videoPlayer = VideoPlayerManager()
    private let viewDidLoadTrigger = PublishSubject<Void>()
    private let videoCellEventTrigger = PublishSubject<VideoCell.Event>()
    
    // MARK: - OVERRIDES
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setUpCollectionView()
        bindViewModel()
        bindingUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        videoPlayer.resumeVideo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setUpCollectionViewLayout()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        videoPlayer.pauseVideo()
    }
    
    override func setUpColors() {
        super.setUpColors()
        view.backgroundColor = AppColors.primaryBackground
    }
    
    // MARK: - Private functions
    private func bindViewModel() {
        let input = Input(viewDidLoadTrigger: viewDidLoadTrigger,
                          refreshTrigger: refreshTrigger,
                          videoCellEvent: videoCellEventTrigger)
        let output = viewModel.transform(input: input)
        
        // Videos
        output.videos
            .drive(cvVideos.rx.items(cellIdentifier: VideoCell.reuseIdentifier, cellType: VideoCell.self)) { [weak self] _, video, cell in
                guard let self = self else { return }
                cell.populateData(with: video)
                cell.eventPublisher
                    .bind(to: self.videoCellEventTrigger)
                    .disposed(by: self.disposeBag)
            }
            .disposed(by: disposeBag)
        
        // Current playbackState
        output.currenPlayerPlaybackState
            .drive(with: self, onNext: { $0.handlePlaybackState($1) })
            .disposed(by: disposeBag)
        
        // Error tracker
        viewModel.errorTracker
            .drive(rx.error)
            .disposed(by: disposeBag)
        
        // Loading tracker
        viewModel.loadingIndicator
            .drive(refreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)
        
        viewDidLoadTrigger.onNext(())
    }
    
    private func bindingUI() {
        // App enters background
        UIApplication.rx.willResignActive
            .subscribe(with: self) { viewController, _ in
                viewController.videoPlayer.pauseVideo()
            }
            .disposed(by: disposeBag)
        
        // App enters foreground
        UIApplication.rx.didBecomeActive
            .subscribe(with: self) { viewController, _ in
                viewController.videoPlayer.resumeVideo()
            }
            .disposed(by: disposeBag)
        
        // Scrolling ended
        Observable.merge(cvVideos.rx.didEndDecelerating.mapToVoid(),
                         cvVideos.rx.didEndScrollingAnimation.mapToVoid())
            .subscribe(with: self) { viewController, _ in
                guard let cell = viewController.getCurrentVisibleCell() else { return }
                viewController.videoPlayer.playVideo(in: cell)
            }
            .disposed(by: disposeBag)
    }
    
    private func setUpUI() {
        vNavigationContainer.addSubview(vHeader)
        vHeader.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(50)
        }
        
        cvVideosBottomConstraint.constant = bottomBarHeight
        cvVideos.backgroundColor = .clear
        view.backgroundColor = AppColors.primaryBackground
    }
    
    private func setUpCollectionView() {
        cvVideos.registerNib(VideoCell.self)
        cvVideos.refreshControl = refreshControl
        cvVideos.isPagingEnabled = true
    }
    
    private func setUpCollectionViewLayout() {
        if let layout = cvVideos.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
            layout.sectionInset = .zero
            layout.itemSize = cvVideos.bounds.size
        }
    }
    
    private func getCurrentVisibleCell() -> VideoCell? {
        let visibleRect = CGRect(origin: cvVideos.contentOffset, size: cvVideos.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        
        guard let visibleIndexPath = cvVideos.indexPathForItem(at: visiblePoint) else {
            return nil
        }
        
        return cvVideos.cellForItem(at: visibleIndexPath) as? VideoCell
    }
    
    
    private func handlePlaybackState(_ state: VideoPlayerView.PlayerPlaybackState) {
        if case .finished = state {
            videoPlayer.replayVideo()
        }
    }
}
