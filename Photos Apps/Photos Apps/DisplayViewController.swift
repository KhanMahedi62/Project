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

protocol SelectedImageProtocol{
    func selectedImageIndex(index : Int)
    func deselection(index : Int)
}

class DisplayViewController: UIViewController {
    var selectedImageDelegate : SelectedImageProtocol?
    var barTitle : String?
    var cacheImage : [Int : UIImage] = [:]
    let imageManager = PHCachingImageManager()
    var trackCell : [Int: Bool] = [:]
    @IBOutlet weak var collectionView: UICollectionView!
    var image = [PHAsset]()
    var selectedCountImage = 0
    
    @IBOutlet weak var viedioLabel: UILabel!
    
    func configure(image : [PHAsset], index : Int){
        self.image = image
        if index == 0 {
            collectionView.reloadData()
        }
    }
    
    @IBAction func downArrayButtonEvenet(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    
}


extension DisplayViewController : UICollectionViewDataSource{
    
    // For showing countImage in the top
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return image.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? DisplayCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.layer.cornerRadius = 6
        if trackCell[indexPath.row] == true {
            cell.layer.borderColor = UIColor.green.cgColor
            cell.layer.borderWidth = 2.0 // Set the border width as needed
        } else {
            cell.layer.borderColor = UIColor.clear.cgColor
        }
        
        let asset = self.image[indexPath.row]
        let targetSize = CGSize(width: 100, height: 100)
        mediaManager.fetchImage(for: asset, size: targetSize) { image in
            if let image = image{
                self.cacheImage[indexPath.row] = image
            }
            cell.videoTiming.text = nil
            cell.imageViewCell.image = nil
            if asset.mediaType == .video{
                
                mediaManager.fetchVideoDuration(for: asset) { (duration) in
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
        let widthVal = self.view.frame.width
        let cellsize = (widthVal - (3*4 + 2*8))/4
        return CGSize(width: cellsize , height: cellsize)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8) // Adjust as needed
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4 // Adjust as needed
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 4 // Adjust as needed
    }
}

extension DisplayViewController : UICollectionViewDelegate{
    func fetchImage(for asset: PHAsset, completion: @escaping (UIImage?) -> Void) {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 300, height: 300), contentMode: .aspectFill, options: options) { (image, info) in
            completion(image)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.collectionView{
            if trackCell[indexPath.row] == nil {
                if let Image = cacheImage[indexPath.row]{
                    selectedCountImage = selectedCountImage + 1
                    selectedImageDelegate?.selectedImageIndex(index: indexPath.row)
                }
                trackCell[indexPath.row] = true
            }
            else{
                if trackCell[indexPath.row] == true{
                    selectedCountImage = selectedCountImage - 1
                    if selectedCountImage == 0 {
                        trackCell.removeAll()
                    }
                    selectedImageDelegate?.deselection(index: indexPath.row)
                    trackCell[indexPath.row] = false
                }
                else{
                    if let Image = cacheImage[indexPath.row]{
                        selectedImageDelegate?.selectedImageIndex(index: indexPath.row)
                        selectedCountImage = selectedCountImage + 1
                    }
                    
                    trackCell[indexPath.row] = true
                }
            }
            
            collectionView.reloadItems(at: [indexPath])
            
        }
        
    }
}


// function conforming to IndicatorInfoProvieder for XLpager Title text
extension DisplayViewController : IndicatorInfoProvider{
    func indicatorInfo(for pagerTabStripController: XLPagerTabStrip.PagerTabStripViewController) -> XLPagerTabStrip.IndicatorInfo {
        return IndicatorInfo(title: self.barTitle)
    }
}


