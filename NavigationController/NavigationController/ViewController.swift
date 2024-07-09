//
//  ViewController.swift
//  NavigationController
//
//  Created by logo_dev_f1 on 30/6/24.
//

import UIKit

class ViewController: UIViewController {

    @IBAction func detailsViewButton(_ sender: UIButton) {
        print("hi this is mahedi")
        let detV = self.storyboard?.instantiateViewController(identifier: "DetailedViewControler") as! DetailedViewControler
        self.navigationController?.pushViewController(detV, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

