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


class LoginViewController: UIViewController {

  @IBOutlet weak var txtEmail: UITextField!
  @IBOutlet weak var txtPassword: UITextField!
  @IBOutlet weak var btnLogin: UIButton!

  override func viewWillAppear(_ animated: Bool) {
    if let user = FIRAuth.auth()?.currentUser {
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

    // login
    FIRAuth.auth()?.signIn(withEmail: email, password: password) { (user, error) in
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
}
