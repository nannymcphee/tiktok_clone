//
//  Optional+Ext.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 03/09/2021.
//

public extension Optional where Wrapped == String {
    var orEmpty: String {
        switch self {
        case .some(let value):
            return String(describing: value)
        default:
            return ""
        }
    }
}
