//
//  MyTasksListViewController.swift
//  ToDoList
//
//  Created by Gabriel Rivera on 12/21/16.
//  Copyright © 2016 gabrielrivera. All rights reserved.
//

import Foundation
import Firebase
import UIKit


class MyTasksListViewController: MainViewController {
  
  @IBOutlet weak var tblTasks: UITableView!

  override func getTable() -> UITableView {
    return self.tblTasks
  }

  override func getQuery() -> FIRDatabaseQuery {
    let userId = FIRAuth.auth()?.currentUser?.uid
    return self.dbRef.child("user-tasks").child(userId!).queryOrderedByKey()
  }
  
  @IBAction func doSignOut(_ sender: Any) {
    self.signOut()
  }
}
