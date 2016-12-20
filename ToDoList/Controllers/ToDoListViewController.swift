//
//  TodoListViewController.swift
//  ToDoList
//
//  Created by Gabriel Rivera on 12/13/16.
//  Copyright © 2016 gabrielrivera. All rights reserved.
//

import Foundation
import UIKit

import Firebase
import FirebaseDatabase

class TodoListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

  var taskList: Array<Task> = []
  var dbRef: FIRDatabaseReference!
  let cellViewIdentifier = "TaskCell"

  @IBOutlet weak var btnAdd: UIButton!
  @IBOutlet weak var tblTasks: UITableView!
  @IBOutlet weak var btnSignOut: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.tblTasks.delegate = self
    self.tblTasks.dataSource = self
    self.tblTasks.rowHeight = UITableViewAutomaticDimension
    self.tblTasks.estimatedRowHeight = 80

    configureDatabase()
    initializeList()
  }

  func configureDatabase() {
    dbRef = FIRDatabase.database().reference()

    // Listen for added tasks
    dbRef.observe(.childAdded, with: { (snapshot) -> Void in
      let task = Task.init(snapshot: snapshot)
      self.taskList.append(task)
      self.tblTasks.insertRows(
        at: [IndexPath(row: self.taskList.count - 1, section: 0)],
        with: UITableViewRowAnimation.automatic
      )
      self.tblTasks.reloadData()
    })

    // Listen for deleted tasks in the Firebase database
    dbRef.observe(.childRemoved, with: { (snapshot) -> Void in
      let index = self.tblTasks.index(ofAccessibilityElement: snapshot)
      self.taskList.remove(at: index)

      self.tblTasks.deleteRows(
        at: [IndexPath(row: index, section: 0)],
        with: UITableViewRowAnimation.automatic
      )

      self.tblTasks.reloadData()
    })
  }

  func initializeList() {
    dbRef.child("tasks").observe(.value, with: { (snapshot) -> Void in
      var tasks: Array<Task> = []

      for item in snapshot.children {
        let task = Task.init(snapshot: item as! FIRDataSnapshot)
        tasks.append(task)
      }

      self.taskList = tasks
      self.tblTasks.reloadData()
    })
  }

  func signOut() {
    let firebaseAuth = FIRAuth.auth()

    do {
      try firebaseAuth?.signOut()
      _ = self.navigationController?.popViewController(animated: true)
    } catch let signOutError as NSError {
      AppUtils.showErrorMessage(
        controller: self,
        message: "Error signing out: \(signOutError.localizedDescription)"
      )
    }
  }

  @IBAction func doSignOut(_ sender: Any) {
    self.signOut()
  }

  private func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if self.taskList.isEmpty {
      let emptyLabel = UILabel(
        frame: CGRect(
          x: 0, y: 0, width: self.tblTasks.bounds.width, height: self.tblTasks.bounds.height
        )
      )
      emptyLabel.text = "There are no tasks to display"
      emptyLabel.textAlignment = .center
      tableView.backgroundView = emptyLabel
      tableView.separatorStyle = .none
    } else {
      tableView.backgroundView = nil
      tableView.separatorStyle = .singleLine
    }
    return self.taskList.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(
      withIdentifier: self.cellViewIdentifier,
      for: indexPath
    ) as! TaskCell

    // adding task info
    let task = self.taskList[indexPath.row]
    cell.lblTitle.text = task.title
    cell.lblDueDate.text = task.formatDate(task.dueDate)
    cell.lblDescription.text = task.taskDescription
    cell.lblDescription.sizeToFit()

    return cell
  }

  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle,
                 forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      let taskItem = self.taskList[indexPath.row]
      taskItem.ref?.removeValue()
    }
  }
}
