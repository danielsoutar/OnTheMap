//
//  MapAuthRequest.swift
//  OnTheMap
//
//  Created by Daniel Soutar on 13/09/2020.
//  Copyright © 2020 Daniel Soutar. All rights reserved.
//

import Foundation

struct Udacity : Codable {
    let username: String
    let password: String
}

struct MapAuthRequest : Codable {
    let udacity: Udacity
}
