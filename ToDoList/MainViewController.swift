//
//  MainViewController.swift
//  ToDoList
//
//  Created by Gabriel Rivera on 12/21/16.
//  Copyright © 2016 gabrielrivera. All rights reserved.
//

import Foundation
import UIKit

import Firebase

import SwiftSpinner

protocol MainViewProtocol {
  func getQuery() -> FIRDatabaseQuery
  func getTable() -> UITableView
}

class MainViewController: UIViewController, MainViewProtocol,
                          UITableViewDelegate, UITableViewDataSource {

  internal func getTable() -> UITableView {
    print("Subclass has not implemented abstract method `getTable`!")
    abort()
  }

  internal func getQuery() -> FIRDatabaseQuery {
    print("Subclass has not implemented abstract method `getQuery`!")
    abort()
  }

  var taskList: Array<Task> = []
  var dbRef: FIRDatabaseReference!
  let cellViewIdentifier = "TaskCell"

  override func viewDidLoad() {
    super.viewDidLoad()
    self.getTable().delegate = self
    self.getTable().dataSource = self
    self.getTable().rowHeight = UITableViewAutomaticDimension
    self.getTable().estimatedRowHeight = 101

    self.configureDatabase()
    self.initializeList()
  }

  func configureDatabase() {
    self.dbRef = FIRDatabase.database().reference()

    // Listen for added tasks
    self.getQuery().observe(.childAdded, with: { (snapshot) -> Void in
      let task = Task.init(snapshot: snapshot)
      self.taskList.append(task)
      self.getTable().insertRows(
        at: [IndexPath(row: self.taskList.count - 1, section: 0)],
        with: UITableViewRowAnimation.automatic
      )
      self.getTable().reloadData()
    })

    // Listen for deleted tasks in the Firebase database
    self.getQuery().observe(.childRemoved, with: { (snapshot) -> Void in
      let index = self.getIndexOfTable(snapshot: snapshot)
      self.taskList.remove(at: index)
      self.getTable().deleteRows(
        at: [IndexPath(row: index, section: 0)],
        with: UITableViewRowAnimation.automatic
      )
      self.getTable().reloadData()
    })
  }

  func initializeList() {
    self.getQuery().observe(.value, with: { (snapshot) -> Void in
      var tasks: Array<Task> = []
      let userTasks = snapshot.children

      for item in userTasks {
        let task = Task.init(snapshot: item as! FIRDataSnapshot)
        tasks.append(task)
      }

      self.taskList = tasks
      self.getTable().reloadData()
    })
  }

  @objc
  func doneButtonClicked(_ sender: UIButton) {
    let task = self.taskList[sender.tag]
    let isCompleted = !task.isCompleted
    SwiftSpinner.show("Updating...")
    task.updateDone(isCompleted, dbRef: self.dbRef)
    SwiftSpinner.hide()
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

  func getIndexOfTable(snapshot: FIRDataSnapshot) -> Int {
    let task = Task.init(snapshot: snapshot)
    let index = self.taskList.index(where: { (currTask) in
      return task.key == currTask.key
    })
    return index!
  }

  private func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if self.taskList.isEmpty {
      let emptyLabel = UILabel(
        frame: CGRect(
          x: 0, y: 0, width: tableView.bounds.width, height: tableView.bounds.height
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

  @objc(tableView:cellForRowAtIndexPath:)
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

    if task.isCompleted! {
      cell.lblCompleted.text = "Completed"
      cell.lblCompleted.textColor = UIColor.green
      cell.btnDone.setTitle("Not Done", for: .normal)
    } else {
      cell.lblCompleted.text = "Not Completed"
      cell.lblCompleted.textColor = UIColor.red
      cell.btnDone.setTitle("Done", for: .normal)
    }

    cell.btnDone.tag = indexPath.row
    cell.btnDone.addTarget(self, action: #selector(MainViewController.doneButtonClicked(_:)),
                           for: .touchUpInside)

    return cell
  }

  @objc(tableView:commitEditingStyle:forRowAtIndexPath:)
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle,
                 forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      SwiftSpinner.show("Deleting...")
      let taskItem = self.taskList[indexPath.row]
      taskItem.delete(dbRef: self.dbRef)
      SwiftSpinner.hide()
    }
  }
}
