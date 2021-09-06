//
//  VideoPlayerManager.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 06/09/2021.
//

import UIKit
import AVFoundation
import AVKit
import Resolver
import RxSwift
import RxCocoa

public enum PlayerState {
    case none
    case stopped
    case playing
    case paused
}

public class VideoPlayerManager: NSObject {
    /// The `VideoCell` that is currently playing video
    weak var playingCell: VideoCell?
    
    /// Specify if current video controller state: playing, in pause or none
    var state: PlayerState = .stopped

    // MARK: - Init Methods
    override init() {
        super.init()
        // Set output to speaker
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        } catch let error as NSError {
            print("audioSession error: \(error.localizedDescription)")
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Methods
    /// Used to start play video
    ///
    /// - Parameters:
    ///   - video: The `TTVideo` that contain the video url to be played
    ///   - videoCell: The `VideoCell` that needs to be updated while video is playing.
    func playVideo(in videoCell: VideoCell) {
        guard playingCell != videoCell else {
            videoCell.resumeVideo()
            return
        }
        
        stopAnyOngoingPlaying()
        videoCell.playVideo()
        state = .playing
        playingCell = videoCell
    }
    
    func pauseVideo() {
        guard let cell = playingCell else { return }
        cell.pauseVideo()
        state = .paused
    }
    
    /// Stops any ongoing audio playing if exists
    func stopAnyOngoingPlaying() {
        guard let cell = playingCell else { return }
        cell.stopVideo()
        playingCell = nil
        state = .stopped
    }
    
    func resetVideoPlayer() {
        guard let cell = playingCell else { return }
        cell.resetPlayerView()
        state = .paused
    }
    
    /// Resume a currently pause audio sound
    func resumeVideo() {
        guard let cell = playingCell else {
            stopAnyOngoingPlaying()
            return
        }
        cell.resumeVideo()
        state = .playing
    }
    
    // MARK: - Private Methods
    private func setSessionPlayerOn() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord)
        } catch _ {
            Logger.e("AVAudioSession setCategory failed")
        }
        do {
            try session.setActive(true)
        } catch _ {
            Logger.e("AVAudioSession setActive failed")
        }
        
        let currentRoute = session.currentRoute
        if currentRoute.outputs.count != 0 {
            for output in currentRoute.outputs {
                if output.portType == .builtInReceiver {
                    do {
                        try session.overrideOutputAudioPort(.speaker)
                    } catch _ {
                        Logger.e("AVAudioSession overrideOutputAudioPort failed")
                    }
                }
            }
        }
    }
}
