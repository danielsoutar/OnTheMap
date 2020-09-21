//
//  LinkEntryViewController.swift
//  OnTheMap
//
//  Created by Daniel Soutar on 16/09/2020.
//  Copyright © 2020 Daniel Soutar. All rights reserved.
//

import MapKit
import UIKit

class LinkEntryViewController: UIViewController, MKMapViewDelegate {

    // MARK: - Outlets
    @IBOutlet weak var linkEntryTextField: UITextField!

    @IBOutlet weak var mapView: MKMapView!

    // MARK: - Constants and Variables

    // The location from the parent view controller.
    var location: MKMapItem?

    // MARK: - View-related Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        // Make the media URL text field look a bit nicer.
        linkEntryTextField.attributedPlaceholder = NSAttributedString(string: "Enter Your URL Here",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])

        // Also set this controller as the text field's delegate.
        linkEntryTextField.delegate = self

        // Set up the annotation for the map view to display to the user.
        let annotation = MKPointAnnotation()
        annotation.coordinate = location!.placemark.coordinate
        annotation.title = "\(location?.placemark.title ?? "")"

        self.mapView.delegate = self
        self.mapView.addAnnotation(annotation)
        // Centers the map around the location provided.
        self.mapView.setCenter(annotation.coordinate, animated: true)
    }

    // MARK: - MKMapViewDelegate

    // Only show the solitary pin, don't allow any editing or other actions.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }

        return pinView
    }

    // MARK: - Actions

    @IBAction func addStudentInfoButtonPressed(_ sender: Any) {
        let newLatitude = location?.placemark.coordinate.latitude
        let newLongitude = location?.placemark.coordinate.longitude
        let newMediaURL = linkEntryTextField.text
        if validateAndVerifyURL(newMediaURL) {
            let locationString = location!.placemark.title!
            MapClient.addOrUpdateWithLocation(with: newLatitude!,
                                              newLongitude: newLongitude!,
                                              locationString: locationString,
                                              newMediaURL: newMediaURL ?? "") {
                (wasSuccessful, error) in
                if wasSuccessful {
                    LocationModel.currentUserLocation?.latitude = newLatitude!
                    LocationModel.currentUserLocation?.longitude = newLongitude!
                    LocationModel.currentUserLocation?.mapString = locationString
                    LocationModel.currentUserLocation?.mediaURL = newMediaURL ?? ""
                    LocationModel.currentUserLocationKnown = true
                    self.returnToMainPage()
                } else {
                    let alert = Alert(title: "Map Pin Post Failed",
                                      message: "Unfortunately your post didn't go through successfully (error message was \(error!.localizedDescription).\nCheck your connection and try again.",
                                      actionTitles: ["OK"],
                                      actionStyles: [nil],
                                      actions: [nil])
                    self.showAlert(from: alert)
                }
            }
        } else {
            displayURLError()
        }
    }

    @IBAction func handleCancelButtonPressed(_ sender: Any) {
        returnToMainPage()
    }

    // MARK: - Helpers

    func returnToMainPage() {
        // I don't like this, but not sure how else to properly
        // dismiss the view with the programmatic style I've used
        // (without recourse to a detail view or navigation stack
        // approach, which include undesirable presentation
        // features).
        DataModelRefresher.refresh()
        self.presentingViewController?.presentingViewController?.dismiss(
            animated: true, completion: nil)
    }

    func validateAndVerifyURL(_ newMediaURL: String?) -> Bool {
        return newMediaURL?.count ?? 0 > 0 && verifyUrl(urlString: newMediaURL)
    }

    func verifyUrl (urlString: String?) -> Bool {
        if let urlString = urlString {
            if NSURL(string: urlString) != nil {
                return true
            }
        }
        return false
    }

    func displayURLError() {
        let alert = Alert(title: "Invalid URL",
                          message: "Unfortunately the URL presented is invalid.",
                          actionTitles: ["OK"],
                          actionStyles: [nil],
                          actions: [nil])
        showAlert(from: alert)
    }
}

extension LinkEntryViewController : UITextFieldDelegate {

    // Dismiss the keyboard when pressing enter.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
}
