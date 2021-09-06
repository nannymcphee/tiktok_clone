//
//  VideoThumbnailGenerator.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 04/09/2021.
//

import UIKit
import AVFoundation
import RxSwift

protocol VideoThumbnailGenerator {
    func getThumbnailFromVideo(_ url: URL) -> Single<UIImage>
}

final class VideoThumbnailGeneratorImpl: VideoThumbnailGenerator {
    func getThumbnailFromVideo(_ url: URL) -> Single<UIImage> {
        .create { single in
            let thumnailTime = CMTimeMake(value: 1, timescale: 1)
            let asset = AVAsset(url: url)
            let avAssetImageGenerator = AVAssetImageGenerator(asset: asset)
            avAssetImageGenerator.appliesPreferredTrackTransform = true
            
            do {
                let cgImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil)
                let image = UIImage(cgImage: cgImage)
                single(.success(image))
            } catch {
                single(.failure(error))
            }
            
            return Disposables.create()
        }
    }
}
