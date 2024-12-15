//
//  Model.swift
//  RaceTracker
//
//  Created by Ike Zeng on 14/12/2024.
//

struct RacesResponse: Codable {
    let status: Int
    let data: RaceData
}

struct RaceData: Codable {
    let nextToGoIDS: [String]
    let raceSummaries: [String: RaceSummary]

    enum CodingKeys: String, CodingKey {
        case nextToGoIDS = "next_to_go_ids"
        case raceSummaries = "race_summaries"
    }
}

struct RaceSummary: Codable {
    let raceID: String
    let raceNumber: Int
    let meetingName: String
    let categoryID: String
    let startTime: StartTime

    enum CodingKeys: String, CodingKey {
        case raceID = "race_id"
        case raceNumber = "race_number"
        case meetingName = "meeting_name"
        case categoryID = "category_id"
        case startTime = "advertised_start"
    }
}

struct StartTime: Codable {
    let seconds: Int
}
