//
//  ViewController.swift
//  JsonUrlSession
//
//  Created by logo_dev_f1 on 25/6/24.
//

import UIKit

class ViewController: UIViewController{
    
    @IBOutlet var tableView: UITableView!
    
    struct Rating : Decodable {
        let rate : Double?
        let count : Int?

        enum CodingKeys: String, CodingKey {

            case rate = "rate"
            case count = "count"
        }

        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            rate = try values.decodeIfPresent(Double.self, forKey: .rate)
            count = try values.decodeIfPresent(Int.self, forKey: .count)
        }

    }
    
    struct dataFromJson : Decodable{
        let id : Int?
        let title : String?
        let price : Double?
        let description : String?
        let category : String?
        let image : String?
        let rating : Rating?

        enum CodingKeys: String, CodingKey {

            case id = "id"
            case title = "title"
            case price = "price"
            case description = "description"
            case category = "category"
            case image = "image"
            case rating = "rating"
        }

        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            id = try values.decodeIfPresent(Int.self, forKey: .id)
            title = try values.decodeIfPresent(String.self, forKey: .title)
            price = try values.decodeIfPresent(Double.self, forKey: .price)
            description = try values.decodeIfPresent(String.self, forKey: .description)
            category = try values.decodeIfPresent(String.self, forKey: .category)
            image = try values.decodeIfPresent(String.self, forKey: .image)
            rating = try values.decodeIfPresent(Rating.self, forKey: .rating)
        }

    }
    
    var jsonData = [dataFromJson]()
    
    func gettingData() {
        if let url = URL(string: "https://fakestoreapi.com/products") {
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                // Handle response, data, and error here
                if let error = error {
                    print("Error: \(error)")
                    return
                }
                
                guard let data = data else {
                    print("No data received")
                    return
                }
                
                do {
                    let responseData = try JSONDecoder().decode([dataFromJson].self, from: data)
                    self.jsonData.append(contentsOf: responseData)
                    DispatchQueue.main.async{
                        self.tableView.reloadData()
                    }

                } catch {
                    print("Error decoding JSON: \(error.localizedDescription)")
                }
            }
            
            task.resume()
        } else {
            print("Invalid URL")
        }
    }
    
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "UserCellTableViewCell", bundle: nil), forCellReuseIdentifier: "UserCell")
        gettingData()
    }
}


extension ViewController : UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        (jsonData.count)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as? UserCellTableViewCell
        var index = indexPath.row * 2
        print(indexPath.row)
        print(indexPath)
        let modelUser = jsonData[indexPath.row]
        print("mahedi khan")
        if let id = modelUser.id{
            cell?.id.text = "\(id)"
            cell?.title.text = modelUser.title
            cell?.price.text = "\(modelUser.price!)"
            let backgroundQueue = DispatchQueue.global(qos: .background)
            let imageUrlString = modelUser.image!
            backgroundQueue.async {
                print("khanmahedi")
                if let url = URL(string: imageUrlString) {
                    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                        if let error = error {
                            print("Error fetching image: \(error)")
                            return
                        }
                        
                        guard let data = data else {
                            print("No image data received")
                            return
                        }
                        if let image = UIImage(data: data) {
                            DispatchQueue.main.async {
                                cell?.userImageView.image = image
                            }
                        } else {
                            print("Unable to create image from data")
                        }
                    }
                    task.resume()
                }
            }
            
            cell?.rate.text = "\(modelUser.rating!.rate!)"
            cell?.count.text = "\(modelUser.rating!.count!)"
        }
            
        
        return cell!
    }
}
