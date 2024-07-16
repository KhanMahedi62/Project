//
//  DisplayImageViewController.swift
//  Photos Apps
//
//  Created by logo_dev_f1 on 15/7/24.
//

import UIKit

class DisplayImageViewController: UIViewController {

    @IBOutlet weak var displayImageView: UIImageView!
    var image : UIImage?
    func configure(image: UIImage){
        self.image = image
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async{
            self.displayImageView.image = self.image
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
