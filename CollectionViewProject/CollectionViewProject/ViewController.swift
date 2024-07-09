//
//  ViewController.swift
//  CollectionViewProject
//
//  Created by logo_dev_f1 on 8/7/24.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate {
    
    @IBOutlet weak var collecTionView : UICollectionView!
    let disPatchQueue = DispatchQueue.global(qos: .background)
    struct ProductRating : Decodable {
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
    
    struct Product : Decodable{
        let id : Int?
        let title : String?
        let price : Double?
        let description : String?
        let category : String?
        let image : String?
        let rating : ProductRating?
        
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
            rating = try values.decodeIfPresent(ProductRating.self, forKey: .rating)
        }
        
    }
    
    var productList = [Product]()
    
    func gettingProduct() {
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
                    let responseData = try JSONDecoder().decode([Product].self, from: data)
                    self.productList.append(contentsOf: responseData)
                    DispatchQueue.main.async {
                        self.collecTionView.reloadData()
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
        collecTionView.delegate = self
        collecTionView.dataSource = self
        gettingProduct()
        // Do any additional setup after loading the view.
    }
    
    
}

extension ViewController : UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return productList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ProductCell
        let modelUser = productList[indexPath.row]
        if modelUser.id != nil{
            
            cell.titleLabel.text = modelUser.title
            cell.priceLabel.text = (modelUser.price == nil) ? "" : "\(modelUser.price!)"
            cell.ratingLabel.text = "\( modelUser.rating?.rate ?? 0)(\( modelUser.rating?.count ?? 0))"
            
            if let imageUrlString = modelUser.image{
                cell.imageViewCell.imageDownloading(imageUrlString)
            }
            
        }
        
        return cell
    }
}

extension ViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //let bounds = collectionView.bounds
        let widthVal = self.view.frame.width
        let cellsize = widthVal/2
        var heightOffset = 10.0
        if traitCollection.verticalSizeClass == .regular && traitCollection.horizontalSizeClass == .regular{
            heightOffset = 0.0
        }
        return CGSize(width: cellsize-5   , height: cellsize + heightOffset)
    }
}
//kingfisher library
//package manager

extension UIImageView{
    static var disPatchQueue = DispatchQueue.global(qos: .background)
    static var imageToCache = NSCache<NSString, UIImage>()
    func imageDownloading(_ imageUrlString: String){
        self.image = nil
        if let chacheImage = UIImageView.imageToCache.object(forKey: NSString(string: imageUrlString)){
            self.image = chacheImage
        }
        UIImageView.disPatchQueue.async {
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
                            self.image = image
                            UIImageView.imageToCache.setObject(image, forKey: NSString(string: imageUrlString))
                        }
                    } else {
                        print("Unable to create image from data")
                    }
                }
                task.resume()
            }
            
        }
    }
}

