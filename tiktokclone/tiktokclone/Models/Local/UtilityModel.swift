//
//  UtilityModel.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 03/09/2021.
//

import Foundation

struct UtilityModel {
    let iconName: String
    let title: String
    var tag: Int
}

extension UtilityModel {
    init() {
        iconName = ""
        title = ""
        tag = -1
    }
}
