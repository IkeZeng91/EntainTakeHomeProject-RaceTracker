//
//  DefaultAPIManagerTests.swift
//  RaceTrackerTests
//
//  Created by Ike Zeng on 14/12/2024.
//

import XCTest
@testable import RaceTracker

final class DefaultAPIManagerTests: XCTestCase {
    var apiManager: DefaultAPIManager!

    override func setUp() {
        super.setUp()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolMock.self]
        let mockSession = URLSession(configuration: config)

    apiManager = DefaultAPIManager(session: mockSession)
    }

    override func tearDown() {
        apiManager = nil
        super.tearDown()
    }

    func testFetchRaceData_withValidResponse_shouldReturnDecodedData() async throws {
        // Given
        let mockJSON = """
        {
            "status": 200,
            "data": {
                "next_to_go_ids": ["123", "456"],
                "race_summaries": {
                    "123": {
                        "race_id": "123",
                        "race_number": 1,
                        "meeting_name": "Horse go go",
                        "category_id": "1",
                        "advertised_start": {
                            "seconds": 1609459200
                        }
                    }
                }
            }
        }
        """
        let mockData = mockJSON.data(using: .utf8)!
        let mockURL = URL(string: APIEndpoints.nextRaces)!
        let mockResponse = HTTPURLResponse(url: mockURL, statusCode: 200, httpVersion: nil, headerFields: nil)

        URLProtocolMock.testURLs = [mockURL: (mockData, mockResponse!)]
        URLProtocolMock.error = nil

        // When
        let result = try await apiManager.fetchRaceData()

        // Then
        XCTAssertEqual(result.status, 200)
        XCTAssertEqual(result.data.nextToGoIDS, ["123", "456"])
        XCTAssertNotNil(result.data.raceSummaries["123"])
    }

    func testFetchRaceData_withInvalidURL_shouldThrowUnsupportedURLError() async {
        // Given
        let invalidAPIManager = DefaultAPIManager(session: URLSession.shared, baseURL: "invalidURL")

        // When
        do {
            _ = try await invalidAPIManager.fetchRaceData()
            XCTFail("Expected APIError.networkError")
        } catch let error as APIError {
            // Then
            if case .networkError(let underlyingError) = error {
                XCTAssertEqual(underlyingError.localizedDescription, "unsupported URL")
            } else {
                XCTFail("Expected networkError, but got \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testFetchRaceData_withEmptyResponse_shouldThrowDecodingError() async {
        // Given
        let mockURL = URL(string: APIEndpoints.nextRaces)!
        let mockResponse = HTTPURLResponse(url: mockURL, statusCode: 200, httpVersion: nil, headerFields: nil)
        let emptyData = Data() // Empty data

        URLProtocolMock.testURLs = [mockURL: (emptyData, mockResponse!)]
        URLProtocolMock.error = nil

        // When
        do {
            _ = try await apiManager.fetchRaceData()
            XCTFail("Expected APIError.decodingError")
        } catch let error as APIError {
            // Then
            switch error {
            case .decodingError:
                break
            case .networkError(let underlyingError):
                if let decodingError = underlyingError as? DecodingError {
                    XCTAssertNotNil(decodingError)
                } else {
                    XCTFail("Expected DecodingError, but got \(underlyingError)")
                }
            default:
                XCTFail("Unexpected error: \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testFetchRaceData_withTimeoutError_shouldThrowNetworkError() async {
        // Given
        let timeoutError = URLError(.timedOut)

        URLProtocolMock.testURLs = [:]
        URLProtocolMock.error = timeoutError

        // When
        do {
            _ = try await apiManager.fetchRaceData()
            XCTFail("Expected APIError.networkError with timeout")
        } catch let error as APIError {
            // Then
            if case .networkError(let underlyingError) = error {
                XCTAssertEqual(underlyingError.localizedDescription, timeoutError.localizedDescription)
            } else {
                XCTFail("Expected networkError wrapping timeout, but got \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testFetchRaceData_withNoNetworkConnection_shouldThrowNetworkError() async {
        // Given
        let noConnectionError = URLError(.notConnectedToInternet)

        URLProtocolMock.testURLs = [:] // No mock data
        URLProtocolMock.error = noConnectionError

        // When
        do {
            _ = try await apiManager.fetchRaceData()
            XCTFail("Expected APIError.networkError with no internet connection")
        } catch let error as APIError {
            // Then
            if case .networkError(let underlyingError) = error {
                XCTAssertEqual(underlyingError.localizedDescription, noConnectionError.localizedDescription)
            } else {
                XCTFail("Expected networkError wrapping no connection, but got \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testFetchRaceData_withMalformedJSON_shouldThrowDecodingError() async {
        // Given
        let invalidJSON = """
        { "invalid_key": "invalid_value", }
        """
        let mockData = invalidJSON.data(using: .utf8)!
        let mockURL = URL(string: APIEndpoints.nextRaces)!
        let mockResponse = HTTPURLResponse(url: mockURL, statusCode: 200, httpVersion: nil, headerFields: nil)

        URLProtocolMock.testURLs = [mockURL: (mockData, mockResponse!)]
        URLProtocolMock.error = nil

        // When
        do {
            _ = try await apiManager.fetchRaceData()
            XCTFail("Expected APIError.decodingError")
        } catch let error as APIError {
            // Then
            if case .decodingError = error {
                // success
            } else {
                XCTFail("Expected decodingError, but got \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}

final class URLProtocolMock: URLProtocol {
    static var testURLs: [URL: (Data, HTTPURLResponse)] = [:]
    static var error: Error?

    override static func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override static func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        if let error = URLProtocolMock.error {
            client?.urlProtocol(self, didFailWithError: error)
        } else if let (data, response) = URLProtocolMock.testURLs[request.url!] {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
        }
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
