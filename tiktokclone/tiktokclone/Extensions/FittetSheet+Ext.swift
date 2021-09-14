//
//  FittetSheet+Ext.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 11/09/2021.
//

import FittedSheets

extension SheetOptions {
    public static var tikTokDefault: SheetOptions {
        var options = SheetOptions(pullBarHeight: 0,
                                   shrinkPresentingViewController: false)
        options.transitionDampening = 1
        options.transitionVelocity = 1
        options.transitionDuration = 0.2
        return options
    }
}
