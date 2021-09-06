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
    
    private lazy var vHeader: HomeHeaderView = {
        let view = HomeHeaderView(frame: CGRect(x: 0, y: 0,
                                              width: Device.screenWidth,
                                              height: 60))
        return view
    }()
    
    // MARK: - Variables
    private let videoPlayer = VideoPlayerManager()
    private let viewDidLoadTrigger = PublishSubject<Void>()
    
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
                          refreshTrigger: refreshTrigger)
        let output = viewModel.transform(input: input)
        
        // Videos
        output.videos
            .drive(cvVideos.rx.items(cellIdentifier: VideoCell.reuseIdentifier, cellType: VideoCell.self)) { [weak self] _, video, cell in
                guard let self = self else { return }
                cell.populateData(with: video, tabBarHeight: self.tabBarHeight)
                cell.eventPublisher
                    .asDriverOnErrorJustComplete()
                    .drive(onNext: { event in
                        switch event {
                        case .didTapAvatar(let user):
                            Logger.d("didTapAvatar \(user)")
                        case .didTapFollow(let user):
                            Logger.d("didTapFollow \(user)")
                        case .didTapLike(let video):
                            Logger.d("didTapLike \(video)")
                        case .didTapComment(let video):
                            Logger.d("didTapComment \(video)")
                        case .didTapShare(let video):
                            Logger.d("didTapShare \(video)")
                        case .didTapMore(let video):
                            Logger.d("didTapMore \(video)")
                        }
                    })
                    .disposed(by: self.disposeBag)
            }
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
        
        // Begin scrolling
        cvVideos.rx.didScroll
            .subscribe(with: self) { viewController, _ in
                viewController.videoPlayer.pauseVideo()
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
}
