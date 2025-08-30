//
//  NetworkManager.swift
//  GitHubSearchApp
//
//  Created by MINERALA on 29.08.2025.
//

import Foundation

// MARK: - NetworkClient Protocol
protocol NetworkClient {
    func makeRequest<T: Decodable>(endpoint: Endpoint, type: T.Type, completed: @escaping (Result<T, AppError>) -> Void)
}

// MARK: - NetworkManager
final class NetworkManager: NetworkClient {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
    }

    func makeRequest<T: Decodable>(endpoint: Endpoint, type: T.Type, completed: @escaping (Result<T, AppError>) -> Void) {
        // URL oluştur
        guard let url = URL(string: endpoint.baseURL + endpoint.path) else {
            completed(.failure(.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.headers

        URLSession.shared.dataTask(with: request) { data, response, error in

            // Network error
            if let error = error as? URLError, error.code == .notConnectedToInternet {
                completed(.failure(.noInternetConnection))
                return
            } else if let error = error {
                completed(.failure(.networkError(error)))
                return
            }

            // HTTP response validation
            guard let httpResponse = response as? HTTPURLResponse else {
                completed(.failure(.invalidResponse))
                return
            }

            switch httpResponse.statusCode {
            case 200...299: break
            case 400: completed(.failure(.invalidRequest)); return
            case 401: completed(.failure(.unauthorized)); return
            case 402: completed(.failure(.paymentRequired)); return
            case 403: completed(.failure(.forbidden)); return
            case 404: completed(.failure(.pageNotFound)); return
            default:
                completed(.failure(.invalidHTTPStatusCode(statusCode: httpResponse.statusCode)))
                return
            }

            // Data validation
            guard let data = data else {
                completed(.failure(.invalidData))
                return
            }

            // Decoding
            do {
                let decoder = JSONDecoder()
                let decodedObject = try decoder.decode(T.self, from: data)
                completed(.success(decodedObject))
            } catch {
                completed(.failure(.decodingError))
            }

        }.resume()
    }
}

