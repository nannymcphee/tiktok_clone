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
    
    /// Keeps only 1 instance of VideoPlayerView
    private lazy var videoPlayerView: VideoPlayerView = {
        let view = VideoPlayerView.instance(with: nil)
        view.backgroundColor = .clear
        view.isHidden = true
        return view
    }()
    
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
            videoPlayerView.resume()
            return
        }
        
        guard let urlString = videoCell.currentVideo?.videoURL,
              let videoURL = URL(string: urlString) else {
            Logger.e("Invalid video url")
            return
        }
        
        stopAnyOngoingPlaying()
        videoCell.insertPlayerView(videoPlayerView)
        videoPlayerView.play(with: videoURL)
        state = .playing
        playingCell = videoCell
    }
    
    func pauseVideo() {
        guard playingCell != nil else { return }
        videoPlayerView.pause()
        state = .paused
    }
    
    /// Stops any ongoing audio playing if exists
    func stopAnyOngoingPlaying() {
        guard playingCell != nil else { return }
        videoPlayerView.resetPlayer()
        videoPlayerView.delegate = nil
        videoPlayerView.removeFromSuperview()
        playingCell?.setInitialUI()
        playingCell = nil
        state = .stopped
    }
    
    func resetVideoPlayer() {
        guard playingCell != nil else { return }
        videoPlayerView.resetPlayer()
        state = .paused
    }
    
    /// Resume a currently pause audio sound
    func resumeVideo() {
        guard playingCell != nil else {
            stopAnyOngoingPlaying()
            return
        }
        videoPlayerView.resume()
        state = .playing
    }
    
    func replayVideo() {
        guard playingCell != nil else {
            stopAnyOngoingPlaying()
            return
        }
        videoPlayerView.replayVideo()
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
