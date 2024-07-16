//
//  DisplayViewController.swift
//  Photos Apps
//
//  Created by logo_dev_f1 on 14/7/24.
//

import UIKit
import Photos
import AVFoundation
import AVKit
class DisplayViewController: UIViewController {
    let backgroundQueue = DispatchQueue.global(qos: .background)
    var playerViewController: AVPlayerViewController?
    var imageCaching = NSCache<NSString, UIImage>()
    let imageManager = PHCachingImageManager()
    @IBOutlet weak var collectionView: UICollectionView!
    var image = [PHAsset]()
    
    @IBOutlet weak var viedioLabel: UILabel!
    func configure(image : [PHAsset]){
        self.image = image
        print("into Navigation")
        print(self.image.count)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
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

extension DisplayViewController{
    func fetchVideoDuration(for asset: PHAsset, completion: @escaping (TimeInterval?) -> Void) {
        PHImageManager.default().requestAVAsset(forVideo: asset, options: nil) { (avAsset, audioMix, info) in
            guard let avAsset = avAsset as? AVURLAsset else {
                completion(nil)
                return
            }
            
            let duration = avAsset.duration.seconds
            completion(duration)
        }
    }
}

extension DisplayViewController : UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        image.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! DisplayCollectionViewCell
        
        let asset = image[indexPath.row]
        let targetSize = CGSize(width: 100, height: 100)
    
    

//                if let cachedVersion = self.imageCaching.object(forKey: String(indexPath.item) as NSString) {
//                    DispatchQueue.main.async{
//                        cell.imageViewCell.image = cachedVersion
//                    }
//                }
//                else{
        
            self.imageManager.requestImage(for: self.image[indexPath.item], targetSize: targetSize, contentMode: .aspectFill, options: nil) { (image, _) in
                if let image = image{
                    self.imageCaching.setObject(image, forKey: String(indexPath.item) as NSString)
                }
                cell.videoTiming.text = nil
                cell.imageViewCell.image = nil
               
                if asset.mediaType == .video{
                
                        self.fetchVideoDuration(for: asset) { (duration) in
                            if let duration = duration{
                                var second = String(Int(duration) % 60)
                                if(second.count == 1) {
                                    second = "0" + second
                                }
                                DispatchQueue.main.async{
                                    cell.videoTiming.text = "\(Int(duration)/60):\(second)"
                                }
                            }
                            
                        }
                    
                    
                }
                else{
                    cell.videoTiming.text = nil
                }
               
                DispatchQueue.main.async{
                    cell.imageViewCell.image = image
                }
                  
                
            }
                        
                          
//                        if asset.mediaType == .video{
//                            self.fetchVideoDuration(for: asset) { (duration) in
//                                if let duration = duration {
//                                    print("this is duration \(duration)")
//                                    var second = String(Int(duration) % 60)
//                                    if(second.count == 1) {
//                                        second = "0" + second
//                                    }
//                                    
//                                    DispatchQueue.main.async{
//                                        var timelabel = UILabel()
//                                        timelabel.text = "\(Int(duration)/60):\(second)"
//                                    
//                                        timelabel.font = UIFont.systemFont(ofSize: 15)
//                                        timelabel.font = UIFont.boldSystemFont(ofSize: 10)
//                                        timelabel.textColor = UIColor.white
//                                      
//                                        cell.imageViewCell.addSubview(timelabel)
//                                       
//                                        NSLayoutConstraint.activate([
//                                            timelabel.trailingAnchor.constraint(equalTo: cell.imageViewCell.trailingAnchor, constant: -10),
//                                            timelabel.bottomAnchor.constraint(equalTo: cell.imageViewCell.bottomAnchor, constant: -10)
//                                        ])
//                                        
//                                    }
//                                }
//                                
//                            }
//                        }
                            
                        
                    
                
            
        
        
        return cell
    }
    }

extension DisplayViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //let bounds = collectionView.bounds
        let widthVal = self.view.frame.width
        let cellsize = widthVal/3
        print("DisplaYview Controller")
        print(widthVal)
        return CGSize(width: cellsize-10   , height: cellsize-10)
    }
}

extension DisplayViewController : UICollectionViewDelegate{
    func playVideo(for asset: PHAsset) {
        PHImageManager.default().requestPlayerItem(forVideo: asset, options: nil) { [weak self] (playerItem, info) in
            guard let playerItem = playerItem else {
                print("Failed to fetch player item")
                return
            }
            
            DispatchQueue.main.async {
                let player = AVPlayer(playerItem: playerItem)
                self?.playerViewController = AVPlayerViewController()
                self?.playerViewController?.player = player
                if let playerViewController = self?.playerViewController {
                    self?.present(playerViewController, animated: true) {
                        player.play()
                    }
                }
            }
        }
    }
    
    func fetchImage(for asset: PHAsset, completion: @escaping (UIImage?) -> Void) {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 300, height: 300), contentMode: .aspectFill, options: options) { (image, info) in
            completion(image)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if image[indexPath.row].mediaType == .video{
            playVideo(for: image[indexPath.row])
        }
        else{
            fetchImage(for: image[indexPath.row]) { (image) in
                let displayImage = self.storyboard?.instantiateViewController(identifier: "DisplayImageViewController") as! DisplayImageViewController
                if let image = image{
                    displayImage.configure(image: image)
                }
                self.navigationController?.pushViewController(displayImage, animated: true)
            }
        }
    }
}
    
    

