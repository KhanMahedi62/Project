//
//  ViewController.swift
//  JsonUrlSessionNew
//
//  Created by logo_dev_f1 on 25/6/24.
//

import UIKit

class ViewController: UIViewController {
    
  
    
    var arrayOfDictionaries: [[String: Any]] = []
    func gettingData() {
        if let url = URL(string: "https://fakestoreapi.com/products") {
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                
                if let error = error {
                    print("Error: \(error)")
                    return
                }
                
                guard let data = data else {
                    print("No data received")
                    return
                }
                
                do {
                    if let jsonData = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                        func traverseJSON(json: Any, indent: String = "") {
                               if let dict = json as? [String: Any] {
                                   for (key, value) in dict {
                                       if let nestedDict = value as? [String: Any] {
                                           // Handle nested dictionary
                                           print("\(indent)\(key):")
                                           traverseJSON(json: nestedDict, indent: indent + "  ")
                                       } else if let array = value as? [Any] {
                                           // Handle array
                                           print("\(indent)\(key):")
                                           for item in array {
                                               traverseJSON(json: item, indent: indent + "  ")
                                           }
                                       } else {
                                           // Handle leaf values
                                           print("\(indent)\(key): \(value)")
                                       }
                                   }
                               } else {
                                   // Handle non-dictionary top-level JSON
                                   print("\(json)")
                               }
                           }
                           
                           // Start traversing the JSON from the top-level dictionary
                           traverseJSON(json: jsonData)
                        
                    } else {
                        
                        print("jsonData is not a valid array of dictionaries")
                    }
                } catch {
                    print("Error deserializing JSON: \(error)")
                }
                
            }
            
            task.resume()
        } else {
            print("Invalid URL")
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        gettingData()
        
    }
    
    
}


