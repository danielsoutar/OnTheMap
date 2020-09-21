//
//  LoginViewControllerKeyboard.swift
//  OnTheMap
//
//  Created by Daniel Soutar on 20/09/2020.
//  Copyright © 2020 Daniel Soutar. All rights reserved.
//

import Foundation
import UIKit

extension LoginViewController : UITextFieldDelegate {
    
    // MARK: - Setting Up Text Fields

    func configureTextFields() {
        setupTextField(self.emailTextField)
        setupTextField(self.passwordTextField)
    }

    func setupTextField(_ textField: UITextField) {
        textField.delegate = self
        textField.autocorrectionType = .no
    }

    // MARK: - Keyboard-View manipulation
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        print("keyboardWillShow() executing")
        if self.eitherTextFieldIsEditing {
            self.view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        print("keyboardWillHide() executing")
        self.view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification: NSNotification) -> CGFloat {
        print("getKeyboardHeight() executing")
        let userInfo = notification.userInfo
        if let keyboardSize = userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            print(keyboardSize.cgRectValue.height)
            return keyboardSize.cgRectValue.height
        } else {
            print("This should never print - calling getKeyboardHeight(_:) without a valid userInfo dictionary.")
            return 0.0
        }
    }
    
    // MARK: - (Un)Subscribing to NSNotifications for Keyboard
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        print("Subscribed to keyboard notifications")
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillShowNotification,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillHideNotification,
                                                  object: nil)
        print("Unsubscribed to keyboard notifications")
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Assign flag to whether either of the text fields are editing, since
        // this is used to configure the keyboard-view manipulation.
        // Although equality between text fields can be risky (many fields beside raw
        // text also need to compare equal), this is safe since the only objects
        // that call this are manipulated in the LoginViewController.
        print("textFieldDidBeginEditing() executing")
        self.eitherTextFieldIsEditing = textField == self.emailTextField ||
            textField == self.passwordTextField
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.passwordTextField {
            self.loginTapped(textField)
        }
        return textField.resignFirstResponder()
    }
}
