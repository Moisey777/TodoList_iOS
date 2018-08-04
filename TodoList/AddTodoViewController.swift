//
//  AddTodoViewController.swift
//  TodoList
//
//  Created by Fredrik Eilertsen on 7/29/18.
//  Copyright © 2018 Fredrik Eilertsen. All rights reserved.
//

import UIKit

protocol CreateTodoItemDelegate: AnyObject {
    func createTodoItem(with todoItem: TodoListInfo.TodoItem)
}

class AddTodoViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    weak var createTodoItemDelegate: CreateTodoItemDelegate!

    @IBAction func addTodoItem(_ sender: Any) {
        guard let description = descriptionTextField.text else {
            return
        }
        createTodoItemDelegate.createTodoItem(with: TodoListInfo.TodoItem(description: description, priority: priorityPickerView.selectedRow(inComponent: 0)))
        if let navController = self.navigationController {
            navController.dismiss(animated: true)
        } else {
            presentingViewController?.dismiss(animated: true)
        }
    }
    
    @IBOutlet weak var addTodoButton: UIButton!
    @IBOutlet weak var priorityPickerView: UIPickerView!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var topLevelStackView: UIStackView!
    
    let priorities = ["Low priority", "Medium priority", "High priority"]
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if !(descriptionTextField.text?.isEmpty)! {
            addTodoButton.isEnabled = true
        } else {
            addTodoButton.isEnabled = false
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if self.navigationController != nil {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(cancelController))
        } else {
            let fittedSize = topLevelStackView.sizeThatFits(UILayoutFittingCompressedSize)
            preferredContentSize = CGSize(width: fittedSize.width + 30, height: fittedSize.height + 30)
        }
    }
    
    @objc func cancelController(sender: AnyObject) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return priorities.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return priorities[row]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        descriptionTextField.addTarget(self, action: #selector(AddTodoViewController.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
