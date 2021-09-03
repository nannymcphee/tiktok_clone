//
//  Dictionary+Ext.swift
//  42Events
//
//  Created by Nguyên Duy on 19/05/2021.
//

import Foundation

extension Dictionary {
    var toJsonString: String {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: self) else { return "" }
        return String(data: jsonData, encoding: .utf8) ?? ""
    }
}

extension Data {
    var toJsonString: String {
        return String(data: self, encoding: .utf8) ?? ""
    }
}
