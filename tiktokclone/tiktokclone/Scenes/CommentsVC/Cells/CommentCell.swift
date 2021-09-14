//
//  CommentCell.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 12/09/2021.
//

import UIKit
import RxSwift
import RxCocoa

class CommentCell: TableViewCell {
    @IBOutlet weak var ivAvatar: UIImageView!
    @IBOutlet weak var lbUsername: UILabel!
    @IBOutlet weak var lbComment: UILabel!
    @IBOutlet weak var lbTime: UILabel!
    @IBOutlet weak var lbReply: UILabel!
    @IBOutlet weak var lbLikedByOwner: PaddingLabel!
    @IBOutlet weak var btnViewReply: UIButton!
    @IBOutlet weak var tbReply: UITableView!
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var svContent: UIStackView!
    @IBOutlet weak var btnCollapseReply: UIButton!
    @IBOutlet weak var vExpandCollapseReply: UIView!
    @IBOutlet weak var vReplyContainerTopConstraint: NSLayoutConstraint!
    
    // MARK: - Events
    enum Event {
        case didTapAvatar(TTUser)
        case toggleLikeComment((comment: TTComment, isLike: Bool))
        case didTapReply((comment: TTComment, user: TTUser))
        case expandCollapseReply((cell: CommentCell, isExpand: Bool))
    }
    
    static var kEstimatedCellHeight: CGFloat = 106
    let eventPublisher = PublishSubject<Event>()

    private var viewModel: CommentCellVM!
    private var isLiked: Bool = false
    
    private let replyContentHeightRelay = BehaviorRelay<CGFloat>(value: 0)
    
