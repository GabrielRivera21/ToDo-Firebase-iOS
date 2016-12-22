//
//  Task.swift
//  ToDoList
//
//  Created by Gabriel Rivera on 12/16/16.
//  Copyright © 2016 gabrielrivera. All rights reserved.
//

import Foundation
import Firebase

class Task: FIRBaseModel {

  var title: String!
  var taskDescription: String!
  var dueDate: Date!
  var userId: String!
  var isCompleted: Bool!

  init(userId: String, title: String, taskDescription: String, dueDate: Date) {
    super.init()
    self.userId = userId
    self.title = title
    self.taskDescription = taskDescription
    self.dueDate = dueDate
    self.isCompleted = false
  }

  override init(snapshot: FIRDataSnapshot) {
    super.init(snapshot: snapshot)
    let snapshotValue = snapshot.value as! [String: AnyObject]
    self.assignSnapshotValues(snapshotValue: snapshotValue)
  }

  func assignSnapshotValues(snapshotValue: [String: AnyObject]) {
    self.title = snapshotValue["title"] as! String
    self.taskDescription = snapshotValue["description"] as! String
    self.userId = snapshotValue["userId"] as! String
    self.isCompleted = snapshotValue["isCompleted"] as! Bool

    let dueDate = snapshotValue["dueDate"] as! String
    let dtFormat = DateFormatter()
    dtFormat.dateStyle = .short
    self.dueDate = dtFormat.date(from: dueDate)!
  }

  func toDictionary() -> Dictionary<String, Any> {
    return ["userId": self.userId,
            "title": self.title,
            "description": self.taskDescription,
            "dueDate": formatDate(self.dueDate),
            "isCompleted": self.isCompleted]
  }

  func formatDate(_ date: Date) -> String {
    let dtFormat = DateFormatter()
    dtFormat.dateStyle = .short
    return dtFormat.string(from: date)
  }

  func updateDone(_ isComplete: Bool, dbRef: FIRDatabaseReference) {
    let updateDone = ["/tasks/\(self.key!)/isCompleted": isComplete,
                      "/user-tasks/\(self.userId!)/\(self.key!)/isCompleted": isComplete]
    dbRef.updateChildValues(updateDone)
  }

  func delete(dbRef: FIRDatabaseReference) {
    let deleteTasks: [String: AnyObject?] =
                      ["/tasks/\(self.key!)": nil,
                       "/user-tasks/\(self.userId!)/\(self.key!)": nil]
    dbRef.updateChildValues(deleteTasks)
  }

}
