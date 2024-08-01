//
//  ImageCollectionViewCell.swift
//  Photos Apps
//
//  Created by logo_dev_f1 on 31/7/24.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    
    func configure(image : UIImage){
        imageView.image = image
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        print("hi i am intializing ")
        // Initialization code
    }
    
}
