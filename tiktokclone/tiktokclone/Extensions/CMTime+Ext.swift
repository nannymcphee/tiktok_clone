//
//  CMTime+Ext.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 10/09/2021.
//

import AVFoundation

extension CMTime {
    func durationFormatted() -> String {
        let seconds = CMTimeGetSeconds(self)
        let secondsText = String(format: "%02d", Int(seconds) % 60)
        let minutesText = String(format: "%02d", Int(seconds) / 60)
        return "\(minutesText):\(secondsText)"
    }
}
