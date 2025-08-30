//
//  AppString.swift
//  GitHubSearchApp
//
//  Created by MINERALA on 29.08.2025.
//

import Foundation

enum AppStrings {
    // APP
    static let favoriteItemUpdated = "favoriteItemUpdated"
    
    // UI
    static let home = "Home"
    static let favorites = "Favorites"

    // Errors
    static let invalidURL = "Invalid URL"
    static let invalidResponse = "Invalid Response"
    static let invalidRequest = "Invalid Request"
    static let invalidData = "The data received from the server was invalid. Please try again."
    static let invalidHTTPStatusCode = "Invalid HTTP Status Code: "
    static let networkError = "A network error has occurred. Check your Internet connection and try again."
    static let decodingError = "Decoding Error"
    static let unauthorized = "In order to perform this operation, you must be logged in or have the necessary authorization. Please log in or provide the necessary authorization."
    static let paymentRequired = "Sorry, you need to pay to view or access this content."
    static let forbidden = "You have exceeded the allowed number of requests. Please wait a while and try again."
    static let pageNotFound = "Sorry, the page or resource you requested could not be found. Please check the URL or try again later."
    static let noInternetConnection = "Sorry, there is no internet connection. Please check your internet connection and try again."
    static let unowned = "Unowned Error!"
    static let navigationError = "Navigation Error: Missing coordinator."
}
