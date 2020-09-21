//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Daniel Soutar on 13/09/2020.
//  Copyright © 2020 Daniel Soutar. All rights reserved.
//

import MapKit
import UIKit

class MapViewController: UIViewController, MKMapViewDelegate {

    // MARK: - Outlets
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var dropPinButton: UIBarButtonItem!
    
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Constants and Variables

    // Annotations for all locations downloaded
    var annotations: [MKPointAnnotation] = []

    // Annotation for the user logged in.
    var userAnnotation: MKPointAnnotation = MKPointAnnotation()

    // MARK: - View-related Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self

        DataModelRefresher.loadDataWithClient(
            completionForRecentLocations: self.handleDownloadStudentLocations,
            completionForUserLocation: self.handleDownloadUserLocation)
        self.mapView.reloadInputViews()

        // NOTE: This only works because this view controller is the first presented.
        // If the table view were the first, no region would be chosen, and the
        // LocationEntryViewController uses the region to constrain the search.
        LocationModel.boundingRegion = self.mapView.region
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.mapView.reloadInputViews()
    }

    // MARK: - Update Map Methods

    func createAnnotation(at index: Int, from source: [StudentInformation]) -> MKPointAnnotation {
        let lat = source[index].latitude
        let long = source[index].longitude

        let first = source[index].firstName
        let last = source[index].lastName

        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        annotation.title = "\(first) \(last)"
        annotation.subtitle = URL(string: source[index].mediaURL)?.absoluteString ?? ""

        return annotation
    }

    func handleDownloadStudentLocations(studentLocations: [StudentInformation]?, error: Error?) {
        guard let studentLocations = studentLocations else {
            displayNoDataError()
            return
        }
        // Add data to the map and reload the page
        LocationModel.locations = studentLocations
        // Clear any existing annotations prior to loading.
        self.mapView.removeAnnotations(self.mapView.annotations)
        for i in 0..<studentLocations.count {
            annotations.append(createAnnotation(at: i, from: LocationModel.locations))
        }
        self.mapView.addAnnotations(annotations)

        // Fail gracefully if no data available.
        // This is OK since this is wrapped within an async block in the MapClient.
        if self.mapView.annotations.count == 0 {
            displayNoDataError()
        }
        DataModelRefresher.annotationsAttemptedDownload = true
    }

    func handleDownloadUserLocation(studentLocation: StudentInformation?, error: Error?) {
        guard let studentLocation = studentLocation else {
            print("Error in user location: \(error?.localizedDescription ?? "")")
            DataModelRefresher.userAnnotationAttemptedDownload = true
            return
        }
        // Add data to the map and reload the page
        LocationModel.currentUserLocation = studentLocation
        let userAnnotation = createAnnotation(at: 0, from: [studentLocation])

        LocationModel.currentUserLocationKnown = true

        self.mapView.addAnnotation(userAnnotation)

        // Not having any data for this user is not necessarily an error, so no
        // alerts here.
        DataModelRefresher.userAnnotationAttemptedDownload = true
    }

    // MARK: - MkMapViewDelegate

    // Show pins for student locations
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

    // Open URLs from pins
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                app.open(URL(string: toOpen)!, options: [:], completionHandler: nil)
            }
        }
    }

    // MARK: - Actions

    @IBAction func handleLogoutPressed(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        let alert = Alert(title: "Logout Failed",
                          message: "Unfortunately you failed to log out, please check your connection and try again.",
                          actionTitles: ["OK"],
                          actionStyles: [nil],
                          actions: [nil],
                          shouldPresent: true)
        MapTabbedController.logoutFromTabbedController(from: self, to: vc, except: alert)
    }

    @IBAction func handleDropPinPressed(_ sender: Any) {
        // Make this a closure so that the scene is only created when actually
        // making the transition.
        // Currently a bug where this controller wrongly transitions to another black
        // scene when making the alert on the navigation stack (despite every other alert
        // not having this issue). It also obscures the alert, and when clicking
        // either button incorrectly logs out. This is not documented and is
        // completely beyond me. The controller to transition to is ***only***
        // created when the transition is meant to be made.
        let makeVC = { return self.storyboard?.instantiateViewController(
            withIdentifier: "LocationEntryViewController") as! LocationEntryViewController }
        MapTabbedController.checkAndInitLocationEntry(from: self,
                                                      in: self.mapView.region,
                                                      completion: makeVC)
    }

    // MARK: - Error Messaging

    func displayNoDataError() {
        let message = "Unfortunately no data seems to be available - checking your internet connection and restarting the app may help."
        let alert = Alert(title: "No Data Available",
                          message: message,
                          actionTitles: ["OK"],
                          actionStyles: [nil],
                          actions: [nil],
                          shouldPresent: true)
        showAlert(from: alert)
    }
}
