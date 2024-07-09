//
//  ViewController.swift
//  Clouser
//
//  Created by logo_dev_f1 on 20/6/24.
//

import UIKit

class ViewController: UIViewController {
    var button = UIButton(type: .system, primaryAction: UIAction(title: "Button Title", handler: { action -> Void in
    print("Button with title \(action.title) tapped!")
       
}))
    var button1 = UIButton(type: .system, primaryAction: UIAction(title: "mahedi khan", handler: {action -> Void in
        print("Button with tittle \(action.title) tapped!")
    }))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        button.frame = CGRect(x: 200, y: 250, width: 200, height: 50)
        view.addSubview(button)
        button1.frame = CGRect(x: 100, y: 100, width: 200, height: 50)
        view.addSubview(button1)
     
    }
    
 
   
   
    
 


}

