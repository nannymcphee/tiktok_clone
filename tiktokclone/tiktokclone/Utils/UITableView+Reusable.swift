//
//  UITableView+Reusable.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 03/09/2021.
//

import UIKit

protocol Reusable: AnyObject {
    static var reuseIdentifier: String { get }
}

extension Reusable {
    static var reuseIdentifier: String {
        return String(describing: self)
        
    }
}

extension UITableViewCell: Reusable {}
extension UITableViewHeaderFooterView: Reusable {}

extension UICollectionViewCell: Reusable {}

protocol NibLoadableView {
    static var nibName: String { get }
}

extension NibLoadableView  {
    static var nibName: String {
        return String(describing: self)
    }
}

extension UITableViewCell: NibLoadableView {}
extension UICollectionViewCell: NibLoadableView {}

extension UITableView {
    func register<T: UITableViewCell>(_: T.Type)  {
        register(T.self, forCellReuseIdentifier: T.reuseIdentifier)
    }
    
    func registerNib<T: UITableViewCell>(_: T.Type)  {
        let bundle = Bundle(for: T.self)
        let nib = UINib(nibName: T.reuseIdentifier, bundle: bundle)
        register(nib, forCellReuseIdentifier: T.reuseIdentifier)
    }
    
    func registerHeaderNib<T: UITableViewHeaderFooterView>(_: T.Type)  {
        let bundle = Bundle(for: T.self)
        let nib = UINib(nibName: T.reuseIdentifier, bundle: bundle)
        register(nib, forHeaderFooterViewReuseIdentifier: T.reuseIdentifier)
    }
    
    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T  {
        guard let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
        }
        return cell
    }
    
    func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>(for section: Int) -> T  {
        guard let cell = dequeueReusableHeaderFooterView(withIdentifier: "DemoHeaderView") as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
        }
        return cell
    }
}

extension UICollectionView {
    func register<T: UICollectionViewCell>(_: T.Type)  {
        register(T.self, forCellWithReuseIdentifier: T.reuseIdentifier)
    }
    
    func registerNib<T: UICollectionViewCell>(_: T.Type)  {
        let bundle = Bundle(for: T.self)
        let nib = UINib(nibName: T.reuseIdentifier, bundle: bundle)
        register(nib, forCellWithReuseIdentifier: T.reuseIdentifier)
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T  {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
        }
        return cell
    }

}
