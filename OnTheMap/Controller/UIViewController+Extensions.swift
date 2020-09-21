//
//  UIViewController+Extensions.swift
//  OnTheMap
//
//  Created by Daniel Soutar on 20/09/2020.
//  Copyright © 2020 Daniel Soutar. All rights reserved.
//

import Foundation
import UIKit

struct Alert {
    let title: String
    let message: String
    let actionTitles: [String]
    let actionStyles: [UIAlertAction.Style?]
    let actions: [((UIAlertAction) -> Void)?]
}

extension UIViewController {

    func showAlert(from alert: Alert) {
        let alertVC = UIAlertController(
            title: alert.title, message: alert.message, preferredStyle: .alert)
        for i in 0..<alert.actions.count {
            alertVC.addAction(UIAlertAction(title: alert.actionTitles[i],
                                            style: alert.actionStyles[i] ?? .default,
                                            handler: alert.actions[i]))
        }
        // A guard against displaying the alert if the controller is being
        // dismissed.
        if !self.isBeingDismissed {
            show(alertVC, sender: nil)
        }
    }
}
