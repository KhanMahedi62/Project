//
//  TableViewCell.swift
//  ToDoList
//
//  Created by logo_dev_f1 on 27/6/24.
//

import UIKit

protocol MyTableViewCellDelegate : AnyObject{
    func didTapButton(toDoItem : TodoItem)
}

class TableViewCell: UITableViewCell {

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var labelText: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    var tableViewCellDelegate : MyTableViewCellDelegate!
    var indexPath : IndexPath?
    var isCompleted : Bool = false
    var toDoItem : TodoItem!
    func configure(_ todoListItem : TodoItem){
        labelText.text = todoListItem.work
        isCompleted = todoListItem.isCompleted
        toDoItem = todoListItem
        if isCompleted == true {
            button.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        }
        else{
            button.setImage(UIImage(systemName: "heart"), for: .normal)
        }
    }
    
    @IBAction func buttonClick(_ sender: UIButton) {
        isCompleted = !isCompleted
        toDoItem.isCompleted = isCompleted
        if isCompleted == true {
            button.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        }
        else{
            button.setImage(UIImage(systemName: "heart"), for: .normal)
        }
        tableViewCellDelegate.didTapButton(toDoItem: toDoItem)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
