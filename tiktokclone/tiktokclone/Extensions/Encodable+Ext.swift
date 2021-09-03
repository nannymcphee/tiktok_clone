//
//  Encodable+Ext.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 03/09/2021.
//

import Foundation

extension Encodable {
    func asDictionary() -> [String: Any] {
        guard let data = try? JSONEncoder().encode(self),
              let dictionary = try? JSONSerialization.jsonObject(with: data,
                                                                 options: .allowFragments) as? [String: Any] else {
            return [:]
        }
        return dictionary
    }
}

extension KeyedDecodingContainer {
    public func decodex<T>(key: K, defaultValue: T) -> T
        where T : Decodable {
            return (try? decode(T.self, forKey: key)) ?? defaultValue
    }
}
