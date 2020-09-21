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

    // MARK: - Constants and Variables

    // Flag for checking whether to shift the view for
    // the keyboard.
    var eitherTextFieldIsEditing = false

    // MARK: - View-related Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        // Register self as the delegate for text fields.
        configureTextFields()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        emailTextField.text = ""
        passwordTextField.text = ""

        // Subscribe to keyboard notifications for shifting
        // the view up.
        subscribeToKeyboardNotifications()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // We do this before this ViewController is deallocated from
        // memory - as that would lead to a broken observer otherwise.
        // That would be better put in a `deinit` method. But it also
        // makes sense, since there is no value in manipulating the
        // view when this ViewController is not visible.
        unsubscribeFromKeyboardNotifications()
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
        setLoggingIn(true)
        let alert = Alert(title: "Signup Failed", message: "Signing Up is currently unimplemented",
                          actionTitles: ["OK"], actionStyles: [nil],
                          actions: [{ alertAction in self.setLoggingIn(false) }])
        showAlert(from: alert)
    }

    // MARK: - Action Handlers

    func handleSessionRequestResponse(_ wasSuccessful: Bool, error: Error?) {
        if wasSuccessful {
            MapClient.getUserData(completion: handleUserDataRequestResponse(_:error:))
        } else {
            print("Session initialisation failed...")
            showLoginFailure(message: error?.localizedDescription ?? "")
        }
    }

    func handleUserDataRequestResponse(_ wasSuccessful: Bool, error: Error?) {
        if wasSuccessful {
            let vc = storyboard?.instantiateViewController(withIdentifier: "MainPageController") as! UITabBarController
            vc.modalPresentationStyle = .fullScreen
            print("Current User Info: ", separator: "", terminator: "")
            print(LocationModel.currentUserLocation ?? "")
            setLoggingIn(false)
            self.present(vc, animated: true, completion: nil)
        } else {
            print("GET request for User Data failed")
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
        let alert = Alert(title: "Login Failed", message: "Reason: " + message,
                          actionTitles: ["OK"],
                          actionStyles: [nil],
                          actions: [{ alertAction in self.setLoggingIn(false) }])
        showAlert(from: alert)
    }
}
