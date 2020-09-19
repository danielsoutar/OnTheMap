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
            print("Error in student locations: \(error?.localizedDescription ?? "")")
            return
        }
        // Add data to the map and reload the page
        LocationModel.locations = studentLocations
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
        // Could follow the MovieManager and extend the UIViewController class
        // to avoid having to write this in both the MapViewController and
        // MapTableViewController, or alternatively have it conform to a protocol?
        MapClient.deleteSession { success, error in
            print("Logging out")
            DispatchQueue.main.async {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func handleDropPinPressed(_ sender: Any) {
        // Raise the alert if a user has some data to overwrite, meaning
        // locationIsKnown is true. If it's false, check that the download
        // attempt was made.
        if LocationModel.currentUserLocationKnown {
            let alertVC = UIAlertController(title: "",
                message: "You have already posted a Location. Would you like to overwrite your Current Location?",
                preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "Overwrite", style: .default, handler: self.setUpLocationEntry))
            alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            show(alertVC, sender: nil)
            // If a download attempt was made but locationIsKnown is false, that
            // means there's no data to overwrite. Just call directly.
        } else if DataModelRefresher.userAnnotationAttemptedDownload {
            setUpLocationEntry(nil)
        }
        // Do nothing otherwise, since we are still waiting to know if the
        // user has data they may be overwriting.
    }

    // MARK: - Helpers

    func setUpLocationEntry(_ action: UIAlertAction?) -> Void {
        let vc = storyboard?.instantiateViewController(withIdentifier: "LocationEntryViewController") as! LocationEntryViewController
        vc.modalPresentationStyle = .fullScreen
        vc.regionToSearch = self.mapView.region
        self.present(vc, animated: true, completion: nil)
    }
    
    // MARK: - Error Messaging
    
    func displayNoDataError() {
        let message = "Unfortunately no data seems to be available - checking your internet connection and restarting the app may help."
        let alertVC = UIAlertController(title: "No Data Available", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        // Not sure how best to guard against a slow connection if a user attempts
        // to log out before the download is done.
        if !self.isBeingDismissed {
            self.present(alertVC, animated: true, completion: nil)
        }
    }

}
