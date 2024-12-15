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
        // Initialize the mock API manager and reset any necessary properties
        mockAPIManager = MockAPIManager()

        // Initialize viewModel asynchronously
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
        // Clean up viewModel and mockAPIManager
        viewModel = nil
        mockAPIManager = nil
        super.tearDown()
    }

    // Test: Success loading race data
    func testLoadRaceDataSuccess() async {
        // Arrange: Prepare mock race data
        let raceData = setupMockRaceData()
        mockAPIManager.mockRaceData = raceData

        // Act: Load data using the view model
        await viewModel.loadRacesData(categoryIDs: [RaceCategories.horseRacing, RaceCategories.harnessRacing])

        // Assert: Check if races are loaded correctly
        await MainActor.run {
            XCTAssertEqual(viewModel.races.count, 2)
            XCTAssertNil(viewModel.errorMessage)
        }
    }

    // Test: Failure loading race data
    func testLoadRaceDataFailure() async {
        // Arrange: Simulate an error
        mockAPIManager.shouldReturnError = true

        // Act: Attempt to load data
        await viewModel.loadRacesData(categoryIDs: [RaceCategories.horseRacing])

        // Assert: Check if error is handled correctly
        await MainActor.run {
            XCTAssertEqual(viewModel.races.count, 0)
            XCTAssertEqual(viewModel.errorMessage, "Failed to load race data: Mocked error")
        }
    }

    // Test: Filtering races by category
    func testRaceFilterByCategory() async {
        // Arrange: Prepare mock race data
        let raceData = setupMockRaceData()
        mockAPIManager.mockRaceData = raceData

        // Act: Load data with category filter
        await viewModel.loadRacesData(categoryIDs: [RaceCategories.horseRacing])

        // Assert: Check if the filtered races are correct
        await MainActor.run {
            XCTAssertEqual(viewModel.races.count, 1)
            XCTAssertTrue(viewModel.races.allSatisfy { $0.categoryID == RaceCategories.horseRacing })
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
