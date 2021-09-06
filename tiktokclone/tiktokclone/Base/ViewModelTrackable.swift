//
//  ViewModelTrackable.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 03/09/2021.
//

protocol ViewModelTrackable: AnyObject {
    var loadingIndicator: ActivityIndicator { get }
    var errorTracker: ErrorTracker { get }
}
