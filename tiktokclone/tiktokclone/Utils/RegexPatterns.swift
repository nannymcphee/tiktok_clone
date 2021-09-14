//
//  RegexPatterns.swift
//  tiktokclone
//
//  Created by Duy Nguyen on 12/09/2021.
//

import Foundation

enum RegexPatterns: String {
    case url = "http[s]?://(([^/:.[:space:]]+(.[^/:.[:space:]]+)*)|([0-9](.[0-9]{3})))(:[0-9]+)?((/[^?#[:space:]]+)([^#[:space:]]+)?(#.+)?)?"
    case mentionedUserId = "@[1-9][0-9]{10,15}"
    case mentionedAll = "@(all|All)"
}
