//
//  NetworkManagerTests.swift
//  GitHubSearchAppTests
//
//  Created by MINERALA on 31.08.2025.
//

import XCTest
@testable import GitHubSearchApp

final class NetworkManagerTests: XCTestCase {

    var mockNetworkManager: MockNetworkManager!

    override func setUp() {
        super.setUp()
        mockNetworkManager = MockNetworkManager()
    }

    override func tearDown() {
        mockNetworkManager = nil
        super.tearDown()
    }

    // MARK: - Success Cases
    func testMakeRequest_ReturnsMockResult() {
        let testUser = SearchItem(login: "MineRala", avatarURL: "https://example.com/avatar.png")
        mockNetworkManager.mockResult = testUser
        let expectation = self.expectation(description: "Request returns mockResult")

        mockNetworkManager.makeRequest(endpoint: .searchUsers(searchText: "MineRala"), type: SearchItem.self) { result in
            switch result {
            case .success(let user):
                XCTAssertEqual(user.login, "MineRala")
                XCTAssertEqual(user.avatarURL, "https://example.com/avatar.png")
                expectation.fulfill()
            case .failure:
                XCTFail("Request failed unexpectedly")
            }
        }

        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(mockNetworkManager.makeRequestCalled)
    }

    func testMakeRequest_ReturnsDecodedData() {
        let json = """
        { "login": "MineRala", "avatar_url": "https://example.com/avatar.png" }
        """.data(using: .utf8)!
        mockNetworkManager.mockData = json
        let expectation = self.expectation(description: "Request decodes mockData")

        mockNetworkManager.makeRequest(endpoint: .searchUsers(searchText: "MineRala"), type: SearchItem.self) { result in
            switch result {
            case .success(let user):
                XCTAssertEqual(user.login, "MineRala")
                XCTAssertEqual(user.avatarURL, "https://example.com/avatar.png")
                expectation.fulfill()
            case .failure:
                XCTFail("Request failed unexpectedly")
            }
        }

        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(mockNetworkManager.makeRequestCalled)
    }

    // MARK: - Failure Cases
    func testMakeRequest_ReturnsNetworkError() {
        mockNetworkManager.shouldReturnError = true
        let expectation = self.expectation(description: "Request returns network error")

        mockNetworkManager.makeRequest(endpoint: .searchUsers(searchText: "MineRala"), type: SearchItem.self) { result in
            switch result {
            case .success: XCTFail("Unexpected success")
            case .failure(let error):
                if case .networkError = error { expectation.fulfill() }
                else { XCTFail("Unexpected error: \(error)") }
            }
        }

        wait(for: [expectation], timeout: 1)
    }

    func testMakeRequest_ReturnsDecodingError() {
        let invalidJson = "{ invalid json }".data(using: .utf8)
        mockNetworkManager.mockData = invalidJson
        let expectation = self.expectation(description: "Request fails decoding")

        mockNetworkManager.makeRequest(endpoint: .searchUsers(searchText: "MineRala"), type: SearchItem.self) { result in
            switch result {
            case .success: XCTFail("Unexpected success")
            case .failure(let error):
                if case .decodingError = error { expectation.fulfill() }
                else { XCTFail("Unexpected error: \(error)") }
            }
        }

        wait(for: [expectation], timeout: 1)
    }

    func testMakeRequest_ReturnsInvalidData() {
        mockNetworkManager.mockData = nil
        let expectation = self.expectation(description: "Request returns invalid data")

        mockNetworkManager.makeRequest(endpoint: .searchUsers(searchText: "MineRala"), type: SearchItem.self) { result in
            switch result {
            case .success: XCTFail("Unexpected success")
            case .failure(let error):
                if case .invalidData = error { expectation.fulfill() }
                else { XCTFail("Unexpected error: \(error)") }
            }
        }

        wait(for: [expectation], timeout: 1)
    }

    func testMakeRequest_ReturnsInvalidURL() {
        mockNetworkManager.forceInvalidURL = true
        let expectation = self.expectation(description: "Request returns invalid URL")

        mockNetworkManager.makeRequest(endpoint: .searchUsers(searchText: ""), type: SearchItem.self) { result in
            switch result {
            case .success: XCTFail("Unexpected success")
            case .failure(let error):
                if case .invalidURL = error { expectation.fulfill() }
                else { XCTFail("Unexpected error: \(error)") }
            }
        }

        wait(for: [expectation], timeout: 1)
    }

    func testMakeRequest_ReturnsNoInternet() {
        mockNetworkManager.forceNoInternet = true
        let expectation = self.expectation(description: "Request returns no internet error")

        mockNetworkManager.makeRequest(endpoint: .searchUsers(searchText: "MineRala"), type: SearchItem.self) { result in
            switch result {
            case .success: XCTFail("Unexpected success")
            case .failure(let error):
                if case .noInternetConnection = error { expectation.fulfill() }
                else { XCTFail("Unexpected error: \(error)") }
            }
        }

        wait(for: [expectation], timeout: 1)
    }

    func testMakeRequest_HTTPStatusErrors() {
        let codes = [400, 401, 402, 403, 404, 500]
        let expectedErrors: [AppError] = [
            .invalidRequest,
            .unauthorized,
            .paymentRequired,
            .forbidden,
            .pageNotFound,
            .invalidHTTPStatusCode(statusCode: 500)
        ]

        for (index, code) in codes.enumerated() {
            mockNetworkManager.httpStatusCode = code
            mockNetworkManager.mockData = Data() // dummy data
            let expectation = self.expectation(description: "Status code \(code) returns correct error")

            mockNetworkManager.makeRequest(endpoint: .searchUsers(searchText: "MineRala"), type: SearchItem.self) { result in
                switch result {
                case .success: XCTFail("Unexpected success for code \(code)")
                case .failure(let error):
                    switch (error, expectedErrors[index]) {
                    case (.invalidRequest, .invalidRequest),
                         (.unauthorized, .unauthorized),
                         (.paymentRequired, .paymentRequired),
                         (.forbidden, .forbidden),
                         (.pageNotFound, .pageNotFound),
                         (.invalidHTTPStatusCode, .invalidHTTPStatusCode):
                        expectation.fulfill()
                    default:
                        XCTFail("Unexpected error \(error) for status code \(code)")
                    }
                }
            }

            wait(for: [expectation], timeout: 1)
        }
    }
}
