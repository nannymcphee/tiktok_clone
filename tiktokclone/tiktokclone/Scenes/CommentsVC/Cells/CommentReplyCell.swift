//
//  CommentReplyCell.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 14/09/2021.
//

import UIKit
import RxSwift
import RxCocoa

class CommentReplyCell: TableViewCell {

    @IBOutlet weak var vContent: UIView!
    @IBOutlet weak var ivAvatar: UIImageView!
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var lbUsername: UILabel!
    @IBOutlet weak var lbComment: UILabel!
    @IBOutlet weak var lbTime: UILabel!
    @IBOutlet weak var lbReply: UILabel!
    
    private var isLiked: Bool = false
    private var viewModel: CommentCellVM!
    
    static var kEstimatedCellHeight: CGFloat = 73
    let eventPublisher = PublishSubject<CommentCell.Event>()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ivAvatar.setRounded()
        lbUsername.font = R.font.milliardSemiBold(size: 12)
        lbComment.font = R.font.milliardLight(size: 14)
        lbTime.font = R.font.milliardLight(size: 12)
        lbReply.font = R.font.milliardSemiBold(size: 12)
        btnLike.titleLabel?.font = R.font.milliardLight(size: 14)
        btnLike.titleLabel?.textAlignment = .center
        
        [lbUsername, lbTime, lbReply].forEach { $0?.textColor = AppColors.secondaryText }
        lbComment.textColor = AppColors.primaryText
        btnLike.setTitleColor(AppColors.secondaryText, for: .normal)
        btnLike.tintColor = AppColors.secondaryText
        
        lbReply.text = Text.reply
    }
    
    override func reset() {
        ivAvatar.image = nil
        lbUsername.text = nil
        lbComment.text = nil
        lbTime.text = nil
        isLiked = false
        super.reset()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func populateData(with data: TTComment) {
        viewModel = CommentCellVM()
        let input = CommentCellVM.Input(comment: data)
        let output = viewModel.transform(input: input)
        
        // User's avatar
        output.userInfo
            .drive(with: self, onNext: { viewController, user in
                viewController.ivAvatar.setImage(url: user.profileImage, placeholder: R.image.ic_avatar_placeholder())
                viewController.lbUsername.text = user.username
            })
            .disposed(by: disposeBag)
        
        // Comment
        output.comment
            .drive(with: self, onNext: { cell, comment in
                cell.lbComment.text = comment
                let labelSize = comment.labelSize(font: R.font.milliardLight(size: 14)!, considering: cell.bounds.width)
                cell.lbComment.changeHeight(to: labelSize.height)
                cell.layoutIfNeeded()
            })
            .disposed(by: disposeBag)
        
        // Like count
        output.likeCount
            .map { "\($0)" }
            .drive(with: self, onNext: {
                $0.btnLike.setTitle($1, for: .normal)
                $0.btnLike.alignImageAndTitleVertically(padding: 4)
            })
            .disposed(by: disposeBag)
        
        // Is liked
        output.isLiked
            .drive(with: self, onNext: { cell, isLiked in
                let image = isLiked ? UIImage.init(systemName: "heart.filled") : UIImage.init(systemName: "heart")
                let tintColor = isLiked ? AppColors.red : AppColors.secondaryText
                cell.btnLike.setImage(image, for: .normal)
                cell.btnLike.tintColor = tintColor
                cell.btnLike.alignImageAndTitleVertically(padding: 4)
                cell.isLiked = isLiked
            })
            .disposed(by: disposeBag)
        
        // Comment time
        output.commentTime
            .drive(lbTime.rx.text)
            .disposed(by: disposeBag)
        
        bindingUI()
    }
    
    // MARK: - Private functions
    private func bindingUI() {
        // Avatar & username tap
        Observable.merge(ivAvatar.rx.tapGesture().when(.recognized).mapToVoid(),
                         lbUsername.rx.tapGesture().when(.recognized).mapToVoid())
            .withLatestFrom(viewModel.commentAuthorObservable)
            .map { CommentCell.Event.didTapAvatar($0) }
            .bind(to: eventPublisher)
            .disposed(by: disposeBag)
        
        // Like tap
        btnLike.rx.tap
            .withLatestFrom(Observable.just(isLiked))
            .do(onNext: { [weak self] isLiked in
                self?.viewModel.updateLikeStatus(isLiked: isLiked)
            })
            .zip(with: viewModel.commentObservable) { isLiked, comment in
                return (comment: comment, isLike: isLiked)
            }
            .map { CommentCell.Event.toggleLikeComment((comment: $0.comment, isLike: $0.isLike)) }
            .bind(to: eventPublisher)
            .disposed(by: disposeBag)
        
        let commentData = Observable.zip(viewModel.commentObservable,
                                         viewModel.commentAuthorObservable)
        
        // Reply tap
        Observable.merge(lbReply.rx.tapGesture().when(.recognized),
                         rx.tapGesture(configuration: { [weak self] gesture, delegate in
                            guard let self = self else { return }
                            delegate.otherFailureRequirementPolicy = .custom { gesture, otherGesture in
                                return otherGesture is UITapGestureRecognizer && (otherGesture.view == self.ivAvatar || otherGesture.view == self.lbUsername)
                            }
                         }).when(.recognized))
            .withLatestFrom(commentData)
            .map { CommentCell.Event.didTapReply($0) }
            .bind(to: eventPublisher)
            .disposed(by: disposeBag)
    }
}
