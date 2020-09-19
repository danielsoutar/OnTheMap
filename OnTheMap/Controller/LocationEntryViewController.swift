//
//  StudyLocationDetailViewController.swift
//  OnTheMap
//
//  Created by Daniel Soutar on 13/09/2020.
//  Copyright © 2020 Daniel Soutar. All rights reserved.
//

import MapKit
import UIKit

class LocationEntryViewController: UIViewController, MKLocalSearchCompleterDelegate {

    // MARK: - Outlets
    
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var findOnMapButton: UIButton!
    
    @IBOutlet weak var loadingWheel: UIActivityIndicatorView!
    
    // MARK: - Constants and Variables

    private var locationTextFieldHasText = false
    
    var regionToSearch: MKCoordinateRegion?
    
    private var latestSearchResult: MKLocalSearchCompletion?
    private var searchCompleter: MKLocalSearchCompleter = MKLocalSearchCompleter()

    // MARK: - View-related Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        // Make the location text field look a bit nicer.
        locationTextField.attributedPlaceholder = NSAttributedString(string: "Enter Your Location Here",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        // Set up search completion.
        locationTextField.addTarget(self, action: #selector(LocationEntryViewController.textFieldDidChange(_:)), for: .editingChanged)
        searchCompleter.delegate = self
        searchCompleter.queryFragment = ""
        searchCompleter.region = regionToSearch ?? MKCoordinateRegion()
        
        // Disable the button initially
        findOnMapButton.isEnabled = false
        loadingWheel.isHidden = true
    }
    
    // MARK: - Actions
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func findOnMapButtonPressed(_ sender: Any) {
        if findOnMapButton.isEnabled {
            let searchRequest = MKLocalSearch.Request(completion: latestSearchResult!)
            
            loadingWheel.startAnimating()
            loadingWheel.isHidden = false
            search(using: searchRequest) {
                [unowned self] (response, error) in
                guard error == nil else {
                    print("Error in search(): " + error!.localizedDescription)
                    return
                }
                let location = response?.mapItems[0] ?? nil
                self.loadingWheel.isHidden = true
                self.loadingWheel.stopAnimating()

                let linkEntryVC = self.storyboard?.instantiateViewController(withIdentifier: "LinkEntryViewController") as! LinkEntryViewController
                linkEntryVC.location = location
                self.present(linkEntryVC, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - Search Completion
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        locationTextFieldHasText = textField.text?.count ?? 0 > 0
        searchCompleter.queryFragment = locationTextField.text ?? ""
        findOnMapButton.isEnabled = locationTextFieldHasText
    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        // As the user types, new completion suggestions are continuously returned to this method.
        // Overwrite the existing results, and then refresh the UI with the new results.
        let completerResults = searchCompleter.results
        if completerResults.count > 0 {
            latestSearchResult = completerResults[0]
        }
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // Handle any errors returned from MKLocalSearchCompleter.
        if let error = error as NSError? {
            print("MKLocalSearchCompleter encountered an error: \(error.localizedDescription). The query fragment is: \"\(completer.queryFragment)\"")
        }
    }
    
    private func search(using searchRequest: MKLocalSearch.Request, completion: @escaping (MKLocalSearch.Response?, Error?) -> Void) {
        // Confine the map search area to an area around the user's current location.
        searchRequest.region = regionToSearch!
        
        // Include only point of interest results. This excludes results based on address matches.
        searchRequest.resultTypes = .pointOfInterest
        
        let localSearch = MKLocalSearch(request: searchRequest)
        localSearch.start(completionHandler: completion)
    }
    
}
