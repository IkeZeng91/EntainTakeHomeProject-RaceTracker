//
//  APIManager.swift
//  RaceTracker
//
//  Created by Ike Zeng on 14/12/2024.
//

import Foundation

/// A protocol for fetching race data from an API.
protocol APIRequestable {

    /// Asynchronously fetches race data.
    /// - Returns: A `RacesResponse` object containing race data.
    /// - Throws: An error if the data fetching fails.
    func fetchRaceData() async throws -> RacesResponse
}

/// A default implementation of `APIRequestable` that handles fetching race data from an API.
class DefaultAPIManager: APIRequestable {

    /// The base URL used to fetch race data from the API.
    private let baseURL: String

    /// The URL session used for making network requests.
    private let session: URLSession

    /// Initializes the API manager with an optional URL session and base URL.
    /// - Parameter session: The URL session used to make network requests. Defaults to `URLSession.shared`.
    /// - Parameter baseURL: The base URL used for API requests. Defaults to `APIEndpoints.nextRaces`.
    init(
        session: URLSession = URLSession.shared,
        baseURL: String = APIEndpoints.nextRaces
    ) {
        self.session = session
        self.baseURL = baseURL
    }

    /// Asynchronously fetches race data from the API.
    /// - Returns: A `RacesResponse` object containing the fetched race data.
    /// - Throws: An error if the URL is invalid, the response is not successful, or decoding fails.
    func fetchRaceData() async throws -> RacesResponse {
        guard let url = URL(string: baseURL) else {
            throw APIError.invalidURL
        }
        let urlRequest = URLRequest(url: url, timeoutInterval: 10)
        do {
            let (data, response) = try await session.data(for: urlRequest)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.serverError(statusCode: (response as? HTTPURLResponse)?.statusCode ?? -1)
            }
            if httpResponse.statusCode != 200 {
                throw APIError.serverError(statusCode: httpResponse.statusCode)
            }
            let decodedData = try JSONDecoder().decode(RacesResponse.self, from: data)
            return decodedData
        } catch let error as URLError {
            throw APIError.networkError(error)
        } catch {
            throw APIError.decodingError
        }
    }
}

/// Custom error type to handle different API errors.
enum APIError: LocalizedError {
    case invalidURL
    case serverError(statusCode: Int)
    case decodingError
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL is invalid."
        case .serverError(let statusCode):
            return "Server returned an error: \(statusCode)."
        case .decodingError:
            return "Failed to decode the data."
        case .networkError(let error):
            return error.localizedDescription
        }
    }
}
