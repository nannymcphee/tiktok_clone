//
//  VideoUploadCoordinator.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 03/09/2021.
//

import UIKit
import XCoordinator

enum VideoUploadRoute: Route {
    case main
}

class VideoUploadCoordinator: NavigationCoordinator<VideoUploadRoute> {
    // MARK: Initialization
    init() {
        super.init(initialRoute: .main)
    }

    // MARK: Overrides
    override func prepareTransition(for route: VideoUploadRoute) -> NavigationTransition {
        switch route {
        case .main:
            let viewController = VideoUploadVC()
            return .push(viewController)
        }
    }
}
