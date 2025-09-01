//
//  MockNetworkManager.swift
//  GitHubSearchAppTests
//
//  Created by MINERALA on 31.08.2025.
//

import Foundation
@testable import GitHubSearchApp

final class MockNetworkManager: NetworkManagerProtocol {

    // MARK: - Test Flags
    var makeRequestCalled = false
    var shouldReturnError = false
    var forceInvalidURL = false
    var forceNoInternet = false
    var httpStatusCode: Int?

    // MARK: - Stub Data
    var mockData: Data?
    var mockResult: Any?

    // MARK: - Methods
    func makeRequest<T: Decodable>(endpoint: Endpoint, type: T.Type, completed: @escaping (Result<T, AppError>) -> Void) {

        makeRequestCalled = true

        if forceInvalidURL {
            completed(.failure(.invalidURL))
            return
        }

        if forceNoInternet {
            completed(.failure(.noInternetConnection))
            return
        }

        if shouldReturnError {
            completed(.failure(.networkError(NSError(domain: "", code: -1))))
            return
        }

        if let mockResult = mockResult as? T {
            completed(.success(mockResult))
            return
        }

        if let status = httpStatusCode, !(200...299).contains(status) {
            switch status {
            case 400: completed(.failure(.invalidRequest)); return
            case 401: completed(.failure(.unauthorized)); return
            case 402: completed(.failure(.paymentRequired)); return
            case 403: completed(.failure(.forbidden)); return
            case 404: completed(.failure(.pageNotFound)); return
            default: completed(.failure(.invalidHTTPStatusCode(statusCode: status))); return
            }
        }

        guard let data = mockData else {
            completed(.failure(.invalidData))
            return
        }

        do {
            let decodedObject = try JSONDecoder().decode(T.self, from: data)
            completed(.success(decodedObject))
        } catch {
            completed(.failure(.decodingError))
        }
    }
}
