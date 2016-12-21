//
//  TaskCell.swift
//  ToDoList
//
//  Created by Gabriel Rivera on 12/19/16.
//  Copyright © 2016 gabrielrivera. All rights reserved.
//

import Foundation
import UIKit


class TaskCell: UITableViewCell {

  @IBOutlet weak var lblTitle: UILabel!
  @IBOutlet weak var lblDueDate: UILabel!
  @IBOutlet weak var lblDescription: UILabel!
  @IBOutlet weak var lblCompleted: UILabel!
  @IBOutlet weak var btnDone: UIButton!

}
