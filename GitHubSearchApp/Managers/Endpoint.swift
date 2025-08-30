//
//  Endpoint.swift
//  GitHubSearchApp
//
//  Created by MINERALA on 29.08.2025.
//

import Foundation

//https://api.github.com/search/users?q=minerala
//https://api.github.com/users/MineRala

// MARK: - API Endpoint Protocol
protocol APIEndpoint {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var parameters: [String: Any]? { get }
}

// MARK: - APIEndpoint Enum
enum Endpoint: APIEndpoint {
    enum Constant {
        static let baseURL = "https://api.github.com/"
    }

    case searchUsers(searchText: String)
    case getUserDetail(userName: String)

    var baseURL: String {
        return Constant.baseURL
    }

    var path: String {
        switch self {
        case .searchUsers(let searchText):
            return "search/users?q=\(searchText)"
        case .getUserDetail(let userName):
            return "users/\(userName)"
        }
    }

    var method: HTTPMethod {
        return .get
    }

    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }

    var parameters: [String: Any]? {
        return nil
    }
}
