//
//  EmojiCell.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 12/09/2021.
//

import UIKit

class EmojiCell: CollectionViewCell {

    @IBOutlet weak var lbEmoji: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lbEmoji.font = UIFont(name: "Apple color emoji", size: 26)
    }

    override func reset() {
        lbEmoji.text = nil
        super.reset()
    }
}
