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

class TodoListViewController: MainViewController {

  @IBOutlet weak var btnAdd: UIButton!
  @IBOutlet weak var tblTasks: UITableView!
  @IBOutlet weak var btnSignOut: UIButton!
  
  override func getTable() -> UITableView {
    return self.tblTasks
  }

  override func getQuery() -> FIRDatabaseQuery {
    return self.dbRef.child("tasks")
  }

  @IBAction func doSignOut(_ sender: Any) {
    self.signOut()
  }
  
}
