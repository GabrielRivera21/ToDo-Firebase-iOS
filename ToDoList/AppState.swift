//
//  AppState.swift
//  ToDoList
//
//  Created by Gabriel Rivera on 12/16/16.
//  Copyright © 2016 gabrielrivera. All rights reserved.
//

import Foundation


class AppState: NSObject {

  static let sharedInstance = AppState()

  var displayName: String?
  var profilePicUrl: String?
}
