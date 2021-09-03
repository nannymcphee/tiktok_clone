//
//  TableViewCell.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 03/09/2021.
//

import UIKit
import RxSwift

open class TableViewCell: UITableViewCell {
    public var disposeBag = DisposeBag()
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.initialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.initialize()
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        
        self.reset()
    }
    
    // MARK: - API
    
    open func initialize() {
        
    }
    
    open func reset() {
        disposeBag = DisposeBag()
    }
}
