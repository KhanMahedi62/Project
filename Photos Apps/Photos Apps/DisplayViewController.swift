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
import Vision
import CocoaImageHashing
protocol SelectedImageProtocol{
    func selectedImageIndex(imageDeletionDelegate : imageDeletionProtocol , section : Int , asset : PHAsset)
    func deselection(asset : PHAsset)
}




extension UIImage {
    func convertToBlackAndWhite(threshold: CGFloat = 0.5) -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }
        
        let width = cgImage.width
        let height = cgImage.height
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let bitsPerComponent = 8
        let bytesPerRow = width
        let bitmapInfo = CGImageAlphaInfo.none.rawValue
        
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else { return nil }
        
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        context.draw(cgImage, in: rect)
        
        guard let data = context.data else { return nil }
        let pixelBuffer = data.bindMemory(to: UInt8.self, capacity: width * height)
        
        // Convert grayscale to binary black and white
        let thresholdValue = UInt8(threshold * 255)
        for y in 0..<height {
            for x in 0..<width {
                let pixelIndex = y * width + x
                pixelBuffer[pixelIndex] = pixelBuffer[pixelIndex] > thresholdValue ? 255 : 0
            }
        }
        
        guard let blackAndWhiteImage = context.makeImage() else { return nil }
        return UIImage(cgImage: blackAndWhiteImage)
    }
}

class DisplayViewController: UIViewController , imageDeletionProtocol  {
    
    var selectedImageDelegate : SelectedImageProtocol?
    var barTitle : String?
    var cacheImage : [Int : UIImage] = [:]
    let imageManager = PHCachingImageManager()
    var trackCell : [PHAsset: Bool] = [:]
    @IBOutlet weak var collectionView: UICollectionView!
    var image = [PHAsset]()
    var selectedCountImage = 0
    var currentIndex: Int?
    @IBOutlet weak var viedioLabel: UILabel!
    var groupImage = [[PHAsset]]()
    
    
    func configure(image : [PHAsset], index : Int){
        self.image = image
        self.currentIndex = index
        //        AssetManager.shared.delegate[index] = self
    }
    
    @IBAction func downArrayButtonEvenet(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        if let currentIndex = self.currentIndex{
            AssetManager.shared.processImage(currentIndex: currentIndex,
                                             groupCompletion: {
                self.groupImage = AssetManager.shared.groupImageAll[currentIndex]?.albumPhotos ?? [[PHAsset]]()
                DispatchQueue.main.async{
                    self.collectionView.reloadData()
                }
            },
                                             completion: {
                AssetManager.shared.groupImageAll[currentIndex]?.checkFlagForCompletingProcessing = true
                AssetManager.shared.deleteAssetsFromTotalAlbums(currentIndex: currentIndex,
                                                                groupCompletion:{
                    self.groupImage = AssetManager.shared.groupImageAll[currentIndex]?.albumPhotos ?? [[PHAsset]]()
                    DispatchQueue.main.async{
                        self.collectionView.reloadData()
                    }
                },
                                                                completion:{})
            })
        }
    }
}




extension DisplayViewController : UICollectionViewDataSource{
    
    // For showing countImage in the top
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return groupImage.count
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return groupImage[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? DisplayCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.layer.cornerRadius = 6
        if trackCell[groupImage[indexPath.section][indexPath.row]] == true {
            cell.layer.borderColor = UIColor.green.cgColor
            cell.layer.borderWidth = 2.0 // Set the border width as needed
        } else {
            cell.layer.borderColor = UIColor.clear.cgColor
        }
        
        let asset = groupImage[indexPath.section][indexPath.row]
        let targetSize = CGSize(width: 100, height: 100)
        mediaManager.fetchImage(for: asset, size: targetSize) { image in
            
            if let image = image{
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
            if trackCell[groupImage[indexPath.section][indexPath.row]] == nil {
                selectedCountImage = selectedCountImage + 1
                selectedImageDelegate?.selectedImageIndex(imageDeletionDelegate: self , section: indexPath.section , asset: groupImage[indexPath.section][indexPath.row])
                
                trackCell[groupImage[indexPath.section][indexPath.row]] = true
            }
            else{
                if trackCell[groupImage[indexPath.section][indexPath.row]] == true{
                    selectedCountImage = selectedCountImage - 1
                    if selectedCountImage == 0 {
                        trackCell.removeAll()
                    }
                    selectedImageDelegate?.deselection(asset: groupImage[indexPath.section][indexPath.row])
                    trackCell[groupImage[indexPath.section][indexPath.row]] = false
                }
                else{
                    selectedImageDelegate?.selectedImageIndex(imageDeletionDelegate: self , section: indexPath.section , asset: groupImage[indexPath.section][indexPath.row])
                    selectedCountImage = selectedCountImage + 1
                    trackCell[groupImage[indexPath.section][indexPath.row]] = true
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


extension DisplayViewController{
    func deleteImage(index: Int, section: Int, asset: PHAsset, completion: @escaping () -> Void){
        for i in 0..<groupImage[section].count {
            if groupImage[section][i] == asset{
                groupImage[section].remove(at: i)
                break
            }
        }
        completion()
    }
    
    func callForCollectionView() {
        DispatchQueue.main.async{
            self.collectionView.reloadData()
        }
    }
}


