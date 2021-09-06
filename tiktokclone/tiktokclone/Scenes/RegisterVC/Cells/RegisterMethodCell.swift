//
//  RegisterMethodCell.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 03/09/2021.
//

import UIKit

class RegisterMethodCell: TableViewCell {

    @IBOutlet weak var vContent: UIView!
    @IBOutlet weak var ivMain: UIImageView!
    @IBOutlet weak var lbTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lbTitle.font = R.font.milliardMedium(size: 14)
        lbTitle.textColor = .white

        vContent.backgroundColor = AppColors.secondaryBackground
        vContent.setTikTokButtonStyle()
    }
    
    override func reset() {
        lbTitle.text = nil
        ivMain.image = nil
        ivMain.tintColor = .clear
        super.reset()
    }
    
    func populateData(with data: UtilityModel) {
        ivMain.image = UIImage(named: data.iconName)
        lbTitle.text = data.title
        if data.title == Text.usePhoneNumberOrEmail {
            ivMain.tintColor = .white
        }
    }
}
