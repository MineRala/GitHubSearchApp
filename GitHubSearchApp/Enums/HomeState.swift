//
//  HomeState.swift
//  GitHubSearchApp
//
//  Created by MINERALA on 30.08.2025.
//

import Foundation

// MARK: - State Enum
enum HomeState {
    case idle
    case loading
    case populated([SearchItem])
    case empty
}
