//
//  DataRefresh.swift
//  OnTheMap
//
//  Created by Daniel Soutar on 19/09/2020.
//  Copyright © 2020 Daniel Soutar. All rights reserved.
//

import Foundation

class DataModelRefresher {

    private static var NUMBER_OF_RECENT_LOCATIONS = 100
    // Room for improvement: Add a var to parameterise the ordering chosen.

    // Flags for checking if annotations were downloaded - disable the drop
    // pin button until this is completed - you can't know you're overwriting
    // something until those downloads are finished.
    static var annotationsAttemptedDownload = false
    static var userAnnotationAttemptedDownload = false

    // Cache the completion handlers from the call to loadDataWithClient() for use
    // in the refresh() method.
    private static var storedCompletionForRecentLocations: (([StudentInformation]?, Error?) -> Void)?
    private static var storedCompletionForUserLocations: ((StudentInformation?, Error?) -> Void)?

    class func loadDataWithClient(completionForRecentLocations: @escaping ([StudentInformation]?, Error?) -> Void,
                                  completionForUserLocation: @escaping (StudentInformation?, Error?) -> Void) {
        MapClient.loadRecentLocations(count: NUMBER_OF_RECENT_LOCATIONS,
                                      completionHandler: completionForRecentLocations)
        if let userKey = LocationModel.currentUserAccount?.key {
            MapClient.loadUserLocation(key: userKey,
                                       completionHandler: completionForUserLocation)
        }
        storedCompletionForRecentLocations = completionForRecentLocations
        storedCompletionForUserLocations = completionForUserLocation
    }
    
    class func refresh() {
        MapClient.loadRecentLocations(count: NUMBER_OF_RECENT_LOCATIONS,
                                      completionHandler: storedCompletionForRecentLocations!)
        if let userKey = LocationModel.currentUserAccount?.key {
            MapClient.loadUserLocation(key: userKey,
                                       completionHandler: storedCompletionForUserLocations!)
        }
    }
}
