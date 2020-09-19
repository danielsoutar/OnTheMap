//
//  LocationModel.swift
//  OnTheMap
//
//  Created by Daniel Soutar on 17/09/2020.
//  Copyright © 2020 Daniel Soutar. All rights reserved.
//

import Foundation
import MapKit

class LocationModel {
    
    static var currentUserAccount: UdacityAccount?
    static var currentUserLocation: StudentInformation?
    static var currentUserLocationKnown = false
    static var locations = [StudentInformation]()
    
    // Bounding region initialised from MapViewController.
    // Defines the region to search when in LocationEntryViewController.
    static var boundingRegion: MKCoordinateRegion?
}
