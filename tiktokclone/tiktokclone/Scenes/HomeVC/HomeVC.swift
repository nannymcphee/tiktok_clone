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
    @IBOutlet weak var lbVideoDuration: UILabel!
    
    private lazy var slProgress: UISlider = {
        let slider = UISlider()
        slider.setMinimumTrackImage(UIImage(color: .white), for: .normal)
        slider.setMaximumTrackImage(UIImage(color: AppColors.lightGray), for: .normal)
        slider.setThumbImage(R.image.ic_slider_thumb_8(), for: .normal)
        slider.setThumbImage(R.image.ic_slider_thumb(), for: .highlighted)
        return slider
    }()
    
    private lazy var vHeader: HomeHeaderView = {
        let view = HomeHeaderView(frame: CGRect(x: 0, y: 0,
                                              width: Device.screenWidth,
                                              height: 60))
        return view
    }()
    
    // MARK: - Variables
    private lazy var appDelegate = UIApplication.shared.delegate as? AppDelegate
    private lazy var bottomBarHeight: CGFloat = tabBarHeight
    private var isSeeking: Bool = false
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
        slProgress.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setUpCollectionViewLayout()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        videoPlayer.pauseVideo()
        slProgress.isHidden = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        appDelegate?.appCoordinator.tabBarRouter?.viewController.view.bringSubviewToFront(slProgress)
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
        
        // Play/pause video
        output.playVideo
            .drive(with: self, onNext: { viewController, isPlay in
                guard let cell = viewController.getCurrentVisibleCell() else { return }
                if isPlay {
                    viewController.videoPlayer.playVideo(in: cell)
                } else {
                    viewController.videoPlayer.pauseVideo()
                }
            })
            .disposed(by: disposeBag)
        
        // Update slider value
        output.sliderValueUpdated
            .drive(with: self, onNext: { viewController, data in
                guard viewController.videoPlayer.playingVideo == data.video,
                      viewController.videoPlayer.state == .playing,
                      !viewController.isSeeking else { return }
                viewController.slProgress.value = data.progress
            })
            .disposed(by: disposeBag)
        
        // Played time updated
        output.playedTimeUpdated
            .drive(with: self, onNext: { viewController, data in
                guard viewController.videoPlayer.playingVideo == data.video else { return }
                let currentVideoDurationText = viewController.videoPlayer.currentVideoDurationText
                viewController.lbVideoDuration.text = "\(data.playedTimeText) / \(currentVideoDurationText)"
            })
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
        
        // Begin dragging
        cvVideos.rx.willBeginDragging
            .asDriver()
            .drive(with: self, onNext: { viewController, _ in
                viewController.slProgress.isHidden = true
            })
            .disposed(by: disposeBag)
        
        // Scrolling ended
        Observable.merge(cvVideos.rx.didEndDecelerating.mapToVoid(),
                         cvVideos.rx.didEndScrollingAnimation.mapToVoid())
            .subscribe(with: self) { viewController, _ in
                guard let cell = viewController.getCurrentVisibleCell() else { return }
                if viewController.videoPlayer.playingCell != cell {
                    viewController.slProgress.value = 0
                }
                viewController.slProgress.isHidden = false
                viewController.videoPlayer.playVideo(in: cell)
            }
            .disposed(by: disposeBag)
        
        // Seek video with UISlider
        slProgress.rx.controlEvent(.valueChanged)
            .withLatestFrom(slProgress.rx.value)
            .asDriverOnErrorJustComplete()
            .drive(with: self, onNext: { viewController, value in
                viewController.videoPlayer.seekVideo(with: value)
                viewController.videoPlayer.configureVideoCellWhileSeeking(viewController.slProgress.isTracking)
                viewController.isSeeking = viewController.slProgress.isTracking
                viewController.lbVideoDuration.isHidden = !viewController.slProgress.isTracking
            })
            .disposed(by: disposeBag)
        
        // On pull to refresh
        refreshTrigger
            .subscribe(with: self, onNext: { viewController, _ in
                viewController.videoPlayer.stopAnyOngoingPlaying()
            })
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
        
        lbVideoDuration.font = R.font.milliardBold(size: 28)
        lbVideoDuration.textColor = .white
        lbVideoDuration.isHidden = true
        
        let tabBarVC = appDelegate?.appCoordinator.tabBarRouter?.viewController
        tabBarVC?.view.addSubview(slProgress)
        slProgress.snp.makeConstraints { [weak self] make in
            guard let self = self else { return }
            make.left.equalToSuperview().offset(-1)
            make.right.equalToSuperview().offset(1)
            make.bottom.equalToSuperview().inset(self.tabBarHeight - 4)
        }
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
