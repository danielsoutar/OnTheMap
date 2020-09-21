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

    @IBAction func handleLogoutPressed(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(
            withIdentifier: "LoginViewController") as! LoginViewController
        let alert = Alert(title: "Logout Failed",
                          message: "Unfortunately you failed to log out, please check your connection and try again.",
                          actionTitles: ["OK"],
                          actionStyles: [nil],
                          actions: [nil])
        MapTabbedController.logoutFromTabbedController(from: self, to: vc, except: alert)
    }

    @IBAction func handleDropPinPressed(_ sender: Any) {
        let makeVC = { return self.storyboard?.instantiateViewController(
            withIdentifier: "LocationEntryViewController") as! LocationEntryViewController }
        MapTabbedController.checkAndInitLocationEntry(from: self,
                                                      in: LocationModel.boundingRegion!,
                                                      completion: makeVC)
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
        cell.detailTextLabel?.text = location.mediaURL
        cell.imageView?.image = UIImage(named: "placeholder")

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedIndex = indexPath.row
        let app = UIApplication.shared
        app.open(URL(string: LocationModel.locations[selectedIndex].mediaURL)!,
                 options: [:]) {
                    success in
                    self.tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
