//
//  ViewController.swift
//  thread
//
//  Created by logo_dev_f1 on 23/6/24.
//

import UIKit
  
  
class ViewController: UIViewController {
  
  
    @IBOutlet weak var tableView: UITableView!
      
    let refreshControl = UIRefreshControl()
    var arr = Array<String>()
      
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        var n: Int = 2
        var value:Int = 1
  
  
        DispatchQueue.main.async {
            debugPrint("printing table of \(n)")
            for i in 1...10 {
                value = i
                  
                print(n*i)
            }
        }
  
  
        for i in 0...10 {
            n = i
            print("Value = " + n.description)
        }
  
  
        DispatchQueue.main.async {
            n = 9
            print(n)
        }
    }
}  
