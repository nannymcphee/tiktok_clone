//
//  TextCheckingType.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 12/09/2021.
//

import Foundation

public enum TextCheckingType {
    case addressComponents([NSTextCheckingKey: String]?)
    case date(Date?)
    case phoneNumber(String?)
    case link(URL?)
    case transitInfoComponents([NSTextCheckingKey: String]?)
    case mention(String)
    case mentionAll
    case hashtag(String)
    case custom(pattern: String, match: String?)
}

public enum CustomDetectorType: Hashable {
    case address
    case date
    case phoneNumber
    case url
    case transitInformation
    case custom(NSRegularExpression)

    // swiftlint:disable force_try
    public static var hashtag = CustomDetectorType.custom(try! NSRegularExpression(pattern: "#[a-zA-Z0-9]{4,}", options: []))
    public static var mention = CustomDetectorType.custom(try! NSRegularExpression(pattern: "@[1-9][0-9]{10,15}", options: []))
    // swiftlint:enable force_try

    public var textCheckingType: NSTextCheckingResult.CheckingType {
        switch self {
        case .address: return .address
        case .date: return .date
        case .phoneNumber: return .phoneNumber
        case .url: return .link
        case .transitInformation: return .transitInformation
        case .custom: return .regularExpression
        }
    }

    /// Simply check if the detector type is a .custom
    public var isCustom: Bool {
        switch self {
        case .custom: return true
        default: return false
        }
    }

    ///The hashValue of the `DetectorType` so we can conform to `Hashable` and be sorted.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(toInt())
    }

    /// Return an 'Int' value for each `DetectorType` type so `DetectorType` can conform to `Hashable`
    private func toInt() -> Int {
        switch self {
        case .address: return 0
        case .date: return 1
        case .phoneNumber: return 2
        case .url: return 3
        case .transitInformation: return 4
        case .custom(let regex): return regex.hashValue
        }
    }
}
