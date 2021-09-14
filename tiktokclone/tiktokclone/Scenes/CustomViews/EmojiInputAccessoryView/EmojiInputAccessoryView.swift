//
//  EmojiInputAccessoryView.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 12/09/2021.
//

import UIKit
import RxSwift
import RxCocoa

class EmojiInputAccessoryView: BaseView {
    // MARK: - UI Elements
    private lazy var cvEmoji: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        view.backgroundColor = .clear
        view.isScrollEnabled = false
        return view
    }()
    
    // MARK: - Variables
    private let emojisRelay = BehaviorRelay<[String]>(value: ["😁", "🥰", "😂", "😳", "😏", "😅", "🥺", "😌"])
    
    private let _emojiSelectSubject = PublishSubject<String>()
    var emojiSelectObservable: Observable<String> {
        return _emojiSelectSubject.asObservable()
    }
    
    // MARK: - Overrides
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
        setUpCollectionView()
        bindingUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private functions
    private func setUpView() {
        view.backgroundColor = AppColors.secondaryBackground
        addSubview(cvEmoji)
        cvEmoji.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setUpCollectionView() {
        cvEmoji.registerNib(EmojiCell.self)

        if let layout = cvEmoji.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 10
            layout.minimumInteritemSpacing = 0
            layout.sectionInset = UIEdgeInsets(top: 6, left: 8, bottom: 10, right: 8)
            let width: CGFloat = bounds.width
            let numberOfColumns: CGFloat = CGFloat(emojisRelay.value.count)
            let widthCell: CGFloat = (width - layout.sectionInset.horizontal - max(0, numberOfColumns - 1) * layout.minimumLineSpacing) / numberOfColumns
            layout.itemSize = CGSize(width: widthCell, height: bounds.height - layout.sectionInset.vertical)
        }
    }
    
    private func bindingUI() {
        emojisRelay.asDriverOnErrorJustComplete()
            .drive(cvEmoji.rx.items(cellIdentifier: EmojiCell.reuseIdentifier, cellType: EmojiCell.self)) { _, data, cell in
                cell.lbEmoji.text = data
            }
            .disposed(by: disposeBag)
        
        cvEmoji.rx.modelSelected(String.self)
            .bind(to: _emojiSelectSubject)
            .disposed(by: disposeBag)
    }
}
