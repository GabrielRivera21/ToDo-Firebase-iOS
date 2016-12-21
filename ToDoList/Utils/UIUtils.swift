//
//  UIUtils.swift
//  ToDoList
//
//  Created by Gabriel Rivera on 12/20/16.
//  Copyright © 2016 gabrielrivera. All rights reserved.
//

import Foundation
import UIKit

class ScrollUtils {

  var controller: UIViewController!
  var scrollView: UIScrollView!

  init(_ controller: UIViewController, scrollView: UIScrollView) {
    self.controller = controller
    self.scrollView = scrollView

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(adjustKeyboard),
      name: NSNotification.Name.UIKeyboardWillShow,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(adjustKeyboard),
      name: NSNotification.Name.UIKeyboardWillHide,
      object: nil
    )
  }

  @objc
  func adjustKeyboard(notification: Notification) {
    let userInfo = notification.userInfo!

    let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
    let keyboardViewEndFrame = controller.view.convert(keyboardScreenEndFrame,
                                                       from: controller.view.window)

    if notification.name == Notification.Name.UIKeyboardWillHide {
      self.scrollView?.contentInset = UIEdgeInsets.zero
    } else {
      self.scrollView?.contentInset = UIEdgeInsets(top: 0,
                                                   left: 0,
                                                   bottom: keyboardViewEndFrame.height,
                                                   right: 0)
    }

    self.scrollView?.scrollIndicatorInsets = self.scrollView.contentInset
  }

}
