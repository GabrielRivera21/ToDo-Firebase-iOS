//
//  Task.swift
//  ToDoList
//
//  Created by Gabriel Rivera on 12/16/16.
//  Copyright © 2016 gabrielrivera. All rights reserved.
//

import Foundation
import Firebase

class Task: NSObject {

  var title: String
  var taskDescription: String
  var dueDate: Date
  var userId: String

  // Firebase props
  var key: String?
  var ref: FIRDatabaseReference?

  init(userId: String, title: String, taskDescription: String, dueDate: Date) {
    self.userId = userId
    self.title = title
    self.taskDescription = taskDescription
    self.dueDate = dueDate
  }

  init(snapshot: FIRDataSnapshot) {
    let snapshotValue = snapshot.value as! [String: AnyObject]
    self.title = snapshotValue["title"] as! String
    self.taskDescription = snapshotValue["description"] as! String
    self.userId = snapshotValue["userId"] as! String

    let dueDate = snapshotValue["dueDate"] as! String
    let dtFormat = DateFormatter()
    dtFormat.dateStyle = .short
    self.dueDate = dtFormat.date(from: dueDate)!

    self.key = snapshot.key
    self.ref = snapshot.ref
  }


  func toDictionary() -> Dictionary<String, String> {
    return ["userId": self.userId,
            "title": self.title,
            "description": self.taskDescription,
            "dueDate": formatDate(self.dueDate)]
  }

  func formatDate(_ date: Date) -> String {
    let dtFormat = DateFormatter()
    dtFormat.dateStyle = .short
    return dtFormat.string(from: date)
  }


}
