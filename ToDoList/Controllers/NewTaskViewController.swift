//
//  NewTaskViewController.swift
//  ToDoList
//
//  Created by Gabriel Rivera on 12/16/16.
//  Copyright © 2016 gabrielrivera. All rights reserved.
//

import Foundation
import UIKit

import Firebase


class NewTaskViewController: UIViewController {
  var dbRef: FIRDatabaseReference!
  var scrollUtils: ScrollUtils!

  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var txtTitle: UITextField!
  @IBOutlet weak var txtDescription: UITextField!
  @IBOutlet weak var pickerDueDate: UIDatePicker!

  override func viewDidLoad() {
    super.viewDidLoad()
    self.dbRef = FIRDatabase.database().reference()
    self.scrollUtils = ScrollUtils.init(self, scrollView: scrollView)
  }

  @IBOutlet weak var btnBack: UIButton!
  @IBOutlet weak var btnAdd: UIButton!

  @IBAction func doBack(_ sender: Any) {
    self.dismiss(animated: true)
  }

  @IBAction func doAddTask(_ sender: Any) {
    let key = self.dbRef.child("tasks").childByAutoId().key

    let userID = FIRAuth.auth()?.currentUser?.uid
    let title = self.txtTitle.text!
    let desc = self.txtDescription.text!
    let dueDate = self.pickerDueDate.date

    let task = Task(userId: userID!, title: title, taskDescription: desc, dueDate: dueDate)
    let taskDict = task.toDictionary()

    let childUpdates = ["/tasks/\(key)": taskDict,
                        "/user-tasks/\(userID!)/\(key)": taskDict]

    self.dbRef.updateChildValues(childUpdates)
    self.resetForm()
    self.dismiss(animated: true)
  }

  func resetForm() {
    self.txtTitle.text = ""
    self.txtDescription.text = ""
    self.pickerDueDate.setDate(Date(), animated: true)
  }

}
