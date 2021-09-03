//
//  UserInfoView.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 03/09/2021.
//

import UIKit
import RxSwift

public class UserInfoView: BaseView {
    // MARK: - IBOutlets
    @IBOutlet weak var ivAvatar: UIImageView!
    @IBOutlet weak var lbTikTokId: UILabel!
    @IBOutlet weak var lbFollowingCount: UILabel!
    @IBOutlet weak var lbFollowing: UILabel!
    @IBOutlet weak var lbFollowerCount: UILabel!
    @IBOutlet weak var lbFollowers: UILabel!
    @IBOutlet weak var lbLikeCount: UILabel!
    @IBOutlet weak var lbLikes: UILabel!
    @IBOutlet var vHSeparators: [UIView]!
    @IBOutlet weak var btnEditProfile: UIButton!
    @IBOutlet weak var btnSaved: UIButton!
    
    // MARK: - Variables
    let kDefaultHeight: CGFloat = 289
    
    private let _editProfileTrigger = PublishSubject<Void>()
    var editProfileTrigger: Observable<Void> {
        return _editProfileTrigger.asObservable()
    }
    
    private let _savedTrigger = PublishSubject<Void>()
    var savedTrigger: Observable<Void> {
        return _savedTrigger.asObservable()
    }
    
    // MARK: - Overrides
    override public func initialize() {
        super.initialize()
        setupUI()
        bindingUI()
    }
    
    public override func reset() {
        super.reset()
    }
    
    // MARK: - Public functions
    func populateData(with user: TTUser) {
        ivAvatar.setImage(url: user.profileImage, placeholder: R.image.ic_avatar_placeholder())
        lbTikTokId.text = user.displayTikTokId
        lbFollowerCount.text = "\(user.followers)"
        lbFollowingCount.text = "\(user.following)"
        lbLikeCount.text = "\(user.likes)"
    }
    
    // MARK: - Private functions
    private func setupUI() {
        backgroundColor = AppColors.primaryBackground
        lbTikTokId.textColor = .white
        btnEditProfile.setTitleColor(.white, for: .normal)
        btnEditProfile.backgroundColor = AppColors.secondaryBackground
        btnSaved.tintColor = .white
        btnSaved.backgroundColor = AppColors.secondaryBackground
        vHSeparators.forEach { $0.backgroundColor = AppColors.secondaryBackground }
        
        [lbFollowingCount, lbFollowerCount, lbLikeCount].forEach {
            $0?.font = R.font.milliardSemiBold(size: 16)
            $0?.textColor = .white
        }
        
        [lbFollowing, lbFollowers, lbLikes].forEach {
            $0?.font = R.font.milliardLight(size: 12)
            $0?.textColor = AppColors.lightGray
        }
        
        btnEditProfile.titleLabel?.font = R.font.milliardSemiBold(size: 16)
        lbTikTokId.font = R.font.milliardSemiBold(size: 16)
        
        lbFollowing.text = Text.following
        lbFollowers.text = Text.followers
        lbLikes.text = Text.likes
        
        ivAvatar.customBorder(cornerRadius: ivAvatar.frame.size.height / 2, borderWidth: 1, color: .clear)
        btnEditProfile.customBorder(cornerRadius: 2, borderWidth: 1, color: .clear)
        btnSaved.customBorder(cornerRadius: 2, borderWidth: 1, color: .clear)
    }
    
    private func bindingUI() {
        btnEditProfile.rx.tap
            .bind(to: _editProfileTrigger)
            .disposed(by: disposeBag)
        
        btnSaved.rx.tap
            .bind(to: _savedTrigger)
            .disposed(by: disposeBag)
    }
}