    // MARK: - Overrides
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpUI()
        setUpReplyTableView()
        setDefaultReplyState()
    }
    
    override func reset() {
        ivAvatar.image = nil
        lbUsername.text = nil
        lbComment.text = nil
        lbTime.text = nil
        isLiked = false
        setDefaultReplyState()
        super.reset()
    }
    
    // MARK: - Public functions
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
        
        // Is liked by author
        output.isLikedByOwner
            .map { !$0 }
            .drive(lbLikedByOwner.rx.isHidden)
            .disposed(by: disposeBag)
        
        // Comment time
        output.commentTime
            .drive(lbTime.rx.text)
            .disposed(by: disposeBag)
        
        // Replies
        output.replies
            .do(onNext: { [weak self] replies in
                let height: CGFloat = replies.isEmpty ? 0 : 20
                self?.vExpandCollapseReply.changeHeight(to: height)
                self?.vExpandCollapseReply.isHidden = replies.isEmpty
                self?.vReplyContainerTopConstraint.constant = replies.isEmpty ? 0 : 10
                self?.btnViewReply.setTitle(Text.viewReplies + " (\(replies.count)) ", for: .normal)
            })
            .drive(tbReply.rx.items(cellIdentifier: CommentReplyCell.reuseIdentifier, cellType: CommentReplyCell.self)) { [weak self] _, model, cell in
                guard let self = self else { return }
                cell.populateData(with: model)
                cell.eventPublisher
                    .subscribe(onNext: { event in
                        switch event {
                        case .didTapAvatar(let user):
                            self.eventPublisher.onNext(.didTapAvatar(user))
                        case let .didTapReply((_, user)):
                            guard let parentComment = self.viewModel.comment else { return }
                            self.eventPublisher.onNext(.didTapReply((comment: parentComment, user: user)))
                        case let .toggleLikeComment((comment, isLike)):
                            Logger.d("toggleLikeComment \(comment), isLike: \(isLike)")
                        default:
                            break
                        }
                    })
                    .disposed(by: self.disposeBag)
            }
            .disposed(by: disposeBag)
        
        bindingUI()
    }
    
    func expandCollapseReply(isExpand: Bool, animated: Bool = true) {
        if !animated { UIView.setAnimationsEnabled(false) }
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            guard let self = self else { return }
            let tbReplyHeight = isExpand ? self.replyContentHeightRelay.value : 0
            self.tbReply.isHidden = !isExpand
            self.tbReply.changeHeight(to: tbReplyHeight)
            self.vReplyContainerTopConstraint.priority = isExpand ? UILayoutPriority(1000) : UILayoutPriority(750)
            if isExpand {
                self.btnCollapseReply.alpha = 1
                self.btnViewReply.alpha = 0
                self.tbReply.isHidden = false
                self.btnCollapseReply.isHidden = false
            }
            self.layoutIfNeeded()
        }, completion: { [weak self] _ in
            if !isExpand {
                self?.btnCollapseReply.alpha = 0
                self?.btnViewReply.alpha = 1
                self?.tbReply.isHidden = true
                self?.btnCollapseReply.isHidden = true
                self?.vReplyContainerTopConstraint.priority = UILayoutPriority(1000)
            }
        })
        if !animated { UIView.setAnimationsEnabled(true) }
    }
    
    // MARK: - Private functions
    private func bindingUI() {
        // Avatar & username tap
        Observable.merge(ivAvatar.rx.tapGesture().when(.recognized).mapToVoid(),
                         lbUsername.rx.tapGesture().when(.recognized).mapToVoid())
            .withLatestFrom(viewModel.commentAuthorObservable)
            .map { Event.didTapAvatar($0) }
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
            .map { Event.toggleLikeComment((comment: $0.comment, isLike: $0.isLike)) }
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
            .map { Event.didTapReply($0) }
            .bind(to: eventPublisher)
            .disposed(by: disposeBag)
        
        // Reply contentSize observer
        tbReply.rx.observe(\.contentSize)
            .subscribe(on: MainScheduler.asyncInstance)
            .map { $0.height }
            .bind(to: replyContentHeightRelay)
            .disposed(by: disposeBag)
        
        // Expand reply
        btnViewReply.rx.tap
            .map { Event.expandCollapseReply((self, true)) }
            .bind(to: eventPublisher)
            .disposed(by: disposeBag)
        
        // Collapse reply
        btnCollapseReply.rx.tap
            .map { Event.expandCollapseReply((self, false)) }
            .bind(to: eventPublisher)
            .disposed(by: disposeBag)
    }
    
    private func setUpUI() {
        ivAvatar.setRounded()
        lbUsername.font = R.font.milliardSemiBold(size: 12)
        lbComment.font = R.font.milliardLight(size: 14)
        lbTime.font = R.font.milliardLight(size: 12)
        lbReply.font = R.font.milliardSemiBold(size: 12)
        lbLikedByOwner.font = R.font.milliardSemiBold(size: 11)
        btnLike.titleLabel?.font = R.font.milliardLight(size: 14)
        btnLike.titleLabel?.textAlignment = .center
        btnViewReply.titleLabel?.font = R.font.milliardSemiBold(size: 12)
        btnViewReply.semanticContentAttribute = .forceRightToLeft
        btnCollapseReply.titleLabel?.font = R.font.milliardSemiBold(size: 14)
        btnCollapseReply.semanticContentAttribute = .forceRightToLeft
        btnCollapseReply.tintColor = AppColors.secondaryText
        btnCollapseReply.alpha = 0
        
        [lbUsername, lbTime, lbReply].forEach { $0?.textColor = AppColors.secondaryText }
        lbComment.textColor = AppColors.primaryText
        btnViewReply.tintColor = AppColors.secondaryText
        btnViewReply.setTitleColor(AppColors.secondaryText, for: .normal)
        btnLike.setTitleColor(AppColors.secondaryText, for: .normal)
        btnLike.tintColor = AppColors.secondaryText
        
        btnCollapseReply.setTitle("\(Text.hide) ", for: .normal)
        lbReply.text = Text.reply
        lbLikedByOwner.text = Text.likedByAuthor
        lbLikedByOwner.textInsets = UIEdgeInsets(all: 4)
        lbLikedByOwner.setTikTokButtonStyle()
        lbLikedByOwner.backgroundColor = AppColors.secondaryBackground
        lbLikedByOwner.textColor = AppColors.lightGray
    }
    
    private func setUpReplyTableView() {
        tbReply.registerNib(CommentReplyCell.self)
        tbReply.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        tbReply.rowHeight = UITableView.automaticDimension
        tbReply.estimatedRowHeight = CommentReplyCell.kEstimatedCellHeight
    }
    
    private func setDefaultReplyState() {
        btnCollapseReply.alpha = 0
        btnViewReply.alpha = 1
        tbReply.isHidden = true
        btnCollapseReply.isHidden = true
        tbReply.isHidden = true
        tbReply.changeHeight(to: 0)
        vReplyContainerTopConstraint.priority = UILayoutPriority(1000)
        layoutIfNeeded()
    }
}
