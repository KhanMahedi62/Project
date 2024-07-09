//
//  ViewController.swift
//  tableView
//
//  Created by logo_dev_f1 on 26/6/24.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
    }


}

extension ViewController: ui

