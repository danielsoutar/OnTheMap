//
//  MapAuthResponse.swift
//  OnTheMap
//
//  Created by Daniel Soutar on 13/09/2020.
//  Copyright © 2020 Daniel Soutar. All rights reserved.
//

import Foundation

struct UdacityAccount : Codable {
    // Check if the user is registered.
    let registered: Bool
    // Unique user key for this Udacity account.
    let key: String
}

struct UdacitySession : Codable {
    // Session ID. Cookies are used for authenticating future requests,
    // so this is not needed.
    let id: String
    // Expiration time for this session. Good practice would be to check
    // if the current time is past this when logging on, as this would
    // enable logging the user out and re-authenticating, or maybe
    // updating the session on-the-fly.
    let expiration: String
}

struct MapAuthResponse : Codable {
    let account: UdacityAccount
    let session: UdacitySession
}
