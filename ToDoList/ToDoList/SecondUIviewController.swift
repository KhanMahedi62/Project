//
//  SecondUIviewController.swift
//  ToDoList
//
//  Created by logo_dev_f1 on 30/6/24.
//

import UIKit

protocol SecondUIviewControllerDelegate{
    func tappImageView(toDoList: TodoItem)
//    func setingViewController(currentViewControl: SecondUIviewController)
}

class SecondUIviewController: UIViewController {

    @IBOutlet weak var secondControlViewButton: UIButton!
    
    @IBAction func backButton(_ sender: UIButton) {
        dismiss(animated: true)
    }
    @IBOutlet weak var labelText: UILabel!
    var secondDelegat : SecondUIviewControllerDelegate?
    var newToDo : TodoItem?
    func configure(toDoItem: TodoItem){
        newToDo = toDoItem
    }
    @IBAction func secondButton(_ sender: UIButton) {
        if let isCompleted = newToDo?.isCompleted{
            newToDo?.isCompleted = !isCompleted
        }
        
            if newToDo?.isCompleted == true{
                secondControlViewButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            }
            else{
                secondControlViewButton.setImage(UIImage(systemName: "heart"), for: .normal)
            }
        if let todo = newToDo{
            secondDelegat?.tappImageView(toDoList: todo)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(newToDo?.isCompleted ?? "nil")
        labelText.text = newToDo?.work
        if newToDo?.isCompleted == true{
            secondControlViewButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        }
        else{
            secondControlViewButton.setImage(UIImage(systemName: "heart"), for: .normal)
        }
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
