//
//  RegisterVC.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 03/09/2021.
//

import UIKit
import RxSwift

final class RegisterVC: RxBaseViewController<RegisterVM> {
    // MARK: - IBOutlets
    @IBOutlet weak var vNavigationContainer: UIView!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var btnHelp: UIButton!
    @IBOutlet weak var scvContent: UIScrollView!
    @IBOutlet weak var vContent: UIView!
    @IBOutlet weak var lbRegisterTitle: UILabel!
    @IBOutlet weak var lbSubtitle: UILabel!
    @IBOutlet weak var tbMethod: UITableView!
    @IBOutlet weak var btnExpandTableView: UIButton!
    @IBOutlet weak var tvTerms: UITextView!
    @IBOutlet weak var lbBottom: UILabel!
    @IBOutlet weak var vBottom: UIView!
    @IBOutlet weak var vTextViewContainer: UIView!
    
    // MARK: - Variables
    private let registerMethodSelectTrigger = PublishSubject<UtilityModel>()
    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        bindViewModel()
        bindingUI()
    }
    
    override func setUpColors() {
        view.backgroundColor = AppColors.black1
        btnClose.tintColor = .white
        btnHelp.tintColor = AppColors.lightGray
        btnExpandTableView.tintColor = .white
        lbRegisterTitle.textColor = .white
        lbSubtitle.textColor = AppColors.lightGray
        tvTerms.textColor = AppColors.lightGray
        vTextViewContainer.backgroundColor = AppColors.black1
        vBottom.backgroundColor = AppColors.black2
    }
    
    
    // MARK: - Private functions
    private func bindViewModel() {
        let input = Input(registerMethodSelected: registerMethodSelectTrigger,
                          dismissTrigger: btnClose.rx.tap.mapToVoid(),
                          expandTableTrigger: btnExpandTableView.rx.tap.mapToVoid())
        let output = viewModel.transform(input: input)
        
        // Register methods
        output.registerMethods
            .drive(tbMethod.rx.items(cellIdentifier: RegisterMethodCell.reuseIdentifier, cellType: RegisterMethodCell.self)) { index, model, cell in
                cell.populateData(with: model)
                cell.selectionStyle = .none
            }
            .disposed(by: disposeBag)
        
        // TableView height
        output.tableViewHeight
            .drive(with: self, onNext: { viewController, data in
                viewController.animateTableViewHeight(data.height, isExpand: data.isExpand)
            })
            .disposed(by: disposeBag)
        
        viewModel.presentingViewController = self
    }
    
    private func bindingUI() {
        // Register method selected
        tbMethod.rx
            .modelSelected(UtilityModel.self)
            .bind(to: registerMethodSelectTrigger)
            .disposed(by: disposeBag)
    }
    
    private func setUpUI() {
        setUpAttributedTermText()
        setUpAttributedBottomText()
        
        lbRegisterTitle.font = R.font.milliardSemiBold(size: 24)
        lbSubtitle.font = R.font.milliardLight(size: 14)
        
        lbRegisterTitle.text = Text.registerTikTok
        lbSubtitle.text = Text.registerSubtitleText
        
        tbMethod.registerNib(RegisterMethodCell.self)
        tbMethod.rowHeight = viewModel.kMethodTableRowHeight
    }
    
    private func setUpAttributedTermText() {
        let normalTermAttributes: [NSAttributedString.Key: Any] = [.font: R.font.milliardLight(size: 12)!,
                                                                   .foregroundColor: AppColors.lightGray]
        let hightlightedTermAttributes: [NSAttributedString.Key: Any] = [.font: R.font.milliardSemiBold(size: 12)!,
                                                                         .foregroundColor: UIColor.white]
        let attributedTermText = Text.registerTermText.createAttributedString(textToStyle: Text.termsOfService,
                                                                              attributes: normalTermAttributes,
                                                                              styledAttributes: hightlightedTermAttributes)
        attributedTermText.customAddAttributes(hightlightedTermAttributes, text: Text.privacyPolicies)
        tvTerms.attributedText = attributedTermText
    }
    
    private func setUpAttributedBottomText() {
        let normalBottomAttributes: [NSAttributedString.Key: Any] = [.font: R.font.milliardLight(size: 16)!,
                                                                     .foregroundColor: AppColors.lightGray]
        let hightlightedBottomAttributes: [NSAttributedString.Key: Any] = [.font: R.font.milliardSemiBold(size: 16)!,
                                                                           .foregroundColor: AppColors.red]
        let attributedBottomText = Text.alreadyHaveAccountLogin.createAttributedString(textToStyle: Text.login,
                                                                                       attributes: normalBottomAttributes,
                                                                                       styledAttributes: hightlightedBottomAttributes)
        lbBottom.attributedText = attributedBottomText
    }
    
    private func animateTableViewHeight(_ height: CGFloat, isExpand: Bool) {
        UIView.animate(withDuration: kAnimationDuration, animations: { [weak self] in
            self?.tbMethod.changeHeight(to: height)
            self?.btnExpandTableView.alpha = isExpand ? 0 : 1
            self?.view.layoutIfNeeded()
        })
    }
}
