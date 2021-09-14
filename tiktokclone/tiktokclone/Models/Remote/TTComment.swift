//
//  TTComment.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 12/09/2021.
//

import Foundation

public struct TTComment: Codable {
    var id: String
    var ownerId: String
    var videoId: String
    var videoOwnerId: String
    var comment: String
    var createdAt: Int
    var isPinned: Bool
    var likedIds: [String]
    var replies: [TTComment]
    
    // Is the comment liked by owner or not
    var isLikedByOwner: Bool {
        return likedIds.contains(videoOwnerId)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, comment, replies
        case ownerId = "owner_id"
        case videoId = "video_id"
        case videoOwnerId = "video_owner_id"
        case likedIds = "liked_ids"
        case createdAt = "created_at"
        case isPinned = "is_pinned"
    }
    
    init(dictionary: [String: Any]) {
        self.id = dictionary[CodingKeys.id.rawValue] as? String ?? ""
        self.ownerId = dictionary[CodingKeys.ownerId.rawValue] as? String ?? ""
        self.videoId = dictionary[CodingKeys.videoId.rawValue] as? String ?? ""
        self.videoOwnerId = dictionary[CodingKeys.videoOwnerId.rawValue] as? String ?? ""
        self.comment = dictionary[CodingKeys.comment.rawValue] as? String ?? ""
        self.isPinned = dictionary[CodingKeys.isPinned.rawValue] as? Bool ?? false
        self.createdAt = dictionary[CodingKeys.createdAt.rawValue] as? Int ?? 0
        self.likedIds = dictionary[CodingKeys.likedIds.rawValue] as? [String] ?? []
        let repliesDict = dictionary[CodingKeys.replies.rawValue] as? [[String: Any]] ?? [[:]]
        self.replies = repliesDict.map { TTComment(dictionary: $0) }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(ownerId, forKey: .ownerId)
        try container.encode(videoId, forKey: .videoId)
        try container.encode(videoOwnerId, forKey: .videoOwnerId)
        try container.encode(comment, forKey: .comment)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(isPinned, forKey: .isPinned)
        try container.encode(likedIds, forKey: .likedIds)
        try container.encode(replies, forKey: .replies)
    }
    
    /// Initializers for uploading comment
    init(videoId: String, videoOwnerId: String, ownerId: String, comment: String) {
        self.videoId = videoId
        self.comment = comment
        self.videoOwnerId = videoOwnerId
        self.ownerId = ownerId
        self.comment = comment
        self.id = ""
        self.createdAt = 0
        self.isPinned = false
        self.likedIds = []
        self.replies = []
    }
}
  
extension TTComment: Equatable {
    public static func ==(lhs: TTComment, rhs: TTComment) -> Bool {
        return lhs.id == rhs.id
    }
}
