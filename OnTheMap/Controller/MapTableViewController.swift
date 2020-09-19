//
//  MapTableViewController.swift
//  OnTheMap
//
//  Created by Daniel Soutar on 17/09/2020.
//  Copyright © 2020 Daniel Soutar. All rights reserved.
//

import UIKit

class MapTableViewController: UIViewController {
    
    // MARK: - Outlets

    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Constants and Variables
    
    // MARK: - View-related Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    // MARK: - Actions

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
        vc.regionToSearch = LocationModel.boundingRegion!
        self.present(vc, animated: true, completion: nil)
    }

}

extension MapTableViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - TableViewDelegate and DataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LocationModel.locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentLocationCell")!
        
        let location = LocationModel.locations[indexPath.row]
        
        cell.textLabel?.text = location.firstName + " " + location.lastName
        cell.imageView?.image = UIImage(named: "placeholder")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedIndex = indexPath.row
        let app = UIApplication.shared
        app.open(URL(string: LocationModel.locations[selectedIndex].mediaURL)!,
                 options: [:], completionHandler: nil)
    }
    
    
}
