//
//  VideoUploadVC.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 03/09/2021.
//

import UIKit
import RxGesture
import RxSwift

class VideoUploadVC: RxBaseViewController<VideoUploadVM> {
    // MARK: - IBOutlets
    @IBOutlet weak var scvContent: UIScrollView!
    @IBOutlet weak var ivThumbnail: UIImageView!
    @IBOutlet weak var tvDescription: KMPlaceholderTextView!
    @IBOutlet weak var tfTags: UITextField!
    @IBOutlet weak var btnUpload: UIButton!
    
    // MARK: - Variables
    private lazy var mediaPicker = RxMediaPicker(delegate: self)
    
    private let selectedVideoURL = PublishSubject<URL?>()
    private let viewWillAppearTrigger = PublishSubject<Void>()
    
    // MARK: - OVERRIDES
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        bindViewModel()
        bindingUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewWillAppearTrigger.onNext(())
    }
    
    override func setUpColors() {
        view.backgroundColor = AppColors.primaryBackground
        ivThumbnail.tintColor = .white
        tvDescription.textColor = .white
        tvDescription.backgroundColor = AppColors.secondaryBackground
        tvDescription.placeholderColor = AppColors.lightGray
        tfTags.backgroundColor = AppColors.secondaryBackground
        tfTags.textColor = .white
        btnUpload.backgroundColor = AppColors.secondaryBackground
        btnUpload.setTitleColor(.white, for: .normal)
        btnUpload.setTitleColor(.black.withAlphaComponent(0.3), for: .disabled)
    }
    
    // MARK: - Private functions
    private func bindViewModel() {
        let input = Input(viewWillAppearTrigger: viewWillAppearTrigger,
                          selectedVideoURL: selectedVideoURL,
                          videoDescription: tvDescription.rx.text.unwrap().asObservable(),
                          hashTags: tfTags.rx.text.unwrap().asObservable(),
                          uploadTrigger: btnUpload.rx.tap.asObservable())
        let output = viewModel.transform(input: input)
        
        // Selected video's thumbnail
        output.selectedVideoThumbnail
            .do(onNext: { [weak self] image in
                self?.ivThumbnail.contentMode = image == nil ? .center : .scaleAspectFill
            })
            .unwrap()
            .drive(ivThumbnail.rx.image)
            .disposed(by: disposeBag)
        
        // Input validation
        output.isFormValid
            .drive(with: self) { viewController, isValid in
                viewController.btnUpload.isEnabled = isValid
                viewController.btnUpload.backgroundColor = isValid ? AppColors.secondaryBackground : AppColors.lightGray
            }
            .disposed(by: disposeBag)
        
        // Reset data
        output.resetData
            .drive(with: self) { viewController, _ in
                viewController.ivThumbnail.image = R.image.ic_video_60()
                viewController.ivThumbnail.contentMode = .center
                viewController.tvDescription.text = ""
                viewController.tfTags.text = nil
            }
            .disposed(by: disposeBag)
        
        // Error tracker
        viewModel.errorTracker
            .drive(rx.error)
            .disposed(by: disposeBag)
        
        // Loading tracker
        viewModel.loadingIndicator
            .drive(rx.isLoading)
            .disposed(by: disposeBag)
    }
    
    private func bindingUI() {
        // Tap on thumbnail
        ivThumbnail.rx.tapGesture()
            .skip(1)
            .flatMapLatest(weakObj: self, { $0.0.mediaPicker.selectVideo(source: .photoLibrary, maximumDuration: 180) })
            .catchErrorJustComplete()
            .bind(to: selectedVideoURL)
            .disposed(by: disposeBag)
        
        // Scrollview didScroll
        scvContent.rx.didScroll
            .observe(on: MainScheduler.asyncInstance)
            .withLatestFrom(scvContent.rx.contentOffset)
            .map { $0.y > 0 ? AppColors.secondaryBackground : AppColors.primaryBackground }
            .asDriverOnErrorJustComplete()
            .drive(with: self, onNext: { viewController, color in
                viewController.navigationController?.backgroundColor(color)
            })
            .disposed(by: disposeBag)
    }
    
    private func setUpUI() {
        setScreenTitle(Text.videoUploadScreenTitle)
        
        tvDescription.placeholder = Text.descriptionPlaceholder
        let attributedPlaceholder = NSAttributedString(string: Text.hashTagPlaceholder, attributes: [.font: R.font.milliardLight(size: 16)!,
                                                                                                     .foregroundColor: AppColors.lightGray])
        tfTags.attributedPlaceholder = attributedPlaceholder
        
        tvDescription.font = R.font.milliardLight(size: 16)
        tfTags.font = R.font.milliardLight(size: 16)
        btnUpload.titleLabel?.font = R.font.milliardSemiBold(size: 16)
        btnUpload.setTitle(Text.upload, for: .normal)
        btnUpload.setTikTokButtonStyle()
    }
}

// MARK: - Extensions
extension VideoUploadVC: RxMediaPickerDelegate {
    func present(picker: UIImagePickerController) {
        present(picker, animated: true, completion: nil)
    }
    
    func dismiss(picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
