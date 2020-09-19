//
//  ViewController.swift
//  OnTheMap
//
//  Created by Daniel Soutar on 13/09/2020.
//  Copyright © 2020 Daniel Soutar. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!

    @IBOutlet weak var facebookLoginButton: UIButton!

    // MARK: - View-related Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        emailTextField.text = ""
        passwordTextField.text = ""
    }
    
    // MARK: - Actions

    @IBAction func loginTapped(_ sender: Any) {
        setLoggingIn(true)
        MapClient.initialiseSession(self.emailTextField.text ?? "",
                                    password: self.passwordTextField.text ?? "",
                                    completion: handleSessionRequestResponse(_:error:))
    }

    @IBAction func signupTapped(_ sender: Any) {
        // Do nothing here
        print("Signing Up is currently unimplemented")
        setLoggingIn(true)
        let alertVC = UIAlertController(title: "Signup Failed",
                                        message: "Signing Up is currently unimplemented",
                                        preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default) {
            alertAction in
            self.setLoggingIn(false)
        })
        show(alertVC, sender: nil)
    }
    
    
    // MARK: - Action Handlers

    func handleSessionRequestResponse(_ wasSuccessful: Bool, error: Error?) {
        if wasSuccessful {
            let vc = storyboard?.instantiateViewController(withIdentifier: "MainPageController") as! UITabBarController
            vc.modalPresentationStyle = .fullScreen
            print("Current User Info: ", separator: "", terminator: "")
            print(LocationModel.currentUserLocation ?? "")
            setLoggingIn(false)
            self.present(vc, animated: true, completion: nil)
        } else {
            print("Session initialisation failed...")
            showLoginFailure(message: error?.localizedDescription ?? "")
        }
    }

    // MARK: - Helpers
    
    func setLoggingIn(_ isLoggingIn: Bool) {
        // Disable interactive elements while logging in.
        emailTextField.isEnabled = !isLoggingIn
        passwordTextField.isEnabled = !isLoggingIn
        loginButton.isEnabled = !isLoggingIn
    }
    
    // MARK: - Error Messaging

    func showLoginFailure(message: String) {
        setLoggingIn(false)
        let alertVC = UIAlertController(title: "Login Failed", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default) {
           alertAction in
           self.setLoggingIn(false)
        })
        show(alertVC, sender: nil)
    }
}
