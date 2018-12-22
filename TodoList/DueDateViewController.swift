//
//  DueDateViewController.swift
//  TodoList
//
//  Created by Fredrik Eilertsen on 12/21/18.
//  Copyright © 2018 Fredrik Eilertsen. All rights reserved.
//

import UIKit
import UserNotifications

protocol NotificationDelegate: AnyObject {
    func prepareAddNotification(with date: Date)
    func prepareRemoveNotification()
}

class DueDateViewController: UIViewController {
    
    weak var notificationDelegate: NotificationDelegate!

    @IBOutlet weak var removeDueDateButton: UIButton!
    @IBOutlet weak var addDueDateButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    var notificationDate : TodoListInfo.DueDate?
    
    @IBAction func removeDueDate(_ sender: Any) {
        notificationDelegate.prepareRemoveNotification()
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addDueDate(_ sender: Any) {
        notificationDelegate.prepareAddNotification(with: datePicker.date)
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let dueDate = notificationDate {
            let calendar = Calendar(identifier: .gregorian)
            let components = DateComponents(year: dueDate.year, month: dueDate.month, day: dueDate.day, hour: dueDate.hour, minute: dueDate.minute)
            datePicker.setDate(calendar.date(from: components)!, animated: false)
        } else {
            datePicker.minimumDate = Date()
        }
    }
}
