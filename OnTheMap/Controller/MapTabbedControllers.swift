//
//  MapTabbedControllers.swift
//  OnTheMap
//
//  Created by Daniel Soutar on 20/09/2020.
//  Copyright © 2020 Daniel Soutar. All rights reserved.
//

import Foundation
import MapKit
import UIKit

// Common functionality for the Map and Table view controllers,
// especially their common navigation bar button functionality.

// Would it have made more sense to create a custom view?
// Maybe, but it'd end up looking similar due to the need
// for a different region in both controllers.

class MapTabbedController : UIViewController {

    // Return the UIAlertAction callback from this function.
    static func setUpLocationEntry(from sender: UIViewController,
                                   to scene: () -> LocationEntryViewController,
                                   in region: MKCoordinateRegion) -> ((UIAlertAction?) -> Void) {
        let createdScene = scene()
        let task = { (action: UIAlertAction?) -> Void in
            createdScene.modalPresentationStyle = .fullScreen
            createdScene.regionToSearch = region
            sender.present(createdScene, animated: true, completion: nil)
        }
        return task
    }

    static func checkAndInitLocationEntry<ControllerType: UIViewController>(from sender: ControllerType,
                                          in region: MKCoordinateRegion,
                                          completion: () -> LocationEntryViewController) {
        // Raise the alert if a user has some data to overwrite, meaning
        // locationIsKnown is true. If it's false, check that the download
        // attempt was made.
        if LocationModel.currentUserLocationKnown {
            let alert = Alert(title: "",
                              message: "You have already posted a Location. Would you like to overwrite your Current Location?",
                              actionTitles: ["Overwrite", "Cancel"],
                              actionStyles: [.default, .cancel],
                              actions: [MapTabbedController.setUpLocationEntry(from: sender, to: completion, in: region), nil])
            sender.showAlert(from: alert)
            // If a download attempt was made but locationIsKnown is false,
            // that means there's no data to overwrite. Just call directly.
        } else if DataModelRefresher.userAnnotationAttemptedDownload {
            setUpLocationEntry(from: sender, to: completion, in: region)(nil)
        }
        // Do nothing otherwise, since we are still waiting to know if the
        // user has data they may be overwriting.
    }

    static func logoutFromTabbedController(from sender: UIViewController,
                                           to scene: LoginViewController,
                                           except alert: Alert) {
        MapClient.deleteSession { success, error in
            if success {
                print("Logging out")
                scene.modalPresentationStyle = .fullScreen
                sender.present(scene, animated: true, completion: nil)
            } else {
                sender.showAlert(from: alert)
            }
        }
    }
}
