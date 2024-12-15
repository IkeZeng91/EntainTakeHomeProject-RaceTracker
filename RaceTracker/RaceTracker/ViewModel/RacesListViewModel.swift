//
//  RacesListViewModel.swift
//  RaceTracker
//
//  Created by Ike Zeng on 14/12/2024.
//

import SwiftUI

/// The view model for managing and providing data for the races list view. It handles race data loading, category filtering, and periodic refreshes.
@MainActor
class RacesListViewModel: ObservableObject {

    /// The list of races to display.
    @Published var races: [RaceSummary] = []

    /// A flag indicating whether race data is currently being loaded.
    @Published var isLoading = false

    /// A message to display when an error occurs while loading race data.
    @Published var errorMessage: String?

    /// The set of selected race categories to filter races.
    @Published var selectedCategories: Set<String> = [
        RaceCategories.horseRacing,
        RaceCategories.harnessRacing,
        RaceCategories.greyhoundRacing
    ]

    private let apiManager: APIRequestable
    private var refreshTimer: Timer?
    private var currentTime: Date = Date()

    /// Initializes the view model with an API manager.
    /// - Parameter apiManager: The API manager used to fetch race data.
    init(apiManager: APIRequestable) {
        self.apiManager = apiManager
    }

    /// Loads race data asynchronously, optionally filtered by category.
    /// - Parameter categoryIDs: An optional list of category IDs to filter races by.
    func loadRacesData(categoryIDs: [String]? = nil) async {
        isLoading = true
        errorMessage = nil
        do {
            // Fetch race data
            let response = try await apiManager.fetchRaceData()
            let filteredRaces = response.data.raceSummaries.values
                .filter { race in
                    let raceStartTime = Date(timeIntervalSince1970: Double(race.startTime.seconds))
                    return (categoryIDs == nil || categoryIDs!.contains(race.categoryID)) &&
                        isRaceUpcoming(raceStartTime: raceStartTime)
                }
                .sorted { $0.startTime.seconds < $1.startTime.seconds }

            // Limit the displayed races to 5
            races = Array(filteredRaces.prefix(5))
            isLoading = false
        } catch {
            errorMessage = Strings.ErrorMessages.failedToLoad + error.localizedDescription
            isLoading = false
        }
    }

    /// Toggles the selection state of a race category and reloads the race data accordingly.
    /// - Parameter category: The category to toggle.
    func toggleCategory(_ category: String) async {
        if selectedCategories.contains(category) {
            if selectedCategories.count == 1 {
                selectedCategories = [
                    RaceCategories.horseRacing,
                    RaceCategories.harnessRacing,
                    RaceCategories.greyhoundRacing
                ]
            } else {
                selectedCategories.remove(category)
            }
        } else {
            selectedCategories.insert(category)
        }

        await loadRacesData(categoryIDs: Array(selectedCategories))
    }

    /// Starts a timer to refresh the race data every 30 seconds.
    func startRefreshTimer() {
        stopRefreshTimer()
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { [weak self] in
                await self?.loadRacesData(categoryIDs: nil)
            }
        }
    }

    /// Stops the refresh timer if it's running.
    func stopRefreshTimer() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }

    /// Determines if a race is upcoming based on its start time and a cutoff time.
    /// - Parameter raceStartTime: The start time of the race.
    /// - Parameter cutoffInSeconds: The time before the current time to consider the race upcoming. Default is 60 seconds.
    /// - Returns: A Boolean value indicating whether the race is upcoming.
    private func isRaceUpcoming(raceStartTime: Date, cutoffInSeconds: TimeInterval = 60) -> Bool {
        let raceCutoffTime = currentTime.addingTimeInterval(-cutoffInSeconds)
        return raceStartTime > raceCutoffTime
    }
}
