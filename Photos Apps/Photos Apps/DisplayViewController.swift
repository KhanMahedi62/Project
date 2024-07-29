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
import XLPagerTabStrip
class DisplayViewController: UIViewController {
    var barTitle : String?
    var itemInfo : IndicatorInfo?
    let backgroundQueue = DispatchQueue.global(qos: .background)
    var playerViewController: AVPlayerViewController?
    var imageCaching = NSCache<NSString, UIImage>()
    let imageManager = PHCachingImageManager()
    var trackCell : [Int: Bool] = [:]
    @IBOutlet weak var collectionView: UICollectionView!
    var image = [PHAsset]()
    static var countImage = 0
    private let topAlertBar = UIView()
    private let countLabel = UILabel()
    
    
    @IBOutlet weak var viedioLabel: UILabel!
    func configure(image : [PHAsset], index : Int){
        self.image = image
        if index == 0 {
            collectionView.reloadData()
        }
    }
    private func setupUI() {
        // Configure the top alert bar
        topAlertBar.backgroundColor = .systemGray
        topAlertBar.translatesAutoresizingMaskIntoConstraints = false
        topAlertBar.isHidden = true  // Initially hidden
        view.addSubview(topAlertBar)
        
        // Configure the count label
        countLabel.textColor = .black
        countLabel.font = UIFont.boldSystemFont(ofSize: 16)
        countLabel.textAlignment = .center
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        topAlertBar.addSubview(countLabel)
        
        // Add constraints to position the top alert bar
        NSLayoutConstraint.activate([
            topAlertBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topAlertBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topAlertBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topAlertBar.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // Add constraints to position the count label within the alert bar
        NSLayoutConstraint.activate([
            countLabel.centerXAnchor.constraint(equalTo: topAlertBar.centerXAnchor),
            countLabel.centerYAnchor.constraint(equalTo: topAlertBar.centerYAnchor)
        ])
        
        // Your collection view or other UI elements setup
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        setupUI()
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
// for extracting video duration of a video
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
    
    // For showing countImage in the top
    func updateSelectedCount() {
        countLabel.text = "Selected Image: \(DisplayViewController.countImage)"
        topAlertBar.isHidden = (DisplayViewController.countImage == 0)
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        image.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! DisplayCollectionViewCell
        if trackCell[indexPath.row] == true {
            cell.layer.borderColor = UIColor.green.cgColor
            cell.layer.borderWidth = 2.0 // Set the border width as needed
        } else {
            cell.layer.borderColor = UIColor.clear.cgColor
        }
        
        let asset = self.image[indexPath.row]
        let targetSize = CGSize(width: 100, height: 100)
        
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
        
        return cell
    }
}

// for sizing the cell
extension DisplayViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //let bounds = collectionView.bounds
        let widthVal = self.view.frame.width
        let cellsize = widthVal/3
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
    
    // showing photo or a video
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if trackCell[indexPath.row] == nil {
            DisplayViewController.countImage = DisplayViewController.countImage + 1
            trackCell[indexPath.row] = true
        }
        else{
            if trackCell[indexPath.row] == true{
                DisplayViewController.countImage = DisplayViewController.countImage - 1
                trackCell[indexPath.row] = false
            }
            else{
                DisplayViewController.countImage = DisplayViewController.countImage + 1
                trackCell[indexPath.row] = true
            }
        }
        
        collectionView.reloadItems(at: [indexPath])
        updateSelectedCount()

    }
}


// function conforming to IndicatorInfoProvieder for XLpager Title text
extension DisplayViewController : IndicatorInfoProvider{
    func indicatorInfo(for pagerTabStripController: XLPagerTabStrip.PagerTabStripViewController) -> XLPagerTabStrip.IndicatorInfo {
        return IndicatorInfo(title: self.barTitle)
    }
}
