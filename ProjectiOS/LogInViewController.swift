//
//  LogInViewController.swift
//  ProjectiOS
//
//  Created by Anthony on 02/03/2017.
//  Copyright © 2017 Anthony. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController, UITextFieldDelegate {
    
    var isLoggedIn : Bool!
    @IBOutlet weak var logInLoadingActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var checkMarkImageView: UIImageView!
    @IBAction func closeLogInScreen(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func onUsernameChange(_ sender: Any) {
        clearErrorField()
    }
    @IBAction func onPasswordChanged(_ sender: Any) {
        clearErrorField()
    }
    
    
    
    @IBAction func logIn(_ sender: Any) {
        if isLoggedIn == true {
            UserDefaults.standard.removeObject(forKey: "username")
            usernameTextField.text = ""
            passwordTextField.text = ""
            checkMarkImageView.isHidden = true
            logInButton.setTitle("Log in", for: .normal)
        }else {
            logInLoadingActivityIndicator.isHidden = false
            view.endEditing(true)
            let username = usernameTextField.text!
            let password = passwordTextField.text!
            if username.isEmpty {
                errorLabel.text = "Username is empty"
            }else if password.isEmpty {
                errorLabel.text = "Password is empty"
            }else {
                MangaUpdatesAPI.logIn(username: username, password: password, completionHandler: { (succes) in
                    self.logInLoadingActivityIndicator.isHidden = true
                    if succes {
                        self.errorLabel.text = ""
                        self.checkMarkImageView.isHidden = false
                        self.dismiss(animated: true, completion: nil)
                    }else {
                        self.errorLabel.text = "Incorrect login"
                    }
                })
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        if let username = UserDefaults.standard.string(forKey: "username") {
            isLoggedIn = true
            usernameTextField.text = username
            passwordTextField.text = "password"
            logInButton.setTitle("Log out", for: .normal)
            checkMarkImageView.isHidden = false
        } else {
            isLoggedIn = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func clearErrorField() {
        errorLabel.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == passwordTextField {
            logIn(passwordTextField)
        }
        view.endEditing(true)
        return true
    }
    
    
    
}
