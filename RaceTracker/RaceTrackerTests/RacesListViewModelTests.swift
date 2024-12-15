//
//  RacesListViewModelTests.swift
//  RaceTrackerTests
//
//  Created by Ike Zeng on 12/12/2024.
//

import XCTest
@testable import RaceTracker

final class RacesListViewModelTests: XCTestCase {
    var viewModel: RacesListViewModel!
    var mockAPIManager: MockAPIManager!

    override func setUp() {
        super.setUp()
        mockAPIManager = MockAPIManager()
        let expectation = self.expectation(description: "viewModel initialized")
        Task {
            await MainActor.run {
                self.viewModel = RacesListViewModel(apiManager: self.mockAPIManager)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }

    override func tearDown() {
        viewModel = nil
        mockAPIManager = nil
        super.tearDown()
    }

    // Test: Fetch race data successfully
    func testFetchRaceData_withValidCategory_shouldReturnRaces() async {
        // Given
        let raceData = setupMockRaceData()
        mockAPIManager.mockRaceData = raceData
        // When
        await viewModel.loadRacesData(categoryIDs: [RaceCategories.horseRacing, RaceCategories.harnessRacing])
        // Then
        await MainActor.run {
            XCTAssertEqual(viewModel.races.count, 2)
            XCTAssertNil(viewModel.errorMessage)
        }
    }

    func testFetchRaceData_withInvalidCategory_shouldReturnError() async {
        // Given
        mockAPIManager.shouldReturnError = true
        // When
        await viewModel.loadRacesData(categoryIDs: [RaceCategories.horseRacing])
        // Then
        await MainActor.run {
            XCTAssertEqual(viewModel.races.count, 0)
            XCTAssertEqual(viewModel.errorMessage, "Failed to load race data: Mocked error")
        }
    }

    func testFetchRaceData_withCategoryFilter_shouldReturnFilteredRaces() async {
        // Given
        let raceData = setupMockRaceData()
        mockAPIManager.mockRaceData = raceData
        // When
        await viewModel.loadRacesData(categoryIDs: [RaceCategories.horseRacing])
        // Then
        await MainActor.run {
            XCTAssertEqual(viewModel.races.count, 1)
            XCTAssertTrue(viewModel.races.allSatisfy { $0.categoryID == RaceCategories.horseRacing })
        }
    }

    func testFetchRaceData_withEmptyRaceData_shouldReturnNoRaces() async {
        // Given
        let emptyRaceData = RaceData(nextToGoIDS: [], raceSummaries: [:])
        mockAPIManager.mockRaceData = emptyRaceData

        // When
        await viewModel.loadRacesData(categoryIDs: [RaceCategories.horseRacing])

        // Then
        await MainActor.run {
            XCTAssertEqual(viewModel.races.count, 0)
            XCTAssertNil(viewModel.errorMessage)
        }
    }

    func testFetchRaceData_withInvalidRaceData_shouldReturnNoRace() async {
        // Given:
        let invalidRaceData = RaceData(
            nextToGoIDS: ["1"],
            raceSummaries: [
                "1": RaceSummary(
                    raceID: "1",
                    raceNumber: 1,
                    meetingName: "",
                    categoryID: RaceCategories.horseRacing,
                    startTime: StartTime(seconds: 0)
                )
            ]
        )
        mockAPIManager.mockRaceData = invalidRaceData
        // When
        await viewModel.loadRacesData(categoryIDs: [RaceCategories.horseRacing])
        // Then
        await MainActor.run {
            XCTAssertEqual(viewModel.races.count, 0)
        }
    }

    func testRaceDataRefresh_shouldUpdateData() async {
        // Given
        let initialRaceData = setupMockRaceData()
        mockAPIManager.mockRaceData = initialRaceData
        // When
        await viewModel.loadRacesData(categoryIDs: [RaceCategories.horseRacing])
        // Then:
        await MainActor.run {
            XCTAssertEqual(viewModel.races.count, 1)
        }
        // Given
        let updatedRaceData = setupMockRaceData()
        mockAPIManager.mockRaceData = updatedRaceData
        // When:
        await viewModel.loadRacesData(categoryIDs: [RaceCategories.horseRacing])
        // Then
        await MainActor.run {
            XCTAssertEqual(viewModel.races.count, 1)
        }
    }

    // Helper method to set up mock race data
    private func setupMockRaceData() -> RaceData {
        let currentDate = Date()
        let futureDate = currentDate.addingTimeInterval(5 * 60)
        let secondsSince1970 = Int(futureDate.timeIntervalSince1970)

        return RaceData(
            nextToGoIDS: ["1", "2", "3"],
            raceSummaries: [
                "1": RaceSummary(
                    raceID: "1",
                    raceNumber: 1,
                    meetingName: "Race 1",
                    categoryID: RaceCategories.horseRacing,
                    startTime: StartTime(seconds: secondsSince1970)
                ),
                "2": RaceSummary(
                    raceID: "2",
                    raceNumber: 2,
                    meetingName: "Race 2",
                    categoryID: RaceCategories.harnessRacing,
                    startTime: StartTime(seconds: secondsSince1970)
                ),
                "3": RaceSummary(
                    raceID: "3",
                    raceNumber: 3,
                    meetingName: "Race 3",
                    categoryID: RaceCategories.greyhoundRacing,
                    startTime: StartTime(seconds: secondsSince1970)
                )
            ]
        )
    }
}
