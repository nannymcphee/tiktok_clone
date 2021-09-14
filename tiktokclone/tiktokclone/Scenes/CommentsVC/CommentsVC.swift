//
//  CommentsVC.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 11/09/2021.
//

import UIKit
import FittedSheets
import ISEmojiView
import RxSwift
import RxCocoa

enum PickerViewType {
    case emoji
    case none
}

class CommentsVC: RxBaseViewController<CommentsVM> {
    // MARK: - IBOutlets
    @IBOutlet weak var vContent: UIView!
    @IBOutlet weak var lbScreenTitle: UILabel!
    @IBOutlet weak var btnDismiss: UIButton!
    @IBOutlet weak var tbComments: UITableView!
    @IBOutlet weak var vBottom: UIView!
    @IBOutlet weak var vInputContainer: UIView!
    @IBOutlet weak var ivAvatar: UIImageView!
    @IBOutlet weak var vTextFieldContainer: UIView!
    @IBOutlet weak var tvComment: KMPlaceholderTextView!
    @IBOutlet weak var btnMention: UIButton!
    @IBOutlet weak var btnEmoji: UIButton!
    @IBOutlet weak var btnAsk: UIButton!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var vBottomBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var vInputContainerTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var vEmojiKeyboardContainer: UIView!
    
    private lazy var vBackground: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0,
                                        width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        view.backgroundColor = .black.withAlphaComponent(0.45)
        view.isHidden = true
        return view
    }()
    
    // MARK: - Variables
    private let kDefaultInputRightPadding: CGFloat = 15
    private let kButtonSendWidth: CGFloat = 30
    private let kTextViewDefaultHeight: CGFloat = 40
    private let kTextViewMaxHeight: CGFloat = 150
    private let kCommentCharactersLimit: Int = 300
    
    private let viewDidLoadTrigger = PublishSubject<Void>()
    private let toggleLikeCommentTrigger = PublishSubject<(comment: TTComment, isLike: Bool)>()
    private let commentCellEventTrigger = PublishSubject<CommentCell.Event>()

    private var didAnimateSendButton: Bool = false
    private var replyingComment: TTComment?
    private var currentPickerView: PickerViewType = .none
    private var sheetVC: SheetViewController? {
        return parent?.parent as? SheetViewController
    }
    
    // MARK: - OVERRIDES
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setUpTableView()
        setUpEmojiPicker()
        setUpInputAccessoryView()
        insertBackgroundView()
        bindViewModel()
        bindingUI()
    }
    
    // MARK: - Private functions
    private func bindViewModel() {
        let input = Input(viewDidLoadTrigger: viewDidLoadTrigger,
                          dismissTrigger: btnDismiss.rx.tap.mapToVoid(),
                          submitCommentTrigger: btnSend.rx.tap.mapToVoid().asObservable(),
                          commentText: tvComment.rx.text.unwrap().asObservable(),
                          toggleLikeCommentTrigger: toggleLikeCommentTrigger,
                          commentCellEvent: commentCellEventTrigger)
        let output = viewModel.transform(input: input)
        
        // Comments
        output.comments
            .drive(tbComments.rx.items(cellIdentifier: CommentCell.reuseIdentifier, cellType: CommentCell.self)) { [weak self] _, model, cell in
                guard let self = self else { return }
                cell.populateData(with: model)
                cell.eventPublisher
                    .bind(to: self.commentCellEventTrigger)
                    .disposed(by: self.disposeBag)
            }
            .disposed(by: disposeBag)
        
        // User's avatar
        output.userAvatar
            .drive(with: self, onNext: { viewController, url in
                viewController.ivAvatar.setImage(url: url, placeholder: R.image.ic_avatar_placeholder())
            })
            .disposed(by: disposeBag)
        
        // Comments count
        output.commentCount
            .drive(lbScreenTitle.rx.text)
            .disposed(by: disposeBag)
        
        // Reply comment
        output.replyComment
            .drive(with: self, onNext: { $0.configureReplyUI(user: $1.user) })
            .disposed(by: disposeBag)
        
        // Error tracker
        viewModel.errorTracker
            .drive(rx.error)
            .disposed(by: disposeBag)
        
        // Loading tracker
        viewModel.loadingIndicator
            .drive(rx.isLoading)
            .disposed(by: disposeBag)
        
        viewDidLoadTrigger.onNext(())
    }
    
    private func bindingUI() {
        // Keyboard height observer
        keyboardHeight()
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self, onNext: { viewController, data in
                viewController.onKeyboardHeightChanged(data.height, notification: data.notification)
            })
            .disposed(by: disposeBag)
        
        // Tap to dismiss keyboard
        vBackground.rx.tapGesture()
        .when(.recognized)
        .asDriverOnErrorJustComplete()
        .drive(with: self, onNext: { viewController, _ in
            viewController.dismissInputView()
        })
        .disposed(by: disposeBag)

        // TextView focused
        tvComment.rx.didBeginEditing
            .asDriver()
            .drive(with: self, onNext: { viewController, _ in
                viewController.currentPickerView = .none
                viewController.sheetVC?.overlayColor = .black.withAlphaComponent(0.45)
                viewController.vBackground.isHidden = false
            })
            .disposed(by: disposeBag)
        
        // TextView focus ended
        tvComment.rx.didEndEditing
            .asDriver()
            .drive(with: self, onNext: { viewController, _ in
                viewController.sheetVC?.overlayColor = .clear
                viewController.vBackground.isHidden = true
            })
            .disposed(by: disposeBag)
        
        // Comments changed
        tvComment.rx.text
            .asDriverOnErrorJustComplete()
            .drive(with: self, onNext: { viewController, text in
                viewController.onCommentsChanged(text)
                viewController.updateTextViewHeight()
            })
            .disposed(by: disposeBag)
        
        // Set TextView's delegate
        tvComment.rx.setDelegate(self).disposed(by: disposeBag)
        
        // btnEmoji tap
        btnEmoji.rx.tap
            .asDriver()
            .drive(with: self, onNext: { viewController, _ in
                viewController.btnEmoji.isSelected.toggle()
                viewController.onEmojiPickerTrigger(isShow: viewController.btnEmoji.isSelected)
            })
            .disposed(by: disposeBag)
        
        // btnSend tap
        btnSend.rx.tap
            .subscribe(with: self, onNext: { viewController, _ in
                viewController.dismissInputView()
            })
            .disposed(by: disposeBag)
        
        // Expand/collapse reply
        commentCellEventTrigger
            .asDriverOnErrorJustComplete()
            .drive(with: self, onNext: { viewController, event in
                switch event {
                case let .expandCollapseReply((cell, isExpand)):
                    cell.expandCollapseReply(isExpand: isExpand)
                    viewController.tbComments.beginUpdates()
                    viewController.tbComments.endUpdates()
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func setUpUI() {
        btnDismiss.tintColor = .white
        btnMention.tintColor = .white
        btnEmoji.tintColor = .white
        btnAsk.tintColor = .white

        btnSend.isHidden = true
        btnSend.backgroundColor = AppColors.red
        btnSend.setRounded()
        
        ivAvatar.setRounded()
        
        vBottom.backgroundColor = AppColors.secondaryBackground
        vInputContainer.backgroundColor = AppColors.textFieldBackground
        vInputContainer.customBorder(cornerRadius: 5, borderWidth: 1.0, color: .clear)
        
        tvComment.placeholder = Text.addComments
        tvComment.placeholderColor = AppColors.lightGray
        tvComment.placeholderFont = R.font.milliardLight(size: 14)
        tvComment.font = R.font.milliardLight(size: 14)
        tvComment.textColor = .white
        tvComment.textContainerInset = UIEdgeInsets(top: 14, left: 8, bottom: 8, right: 0)
        
        lbScreenTitle.font = R.font.milliardMedium(size: 13)
        lbScreenTitle.textColor = .white.withAlphaComponent(0.7)
    }
    
    private func setUpEmojiPicker() {
        let keyboardSettings = KeyboardSettings(bottomType: .categories)
        keyboardSettings.countOfRecentsEmojis = 20
        keyboardSettings.updateRecentEmojiImmediately = true
        
        let emojiView = EmojiView(keyboardSettings: keyboardSettings)
        emojiView.translatesAutoresizingMaskIntoConstraints = false
        emojiView.delegate = self
        emojiView.backgroundColor = .clear
        
        vEmojiKeyboardContainer.addSubview(emojiView)
        emojiView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setUpInputAccessoryView() {
        let vInputAccessory = EmojiInputAccessoryView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 50))
        vInputAccessory.emojiSelectObservable
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self, onNext: { viewController, emoji in
                viewController.tvComment.insertText(emoji)
            })
            .disposed(by: disposeBag)
        tvComment.inputAccessoryView = vInputAccessory
    }
    
    private func setUpTableView() {
        tbComments.registerNib(CommentCell.self)
        tbComments.estimatedRowHeight = CommentCell.kEstimatedCellHeight
        tbComments.rowHeight = UITableView.automaticDimension
    }
    
    private func insertBackgroundView() {
        view.insertSubview(vBackground, belowSubview: vBottom)
        vBackground.snp.makeConstraints { make in
            make.bottom.equalTo(vBottom.snp.top)
            make.left.right.equalToSuperview()
            make.top.equalTo(vContent.snp.top)
        }
    }
    
    private func configureReplyUI(user: TTUser) {
        tvComment.placeholder = Text.replyTo(user.username)
        tvComment.becomeFirstResponder()
        btnAsk.isHidden = true
        btnEmoji.isHidden = true
    }
    
    private func dismissInputView() {
        btnAsk.isHidden = false
        btnEmoji.isHidden = false
        btnEmoji.isSelected = false
        currentPickerView = .none
        tvComment.placeholder = Text.addComments
        tvComment.text = ""
        tvComment.resignFirstResponder()
        onKeyboardHeightChanged(0, notification: nil)
    }
    
    private func onKeyboardHeightChanged(_ height: CGFloat, notification: Notification?) {
        let duration = notification?.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0
        let curveValue = notification?.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int ?? 0
        
        guard let curve = UIView.AnimationCurve(rawValue: curveValue) else {
            Logger.e("Animate comment input view failed: Invalid curve animation")
            return
        }
        
        var _height = height
        if case .emoji = currentPickerView {
            _height = 250
        }
        
        let animator = UIViewPropertyAnimator(duration: duration,
                                              curve: curve,
                                              animations: { [weak self] in
                                                guard let self = self else { return }
                                                self.vBottomBottomConstraint.constant = _height
                                                self.view.layoutIfNeeded()
                                              })
        animator.startAnimation()
    }
    
    private func onCommentsChanged(_ text: String?) {
        let isTextEmpty = text?.isEmpty ?? false
        let newRightPadding: CGFloat = isTextEmpty
            ? self.kDefaultInputRightPadding
            : self.kButtonSendWidth + 20
        
        btnAsk.isHidden = !isTextEmpty
        btnSend.isHidden = isTextEmpty
        
        // Only animate send button once
        if !isTextEmpty && !didAnimateSendButton {
            btnSend.doZoomBounceAnimation()
            didAnimateSendButton = true
        }
        
        guard vInputContainerTrailingConstraint.constant != newRightPadding else { return }
        
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            guard let self = self else { return }
            self.vInputContainerTrailingConstraint.constant = newRightPadding
            self.view.layoutIfNeeded()
        }, completion: { [weak self] _ in
            if isTextEmpty {
                self?.didAnimateSendButton = false
            }
        })
    }
    
    private func updateTextViewHeight() {
        let newSize = tvComment.sizeThatFits(CGSize(width: tvComment.frame.size.width,
                                                    height: .greatestFiniteMagnitude))
        
        if newSize.height == kTextViewMaxHeight {
            tvComment.isScrollEnabled = true
        } else if newSize.height > kTextViewMaxHeight {
            tvComment.isScrollEnabled = true
            tvComment.changeHeight(to: kTextViewMaxHeight)
            view.layoutIfNeeded()
        } else {
            tvComment.isScrollEnabled = false
            let height = newSize.height > kTextViewDefaultHeight ? newSize.height : kTextViewDefaultHeight
            tvComment.changeHeight(to: height)
            view.layoutIfNeeded()
        }
    }
    
    private func onEmojiPickerTrigger(isShow: Bool) {
        currentPickerView = isShow ? .emoji : .none
        vEmojiKeyboardContainer.isHidden = !isShow
        tvComment.resignFirstResponder()
        onKeyboardHeightChanged(isShow ? 250 : 0, notification: nil)
    }
}

// MARK: - Extensions
extension CommentsVC: EmojiViewDelegate {
    func emojiViewDidSelectEmoji(_ emoji: String, emojiView: EmojiView) {
        tvComment.insertText(emoji)
    }
    
    func emojiViewDidPressChangeKeyboardButton(_ emojiView: EmojiView) {
        tvComment.inputView = nil
        tvComment.keyboardType = .default
        tvComment.reloadInputViews()
    }
    
    func emojiViewDidPressDeleteBackwardButton(_ emojiView: EmojiView) {
        tvComment.deleteBackward()
    }
    
    func emojiViewDidPressDismissKeyboardButton(_ emojiView: EmojiView) {
        tvComment.resignFirstResponder()
    }
}

extension CommentsVC: UITextViewDelegate {
    func textView(_ textView: UITextView,
                  shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {
        let updatedString = (textView.text.orEmpty as NSString).replacingCharacters(in: range, with: text)
        return updatedString.count <= kCommentCharactersLimit
    }
}
