//
//  ViewController.swift
//  JsonUrlSessionNew
//
//  Created by logo_dev_f1 on 25/6/24.
//

import UIKit

class ViewController: UIViewController {
    
    struct jsonObject{
        var userId : Int
        var id : Int
        var title : String
        var body : String
    }
    
    var arrayOfDictionaries: [jsonObject] = []
    func gettingData(completion: @escaping ([jsonObject]) -> Void) {
        if let url = URL(string: "https://jsonplaceholder.typicode.com/posts") {
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
                        for json in jsonData {
                            if let userId = json["userId"] as? Int,
                               let id = json["id"] as? Int,
                               let title = json["title"] as? String,
                               let body = json["body"] as? String {
                                let object = jsonObject(userId: userId, id: id, title: title, body: body)
                                self.arrayOfDictionaries.append(object)
                            }
                        }
                        completion(self.arrayOfDictionaries)
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
        gettingData(completion: { (arrayDictionary: [jsonObject]) in
            print(arrayDictionary[0].id)
        })
        
    }
    
    
}

