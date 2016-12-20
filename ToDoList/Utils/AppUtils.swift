//
//  AppUtils.swift
//  ToDoList
//
//  Created by Gabriel Rivera on 12/15/16.
//  Copyright © 2016 gabrielrivera. All rights reserved.
//

import Foundation
import UIKit

class AppUtils {

  static func showMessage(controller: UIViewController, title: String, message: String) {
    let alert = UIAlertController(
      title: title,
      message: message,
      preferredStyle: UIAlertControllerStyle.alert
    )
    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
    controller.present(alert, animated: true, completion: nil)
  }

  static func showMessage(controller: UIViewController, message: String) {
    showMessage(controller: controller, title: "To Do", message: message)
  }

  static func showSuccessMessage(controller: UIViewController, message: String) {
    showMessage(controller: controller, title: "Success", message: message)
  }

  static func showErrorMessage(controller: UIViewController, message: String) {
    showMessage(controller: controller, title: "Error", message: message)
  }
}
