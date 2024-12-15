//
//  MockAPIManager.swift
//  RaceTrackerTests
//
//  Created by Ike Zeng on 15/12/2024.
//

import Foundation
@testable import RaceTracker

class MockAPIManager: APIRequestable {

    var mockRaceData: RaceData?

    var shouldReturnError = false

    /// Fetches mock race data or returns an error based on the flag.
    func fetchRaceData() async throws -> RacesResponse {
        if shouldReturnError {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mocked error"])
        }

        guard let raceData = mockRaceData else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No mock data provided"])
        }
        return RacesResponse(status: 200, data: raceData)
    }
}
