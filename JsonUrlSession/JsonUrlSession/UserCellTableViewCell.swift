//
//  UserCellTableViewCell.swift
//  JsonUrlSession
//
//  Created by logo_dev_f1 on 26/6/24.
//

import UIKit

class UserCellTableViewCell: UITableViewCell {
    @IBOutlet weak var id: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var rate: UILabel!
    
    @IBOutlet weak var count: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
