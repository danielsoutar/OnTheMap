//
//  MapUpdateLocationRequest.swift
//  OnTheMap
//
//  Created by Daniel Soutar on 19/09/2020.
//  Copyright © 2020 Daniel Soutar. All rights reserved.
//

import Foundation

// Shortened version of the StudentInformation struct, for submitting post/put requests
// to the Udacity API.
struct MapUpdateLocationRequest : Codable {
    let uniqueKey: String
    let firstName: String
    let lastName: String
    let mapString: String
    let mediaURL: String
    let latitude: Double
    let longitude: Double
}
