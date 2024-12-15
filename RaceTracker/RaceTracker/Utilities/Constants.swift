//
//  Constants.swift
//  RaceTracker
//
//  Created by Ike Zeng on 14/12/2024.
//

import Foundation

enum APIEndpoints {
    static let nextRaces = "https://api.neds.com.au/rest/v1/racing/?method=nextraces&count=10"
}

enum RaceCategories {
    static let horseRacing = "4a2788f8-e825-4d36-9894-efd4baf1cfae"
    static let harnessRacing = "161d9be2-e909-4326-8c2c-35ed71fb460b"
    static let greyhoundRacing = "9daef0d7-bf3c-4f50-921d-8e818c60fe61"
}
