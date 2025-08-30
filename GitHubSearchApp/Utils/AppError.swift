//
//  AppError.swift
//  GitHubSearchApp
//
//  Created by MINERALA on 29.08.2025.
//

import Foundation

enum AppError: Error {
    case invalidURL
    case invalidResponse
    case invalidRequest
    case invalidData
    case invalidHTTPStatusCode(statusCode: Int)
    case networkError(Error)
    case decodingError
    case unauthorized
    case paymentRequired
    case forbidden
    case pageNotFound
    case noInternetConnection
    case unknown

    var errorMessage: String {
        switch self {
        case .invalidURL:
            return AppStrings.invalidURL
        case .invalidResponse:
            return AppStrings.invalidResponse
        case .invalidRequest:
            return AppStrings.invalidRequest
        case .invalidData:
            return AppStrings.invalidData
        case .invalidHTTPStatusCode(let statusCode):
            return AppStrings.invalidHTTPStatusCode + "\(statusCode)"
        case .networkError(_):
            return AppStrings.networkError
        case .decodingError:
            return AppStrings.decodingError
        case .unauthorized:
            return AppStrings.unauthorized
        case .paymentRequired:
            return AppStrings.paymentRequired
        case .forbidden:
            return AppStrings.forbidden
        case .pageNotFound:
            return AppStrings.pageNotFound
        case .noInternetConnection:
            return AppStrings.noInternetConnection
        case .unknown:
            return AppStrings.unowned
        }
    }
}
