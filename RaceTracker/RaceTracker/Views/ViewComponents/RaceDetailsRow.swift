//
//  RaceDetailsRow.swift
//  RaceTracker
//
//  Created by Ike Zeng on 14/12/2024
//

import Foundation
import SwiftUI

/// RaceDetailsRow displays the race details including the race number, meeting name, race type icon, and a countdown timer to the start of the race.
struct RaceDetailsRow: View {

    /// A summary of the race including its meeting name, race number, and start time.
    let race: RaceSummary

    /// The remaining time (in seconds) until the race starts.
    @State private var remainingSeconds: Int = 0

    var body: some View {
        HStack {
            // Race type icon
            Image(systemName: imageNameForRaceType(race.categoryID))
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .accessibilityLabel(Strings.RaceDetailsRow.accessibilityRaceType(raceCategoryName(for: race.categoryID)))

            // Race meeting name and race number
            VStack(alignment: .leading) {
                Text(race.meetingName)
                    .font(.headline)
                    .accessibilityLabel(Strings.RaceDetailsRow.accessibilityMeetingName(race.meetingName))
                Text("\(Strings.RaceDetailsRow.raceNumber) \(race.raceNumber)")
                    .font(.subheadline)
                    .accessibilityLabel(Strings.RaceDetailsRow.accessibilityRaceNumber(String(race.raceNumber)))
            }

            Spacer()

            // Countdown timer
            Text(formatCountdownTime(seconds: remainingSeconds))
                .font(.subheadline)
                .foregroundStyle(.red)
                .accessibilityLabel(Strings.RaceDetailsRow.accessibilityTimeRemaining(formatCountdownTime(seconds: remainingSeconds)))

        }
        .padding()
        .onAppear {
            let currentTime = Date()
            let advertisedStartTime = Date(timeIntervalSince1970: TimeInterval(race.startTime.seconds))
            remainingSeconds = Int(advertisedStartTime.timeIntervalSince(currentTime))
            startTimer()
        }
    }

    // MARK: - Helpers

    /// Returns the image name for the race category.
    /// - Parameter type: The category ID of the race.
    /// - Returns: The system icon name.
    func imageNameForRaceType(_ type: String) -> String {
        switch type {
        case RaceCategories.horseRacing:
            return "hare.fill"
        case RaceCategories.harnessRacing:
            return "car.2"
        case RaceCategories.greyhoundRacing:
            return "dog.fill"
        default:
            return ""
        }
    }

    /// Formats the countdown time from seconds into a more human-readable format.
    /// - Parameter seconds: The remaining seconds until the event starts, which can be negative when the event has started.
    /// - Returns: A formatted string representing the time.
    func formatCountdownTime(seconds: Int) -> String {
        let absoluteSeconds = abs(seconds)
        let isNegative = seconds < 0
        let timeString: String

        if absoluteSeconds < 60 {
            timeString = "\(absoluteSeconds)s"
        } else if absoluteSeconds < 3600 {
            let minutes = absoluteSeconds / 60
            let remainingSeconds = absoluteSeconds % 60
            timeString = remainingSeconds > 0 ? "\(minutes)m \(remainingSeconds)s" : "\(minutes)m"
        } else {
            let hours = absoluteSeconds / 3600
            let minutes = (absoluteSeconds % 3600) / 60
            timeString = minutes > 0 ? "\(hours)h \(minutes)m" : "\(hours)h"
        }

        return isNegative ? "-\(timeString)" : timeString
    }

    /// Starts the countdown timer that updates the remaining time every second.
    func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            remainingSeconds -= 1
        }
    }

    /// Maps a categoryID to its corresponding race category name.
    /// - Parameter categoryID: The ID of the race category.
    /// - Returns: The race category name.
    func raceCategoryName(for categoryID: String) -> String {
        switch categoryID {
        case RaceCategories.horseRacing:
            return Strings.RaceDetailsRow.horseRacing
        case RaceCategories.harnessRacing:
            return Strings.RaceDetailsRow.harnessRacing
        case RaceCategories.greyhoundRacing:
            return Strings.RaceDetailsRow.greyhoundRacing
        default:
            return Strings.RaceDetailsRow.unknownRace
        }
    }
}
