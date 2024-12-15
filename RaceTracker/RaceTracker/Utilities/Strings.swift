//
//  Strings.swift
//  RaceTracker
//
//  Created by Ike Zeng on 14/12/2024.
//

import Foundation

struct Strings {

    struct RaceDetailsRow {
        static let raceNumber = "Race Number: "
        static let horseRacing = "Horse Racing"
        static let harnessRacing = "Harness Racing"
        static let greyhoundRacing = "Greyhound Racing"
        static let unknownRace = "Unknown Race"

        static func accessibilityRaceType(_ categoryName: String) -> String {
            return "Race type: \(categoryName)"
        }

        static func accessibilityMeetingName(_ meetingName: String) -> String {
            return "Meeting name: \(meetingName)"
        }

        static func accessibilityRaceNumber(_ raceNumber: String) -> String {
            return "Race number: \(raceNumber)"
        }

        static func accessibilityTimeRemaining(_ countdown: String) -> String {
            return "Time remaining: \(countdown)"
        }
    }

    struct ErrorMessages {
        static let networkError = "Failed to load data. Please try again."
        static let failedToLoad = "Failed to load race data: "
    }

    struct RacesListView {
        static let title = "Upcoming Races"
        static let loadingMessage = "Loading races..."
        static let errorTitle = "Oops! Something went wrong!"
        static let errorRetryButton = "Retry"
        static let errorCancelButton = "Cancel"
        static let unknownError = "Unknown error occurred."
        static let filterButtonHorseRacing = "Horse Racing"
        static let filterButtonHarnessRacing = "Harness Racing"
        static let filterButtonGreyhoundRacing = "Greyhound Racing"
        static let accessibilityLoadingRaces = "Loading races"
        static let accessibilityHorseRacingFilter = "Horse Racing Filter"
        static let accessibilityHarnessRacingFilter = "Harness Racing Filter"
        static let accessibilityGreyhoundRacingFilter = "Greyhound Racing Filter"
        static let accessibilityRefreshButton = "Refresh races list"
        static let accessibilityRefreshButtonHint = "Double tap to refresh the race list"
    }

    struct FilterButton {
        static let horseRacing = "Horse Racing"
        static let harnessRacing = "Harness Racing"
        static let greyhoundRacing = "Greyhound Racing"
        static func accessibilityFilterButtonTitle(_ title: String) -> String {
            return "\(title) filter button"
        }

        static func accessibilityFilterButtonHint(isSelected: Bool) -> String {
            return isSelected ? "Tap to deselect" : "Tap to select"
        }
    }
}
