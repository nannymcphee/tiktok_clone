//
//  TTUser.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 03/09/2021.
//

public struct TTUser: Codable {
    var id: String
    var tiktokId: String
    var username: String
    var email: String
    var phoneNumber: String
    var profileImage: String
    var userBio: String
    var following: Int
    var followers: Int
    var likes: Int
    var isVerified: Bool
    var videos: [String]
    var savedVideos: [String]
    var privateVideos: [String]
    var likedComments: [String]
    var likedVideos: [String]
    
    var displayTikTokId: String {
        return tiktokId.isEmpty ? "@\(username.replacingOccurrences(of: " ", with: ""))" : "@\(tiktokId)"
    }
    
    enum CodingKeys: String, CodingKey {
        case id, username, email, following, followers, likes, videos
        case tiktokId = "tiktok_id"
        case phoneNumber = "phone_number"
        case profileImage = "profile_img"
        case userBio = "user_bio"
        case isVerified = "is_verified"
        case savedVideos = "saved_videos"
        case privateVideos = "private_videos"
        case likedComments = "liked_comments"
        case likedVideos = "liked_videos"
    }
    
    init(dictionary: [String: Any]) {
        self.id = dictionary[CodingKeys.id.rawValue] as? String ?? ""
        self.tiktokId = dictionary[CodingKeys.tiktokId.rawValue] as? String ?? ""
        self.username = dictionary[CodingKeys.username.rawValue] as? String ?? ""
        self.email = dictionary[CodingKeys.email.rawValue] as? String ?? ""
        self.phoneNumber = dictionary[CodingKeys.phoneNumber.rawValue] as? String ?? ""
        self.profileImage = dictionary[CodingKeys.profileImage.rawValue] as? String ?? ""
        self.userBio = dictionary[CodingKeys.userBio.rawValue] as? String ?? ""
        self.following = dictionary[CodingKeys.following.rawValue] as? Int ?? 0
        self.followers = dictionary[CodingKeys.followers.rawValue] as? Int ?? 0
        self.likes = dictionary[CodingKeys.likes.rawValue] as? Int ?? 0
        self.isVerified = dictionary[CodingKeys.isVerified.rawValue] as? Bool ?? false
        self.videos = dictionary[CodingKeys.videos.rawValue] as? [String] ?? []
        self.savedVideos = dictionary[CodingKeys.savedVideos.rawValue] as? [String] ?? []
        self.privateVideos = dictionary[CodingKeys.privateVideos.rawValue] as? [String] ?? []
        self.likedComments = dictionary[CodingKeys.likedComments.rawValue] as? [String] ?? []
        self.likedVideos = dictionary[CodingKeys.likedVideos.rawValue] as? [String] ?? []
    }
    
    /// Initializers for saving data after login success
    init(id: String, username: String, phoneNumber: String, email: String, profileImage: String) {
        self.id = id
        self.username = username
        self.phoneNumber = phoneNumber
        self.email = email
        self.profileImage = profileImage
        self.tiktokId = ""
        self.userBio = ""
        self.following = 0
        self.followers = 0
        self.likes = 0
        self.isVerified = false
        self.videos = []
        self.savedVideos = []
        self.privateVideos = []
        self.likedComments = []
        self.likedVideos = []
    }
}
  
