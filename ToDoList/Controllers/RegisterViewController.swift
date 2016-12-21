//
//  RegisterViewController.swift
//  ToDoList
//
//  Created by Gabriel Rivera on 12/14/16.
//  Copyright © 2016 gabrielrivera. All rights reserved.
//

import Foundation
import UIKit

import Firebase

class RegisterViewController: UIViewController {

  var dbRef: FIRDatabaseReference!
  var scrollUtil: ScrollUtils!

  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var contentView: UIView!

  @IBOutlet weak var txtEmail: UITextField!
  @IBOutlet weak var txtPassword: UITextField!
  @IBOutlet weak var txtConfirmPassword: UITextField!

  @IBOutlet weak var btnRegister: UIButton!
  @IBOutlet weak var btnBack: UIButton!

  override func viewDidLoad() {
    super.viewDidLoad()
    dbRef = FIRDatabase.database().reference()
    self.scrollUtil = ScrollUtils.init(self, scrollView: self.scrollView)
  }

  @IBAction func register(_ sender: Any) {
    let password = txtPassword.text!
    let confirmPassword = txtConfirmPassword.text!
    let email = txtEmail.text!

    if !isValidData(email: email, password1: password, password2: confirmPassword) {
      AppUtils.showErrorMessage(controller: self, message: "There are invalid fields.")
      return
    }

    // create the user
    FIRAuth.auth()?.createUser(withEmail: email, password: password) { (user, error) in
      if let error = error {
        AppUtils.showErrorMessage(controller: self, message: error.localizedDescription)
        return
      }

      AppUtils.showSuccessMessage(controller: self, message: "User \(email) has been created")
      self.dismiss(animated: true)
    }
  }

  @IBAction func back(_ sender: Any) {
    dismiss(animated: true)
  }

  func isValidData(email: String, password1: String, password2: String) -> Bool {
    guard email != "" else { return false }
    guard password1 != "" else { return false }
    guard password2 != "" else { return false }
    guard password1 == password2 else { return false }
    guard email.contains("@") else { return false }
    return true
  }

}
