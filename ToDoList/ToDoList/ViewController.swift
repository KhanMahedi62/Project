//
//  ViewController.swift
//  ToDoList
//
//  Created by logo_dev_f1 on 27/6/24.
//

import UIKit
struct TodoItem{
      var work: String
      var ind : Int
      var isCompleted: Bool
  }



class ViewController: UIViewController, UITableViewDelegate {
    var cnt : Int = 0
    var flag : Bool = false
  
    var todoListItems: [TodoItem] = []

    func apendBro(){
       
        for i in 1...50 {
            if i % 2 == 0 {
                todoListItems.append(TodoItem(work: "Hi this is khanmaheid", ind: i - 1, isCompleted: false))
            } else {
                todoListItems.append(TodoItem(work: "lsjflkjsk ljslkdjflksd nflksjflk", ind: i - 1, isCompleted: false))
            }
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "UserCell")
        apendBro()
    }

}

extension ViewController{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let secondViewController = storyboard?.instantiateViewController(withIdentifier: "SecondUIviewController") as! SecondUIviewController
        secondViewController.secondDelegat = self
        secondViewController.configure(toDoItem: todoListItems[indexPath.row])
        secondViewController.modalPresentationStyle = .fullScreen
//        secondViewController.modalTransitionStyle = .flipHorizontal
        present(secondViewController, animated: true)
//        self.navigationController?.pushViewController(secondViewController, animated: true)
    }
}

extension ViewController : UITableViewDataSource, MyTableViewCellDelegate , SecondUIviewControllerDelegate{
    func tappImageView(toDoList: TodoItem) {
        todoListItems[toDoList.ind] = toDoList
        let ind : IndexPath = [0, toDoList.ind]
        tableView.reloadRows(at: [ind], with: .none)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoListItems.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! TableViewCell
        cell.configure(todoListItems[indexPath.row])
        cell.tableViewCellDelegate = self
        return cell
    }
    func didTapButton(toDoItem : TodoItem) {
        todoListItems[toDoItem.ind] = toDoItem
    }
}

