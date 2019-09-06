//
//  TableViewController.swift
//  TodoList
//
//  Created by Fredrik Eilertsen on 7/29/18.
//  Copyright © 2018 Fredrik Eilertsen. All rights reserved.
//

import UIKit
import UserNotifications

class TodoListTableViewController: UITableViewController, CreateTodoItemDelegate, UIPopoverPresentationControllerDelegate, DeleteTodoItemsDelegate, EditTodoItemDelegate, CHeckBoxDelegate {
    
    private var isViewJustLoaded = false
    
    func deleteTodoItems(with priorities: [Bool]) {
        todoListInfo.todos = todoListInfo.todos.filter {
            if $0.priority == 0 {
                if (priorities[0]) {
                    if $0.dueDate.notificationId != "" {
                        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [$0.dueDate.notificationId])
                    }
                    return false
                } else {
                    return true
                }
            } else if $0.priority == 1 {
                if (priorities[1]) {
                    if $0.dueDate.notificationId != "" {
                        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [$0.dueDate.notificationId])
                    }
                    return false
                } else {
                    return true
                }
            } else if $0.priority == 2 {
                if (priorities[2]) {
                    if $0.dueDate.notificationId != "" {
                        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [$0.dueDate.notificationId])
                    }
                    return false
                } else {
                    return true
                }
            } else {
                return false
            }
        }
        self.tableView.reloadData()
        saveList()
    }
    
    
    func createTodoItem(with todoItem: TodoListInfo.TodoItem) {
        todoListInfo.todos.append(todoItem)
        sortList()
        self.tableView.reloadData()
        saveList()
    }
    
    func updateTodoItem(with todoItem: TodoListInfo.TodoItem, at index: Int) {
        todoListInfo.todos[index] = todoItem
        sortList()
        self.tableView.reloadData()
        saveList()
    }
    
    var todoListInfo: TodoListInfo = TodoListInfo(todoList: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: .zero)
        isViewJustLoaded = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !isViewJustLoaded {
            self.tableView.reloadData()
        }
        isViewJustLoaded = false
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if let url = try? FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
            ).appendingPathComponent("TodoList.json") {
            if let jsonData = try? Data(contentsOf: url), let savedTodoListInfo = TodoListInfo(json: jsonData) {
                todoListInfo = savedTodoListInfo
                sortList()
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if todoListInfo.todos.count == 0 {
            self.tableView.setEmptyMessage("Add tasks by tapping the plus-button.")
        } else {
            self.tableView.restore()
        }
        
        return todoListInfo.todos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let todoItem = todoListInfo.todos[indexPath.row]
        if todoItem.dueDate.notificationId == "" || notificationHasExpired(dueDate: todoItem.dueDate) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "todoCell", for: indexPath) as! TodoTableViewCell
            
            cell.descriptionLabel!.text = todoItem.description
            cell.descriptionLabel!.isEnabled = !todoItem.isCompleted
            
            setCellPriorityColor(priority: todoItem.priority, cell: cell)
            configureCellCheckbox(cell: cell, isCompleted: todoItem.isCompleted, row: indexPath.row)
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "todoNotificationCell", for: indexPath) as! TodoWithNotificationTableViewCell
            
            let calendar = Calendar(identifier: .gregorian)
            let components = DateComponents(year: todoItem.dueDate.year, month: todoItem.dueDate.month, day: todoItem.dueDate.day, hour: todoItem.dueDate.hour, minute: todoItem.dueDate.minute)
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM dd, yyyy 'at' hh:mm"
            let formattedDate = formatter.string(from: calendar.date(from: components)!)
            
            cell.notificationLabel!.text = "notify: \(formattedDate)"
            cell.descriptionLabel!.text = todoItem.description
            cell.descriptionLabel!.isEnabled = !todoItem.isCompleted
            cell.notificationLabel!.isEnabled = !todoItem.isCompleted
            
            setCellPriorityColor(priority: todoItem.priority, cell: cell)
            configureCellCheckbox(cell: cell, isCompleted: todoItem.isCompleted, row: indexPath.row)
            
            return cell
        }
    }
    
    private func setCellPriorityColor(priority: Int, cell: TodoTableViewCell) {
        if (priority == 0) {
            cell.backgroundColor = #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9568627451, alpha: 1)
        } else if (priority == 1) {
            cell.backgroundColor = #colorLiteral(red: 0.862745098, green: 0.8156862745, blue: 0.7529411765, alpha: 1)
        } else if (priority == 2) {
            cell.backgroundColor = #colorLiteral(red: 0.7529411765, green: 0.6980392157, blue: 0.5137254902, alpha: 1)
        }
    }
    
    private func configureCellCheckbox(cell: TodoTableViewCell, isCompleted: Bool, row: Int) {
        cell.checkBox.on = isCompleted
        cell.checkBox.tag = row
        cell.checkBoxDelegate = self
    }
    
    func checkBoxTap(with tag: Int) {
        let indexPath = IndexPath(row: tag, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as! TodoTableViewCell
        
        if (todoListInfo.todos[tag].dueDate.notificationId != "") {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [todoListInfo.todos[tag].dueDate.notificationId])
            todoListInfo.todos[tag].dueDate.notificationId = ""
            todoListInfo.todos[tag].dueDate.year = 0
            todoListInfo.todos[tag].dueDate.month = 0
            todoListInfo.todos[tag].dueDate.day = 0
            todoListInfo.todos[tag].dueDate.hour = 0
            todoListInfo.todos[tag].dueDate.minute = 0
        }
        
        todoListInfo.todos[tag].isCompleted = cell.checkBox.on

        sortList()
        self.tableView.reloadData()
    }
    
    private func notificationHasExpired(dueDate: TodoListInfo.DueDate) -> Bool {
        let components = DateComponents(year: dueDate.year, month: dueDate.month, day: dueDate.day, hour: dueDate.hour, minute: dueDate.minute)
        let someDateTime = Calendar.current.date(from: components)!
        return someDateTime.timeIntervalSinceNow.sign == .minus
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        // Row should not be selectable if the task is completed
        if (todoListInfo.todos[indexPath.row].isCompleted) {
            return nil
        }
        return indexPath
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "Edit TODO Item", sender: indexPath)
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let todoItem = todoListInfo.todos[indexPath.row]
            if todoItem.dueDate.notificationId != "" {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [todoItem.dueDate.notificationId])
            }
            todoListInfo.todos.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            saveList()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Add TODO Item" {
            if let vc = segue.destination as? EditTodoItemViewController {
                vc.createTodoItemDelegate = self
                vc.isNewItem = true
                vc.todoItem = TodoListInfo.TodoItem()
            }
        } else if segue.identifier == "Delete TODO items" {
            if let vc = segue.destination as? DeleteTodoItemsViewController {
                vc.deleteTodoItemsDelegate = self
                vc.popoverPresentationController?.delegate = self
            }
        } else if segue.identifier == "Edit TODO Item" {
            if let vc = segue.destination as? EditTodoItemViewController, let indexPath = sender as? IndexPath {
                vc.positionInTodoList = indexPath.row
                vc.todoItem = todoListInfo.todos[indexPath.row]
                vc.editTodoItemDelegate = self
            }
        }
    }

    func presentationController(_ controller: UIPresentationController,
    viewControllerForAdaptivePresentationStyle
    style: UIModalPresentationStyle) -> UIViewController? {
        let presented = controller.presentedViewController
        let navigationConroller = UINavigationController(rootViewController: presented)
        return navigationConroller
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    func sortList() {
        todoListInfo.todos.sort(by: {
            if($0.isCompleted != $1.isCompleted) {
                return !$0.isCompleted
            } else if($0.priority != $1.priority) {
                return $0.priority > $1.priority
            } else if ($0.description != $1.description) {
                return $0.description < $1.description
            } else {
                return true
            }
        })
    }
    
    func saveList() {
        if let json = todoListInfo.json {
            if let url = try? FileManager.default.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
                ).appendingPathComponent("TodoList.json") {
                do {
                    try json.write(to: url)
                } catch let error {
                    print("Couldn't save \(error)")
                }
            }
        }
    }

}

extension UITableView {
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = #colorLiteral(red: 0.2156862745, green: 0.2156862745, blue: 0.2156862745, alpha: 1)
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont.systemFont(ofSize: 40)
        messageLabel.sizeToFit()
        
        self.backgroundView = messageLabel;
        self.separatorStyle = .none;
    }
    
    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}
