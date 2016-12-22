//
//  FIRBaseModel.swift
//  ToDoList
//
//  Created by Gabriel Rivera on 12/21/16.
//  Copyright © 2016 gabrielrivera. All rights reserved.
//

import Foundation
import Firebase

class FIRBaseModel: NSObject {

  // Firebase props
  var key: String?
  var ref: FIRDatabaseReference?

  override init() {
    super.init()
  }

  init(snapshot: FIRDataSnapshot) {
    self.key = snapshot.key
    self.ref = snapshot.ref
  }

}
