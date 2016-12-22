//
//  User.swift
//  ToDoList
//
//  Created by Gabriel Rivera on 12/21/16.
//  Copyright © 2016 gabrielrivera. All rights reserved.
//

import Foundation
import Firebase

class User: FIRBaseModel {

  var id: String!
  var username: String!
  var email: String!

  init(id: String, email: String) {
    super.init()
    self.id = id
    self.email = email
    self.username = email.characters.split(separator: "@").map(String.init)[0]
  }

  override init(snapshot: FIRDataSnapshot) {
    super.init(snapshot: snapshot)
    let snapshotValue = snapshot.value as! [String: AnyObject]
    self.id = snapshotValue["id"] as! String
    self.username = snapshotValue["username"] as! String
    self.email = snapshotValue["email"] as! String
  }

  func toDictionary() -> Dictionary<String, Any> {
    return ["id": self.id,
            "username": self.username,
            "email": self.email]
  }
}
