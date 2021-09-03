//
//  TTUser.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 03/09/2021.
//

import Foundation

struct TTUser: Codable {
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
