//
//  ItemDetail.swift
//  GitHubSearchApp
//
//  Created by MINERALA on 29.08.2025.
//

import Foundation

struct ItemDetail: Decodable {
    let login: String
    let avatarURL: String
    let htmlURL: String
    let name: String?
    
    enum CodingKeys: String, CodingKey {
        case login
        case avatarURL = "avatar_url"
        case htmlURL = "html_url"
        case name
    }
}
