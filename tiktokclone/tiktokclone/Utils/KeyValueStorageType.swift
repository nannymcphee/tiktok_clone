//
//  KeyValueStorageType.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 03/09/2021.
//

import Foundation

public enum AppKeys: String {
    case user               = "com.duynguyen.tiktokclone.user"
}

public protocol KeyValueStoreType: AnyObject {
    func set(_ value: Bool, forKey defaultName: String)
    func set(_ value: Int, forKey defaultName: String)
    func set(_ value: Double, forKey defaultName: String)
    func set(_ value: Any?, forKey defaultName: String)
    func save<T: Codable>(_ value: T?, forKey defaultName: String)
    
    
    func bool(forKey defaultName: String) -> Bool
    func data(forKey defaultName: String) -> Data?
    func dictionary(forKey defaultName: String) -> [String: Any]?
    func integer(forKey defaultName: String) -> Int
    func double(forKey defaultName: String) -> Double
    func object(forKey defaultName: String) -> Any?
    func string(forKey defaultName: String) -> String?
    func get<T: Codable>(forKey defaultName: String) -> T?
    func get<T: Codable>(forArrKey defaultName: String) -> [T]?
    
    func synchronize() -> Bool
    func removeObject(forKey defaultName: String)
    func clearUserData()
    
    // MARK: - Custom properties
    var user: TTUser? { get set }
}

public extension KeyValueStoreType {
    // MARK: - Custom properties
    var user: TTUser? {
        get {
            return get(forKey: AppKeys.user.rawValue)
        }
        set {
            save(newValue, forKey: AppKeys.user.rawValue)
        }
    }
}

extension UserDefaults: KeyValueStoreType {
    public func save<T: Codable>(_ value: T?, forKey defaultName: String) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(value) {
            self.set(data, forKey: defaultName)
        }
    }
    
    public func get<T: Codable>(forKey defaultName: String) -> T? {
        let decoder = JSONDecoder()
        if let data = self.object(forKey: defaultName) as? Data,
           let json = try? decoder.decode(T.self, from: data) {
            return json
        }
        return nil
    }
    
    public func get<T: Codable>(forArrKey defaultName: String) -> [T]? {
        let decoder = JSONDecoder()
        if let data = self.object(forKey: defaultName) as? Data,
           let array = try? decoder.decode(Array<T>.self, from: data) {
            return array
        }
        return nil
    }
    
    static func instance() -> KeyValueStoreType {
        return UserDefaults.standard
    }
    
    public func clearUserData() {
        user = nil
    }
}
