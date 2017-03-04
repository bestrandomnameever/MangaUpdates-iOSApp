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
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var checkMarkImageView: UIImageView!
    @IBAction func onUsernameChange(_ sender: Any) {
        clearErrorField()
    }
    @IBAction func onPasswordChanged(_ sender: Any) {
        clearErrorField()
    }
    
    
    @IBAction func logInButtonPressed(_ sender: Any) {
        print(logInLoadingActivityIndicator.isAnimating.description)
        if isLoggedIn == true {
            logOut()
        }else {
            let username = usernameTextField.text!
            let password = passwordTextField.text!
            logIn(username: username, password: password)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        //logInLoadingActivityIndicator.stopAnimating()
        if let username = UserDefaults.standard.string(forKey: "username") {
            setScreenToLoggedInUser(username: username)
        } else {
            isLoggedIn = false
            self.title = "Log in"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func logIn(username: String, password: String) {
        logInLoadingActivityIndicator.startAnimating()
        view.endEditing(true)
        if username.isEmpty {
            errorLabel.text = "Username is empty"
        }else if password.isEmpty {
            errorLabel.text = "Password is empty"
        }else {
            self.clearErrorField()
            MangaUpdatesAPI.logIn(username: username, password: password, completionHandler: { (succes) in
                if succes {
                    self.setCorrectCookie()
                    self.setScreenToLoggedInUser(username: username)
                    //self.dismiss(animated: true, completion: nil)
                }else {
                    self.errorLabel.text = "Incorrect login"
                }
            })
        }
        self.logInLoadingActivityIndicator.stopAnimating()
    }
    
    private func setScreenToLoggedInUser(username: String) {
        isLoggedIn = true
        self.title = "Log out"
        titleLabel.text = "Hey " + username
        usernameTextField.text = username
        usernameTextField.textColor = UIColor.green
        usernameTextField.isUserInteractionEnabled = false
        passwordTextField.text = "password"
        usernameTextField.textColor = UIColor.green
        passwordTextField.isUserInteractionEnabled = false
        checkMarkImageView.isHidden = false
        logInButton.setTitle("Log out", for: .normal)
    }
    
    private func logOut() {
        isLoggedIn = false
        UserDefaults.standard.removeObject(forKey: "username")
        self.title = "Log In"
        titleLabel.text = "Login MangaUpdates"
        usernameTextField.text = ""
        usernameTextField.textColor = UIColor.black
        usernameTextField.isUserInteractionEnabled = true
        passwordTextField.text = ""
        passwordTextField.textColor = UIColor.black
        passwordTextField.isUserInteractionEnabled = true
        checkMarkImageView.isHidden = true
        logInButton.setTitle("Log in", for: .normal)
    }
    
    
    private func clearErrorField() {
        errorLabel.text = ""
    }
    
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        let username = usernameTextField.text!
        let password = passwordTextField.text!
        logIn(username: username, password: password)
        return true
    }
    
    private func setCorrectCookie() {
        let cookies = HTTPCookieStorage.shared.cookies!
        for cookie in cookies {
            if cookie.name == "secure_session" {
                let properties = [
                    HTTPCookiePropertyKey.name: cookie.name,
                    HTTPCookiePropertyKey.value: cookie.value,
                    HTTPCookiePropertyKey.domain: "www.mangaupdates.com",
                    HTTPCookiePropertyKey.path: cookie.path
                    ] as [HTTPCookiePropertyKey : Any]
                HTTPCookieStorage.shared.setCookie(HTTPCookie.init(properties: properties)!)
                print("cookie toegevoegd")
            }
        }
    }
    
}
