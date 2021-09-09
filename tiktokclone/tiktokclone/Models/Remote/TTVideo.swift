//
//  TTVideo.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 04/09/2021.
//

import UIKit

public struct TTVideo: Codable {
    var id: String
    var ownerId: String
    var `description`: String
    var thumbnailURL: String
    var videoURL: String
    var commentCount: Int
    var createdAt: Int
    var likedIds: [String]
    var tags: [String]
    
    var selectedVideoURL: URL?
    var videoThumbnail: UIImage?
    
    enum CodingKeys: String, CodingKey {
        case id, tags
        case ownerId = "owner_id"
        case `description` = "description"
        case thumbnailURL = "thumbnail_url"
        case videoURL = "video_url"
        case commentCount = "comment_count"
        case likedIds = "liked_ids"
        case createdAt = "created_at"
    }
    
    init(dictionary: [String: Any]) {
        self.id = dictionary[CodingKeys.id.rawValue] as? String ?? ""
        self.ownerId = dictionary[CodingKeys.ownerId.rawValue] as? String ?? ""
        self.description = dictionary[CodingKeys.description.rawValue] as? String ?? ""
        self.thumbnailURL = dictionary[CodingKeys.thumbnailURL.rawValue] as? String ?? ""
        self.videoURL = dictionary[CodingKeys.videoURL.rawValue] as? String ?? ""
        self.commentCount = dictionary[CodingKeys.commentCount.rawValue] as? Int ?? 0
        self.createdAt = dictionary[CodingKeys.createdAt.rawValue] as? Int ?? 0
        self.likedIds = dictionary[CodingKeys.likedIds.rawValue] as? [String] ?? []
        self.tags = dictionary[CodingKeys.tags.rawValue] as? [String] ?? []
    }
    
    /// Initializers for uploading video
    init(description: String, tags: [String], videoURL: URL?, thumbnailImage: UIImage?, ownerId: String) {
        self.description = description
        self.tags = tags
        self.selectedVideoURL = videoURL
        self.videoThumbnail = thumbnailImage
        self.ownerId = ownerId
        self.id = ""
        self.videoURL = ""
        self.thumbnailURL = ""
        self.commentCount = 0
        self.createdAt = 0
        self.likedIds = []
    }
}
  
extension TTVideo: Equatable {
    public static func ==(lhs: TTVideo, rhs: TTVideo) -> Bool {
        return lhs.id == rhs.id
    }
}
