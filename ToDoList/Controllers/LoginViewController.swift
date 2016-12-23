//
//  LoginViewController.swift
//  ToDoList
//
//  Created by Gabriel Rivera on 12/14/16.
//  Copyright © 2016 gabrielrivera. All rights reserved.
//

import Foundation
import UIKit

import Firebase
import GoogleSignIn

import SwiftSpinner

class LoginViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {

  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var contentView: UIView!

  var scrollUtil: ScrollUtils!
  var dbRef: FIRDatabaseReference!

  @IBOutlet weak var txtEmail: UITextField!
  @IBOutlet weak var txtPassword: UITextField!
  @IBOutlet weak var btnLogin: UIButton!
  @IBOutlet weak var btnGoogleLogin: GIDSignInButton!
  
  override func viewWillAppear(_ animated: Bool) {
    if let user = FIRAuth.auth()?.currentUser {
      self.signedIn(user)
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setupSocialSignIn()
    scrollUtil = ScrollUtils.init(self, scrollView: self.scrollView)
    self.dbRef = FIRDatabase.database().reference()
  }

  // Sets up all of the supported Social Accounts
  func setupSocialSignIn() {
    GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
    GIDSignIn.sharedInstance().delegate = self
    GIDSignIn.sharedInstance().uiDelegate = self
  }

  func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
    if let error = error {
      AppUtils.showErrorMessage(controller: self, message: error.localizedDescription)
      return
    }

    guard let authentication = user.authentication else { return }
    let credential = FIRGoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                      accessToken: authentication.accessToken)

    SwiftSpinner.show("Logging in...")

    FIRAuth.auth()?.signIn(with: credential) { (user, error) in
      SwiftSpinner.hide()
      if let error = error {
        AppUtils.showErrorMessage(controller: self, message: error.localizedDescription)
        return
      }
      self.createUserInDb(user)
      self.signedIn(user)
    }
  }

  @IBAction func login(_ sender: Any) {
    let email = txtEmail.text!
    let password = txtPassword.text!

    // check for errors
    if let errorMsg = validateDataAndGetErrors(email: email, password: password) {
      AppUtils.showErrorMessage(controller: self, message: errorMsg)
      return
    }

    SwiftSpinner.show("Logging in...")

    // login
    FIRAuth.auth()?.signIn(withEmail: email, password: password) { (user, error) in
      SwiftSpinner.hide()
      if let error = error {
        AppUtils.showErrorMessage(controller: self, message: error.localizedDescription)
        return
      }
      self.signedIn(user)
    }
  }

  func signedIn(_ user: FIRUser?) {
    txtEmail.text = ""
    txtPassword.text = ""
    self.performSegue(withIdentifier: Constants.Segues.ShowMainView, sender: nil)
  }

  func validateDataAndGetErrors(email: String, password: String) -> String? {
    guard txtEmail.text! != "" else { return "Please provide an email." }
    guard txtPassword.text != "" else { return "Please provide a Password" }
    return nil
  }

  func createUserInDb(_ user: FIRUser?) {
    if let user = user {
      let dbUser = User.init(id: user.uid, email: user.email!)
      let userDict = dbUser.toDictionary()
      let childUpdates = ["/users/\(user.uid)": userDict]
      self.dbRef.updateChildValues(childUpdates)
    }
  }
}
