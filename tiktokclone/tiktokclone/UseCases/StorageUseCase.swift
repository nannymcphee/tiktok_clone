//
//  StorageUseCase.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 04/09/2021.
//

import UIKit
import RxSwift
import FirebaseStorage
import Resolver

protocol StorageUseCase {
    func uploadVideo(url: URL) -> Single<String>
    func uploadImage(image: UIImage) -> Single<String>
}

final class StorageUseCaseImpl: StorageUseCase {
    @Injected private var userRepo: UserRepo
    private lazy var storage = Storage.storage().reference()
    private var currentUserId: String? {
        userRepo.currentUser?.id
    }
    
    func uploadVideo(url: URL) -> Single<String> {
        .create { [weak self] single in
            guard let self = self,
                  let userId = self.currentUserId,
                  let videoData = try? Data(contentsOf: url) else { return Disposables.create() }
            let fileName = self.getFileName(userId: userId, fileExtension: "mov")
            let videoRef = self.storage.child("videos").child(fileName)
            
            videoRef.putData(videoData, metadata: nil) { _, error in
                guard let error = error else {
                    // No error, retrieve downloadURL
                    videoRef.downloadURL { url, error in
                        if let error = error {
                            single(.failure(error))
                        }
                        
                        if let urlString = url?.absoluteString {
                            single(.success(urlString))
                        }
                    }
                    return
                }
                
                single(.failure(error))
            }
            
            return Disposables.create()
        }
    }
    
    func uploadImage(image: UIImage) -> Single<String> {
        .create { [weak self] single in
            guard let self = self,
                  let imageData = image.jpegData(compressionQuality: 0.8),
                  let userId = self.currentUserId else { return Disposables.create() }
            let fileName = self.getFileName(userId: userId, fileExtension: "jpg")
            let imageRef = self.storage.child("images").child(fileName)
            
            imageRef.putData(imageData, metadata: nil) { _, error in
                guard let error = error else {
                    // No error, retrieve downloadURL
                    imageRef.downloadURL { url, error in
                        if let error = error {
                            single(.failure(error))
                        }
                        
                        if let urlString = url?.absoluteString {
                            single(.success(urlString))
                        }
                    }
                    return
                }
                
                single(.failure(error))
            }
            
            return Disposables.create()
        }
    }
}

private extension StorageUseCase {
    func getFileName(userId: String, fileExtension: String) -> String {
        return "\(userId)_\(Date().timeIntervalSince1970.toInt).\(fileExtension)"
    }
}

private extension TimeInterval {
    var toInt: Int {
        return Int(self)
    }
}
