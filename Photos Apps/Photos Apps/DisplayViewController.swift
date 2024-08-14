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
    func selectedImageIndex(index : Int , image : UIImage)
    func deselection(index : Int)
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
    
//    func process(_ image: UIImage) -> VNFeaturePrintObservation? {
//        guard let cgImage = image.cgImage else { return nil }
//        
//        // Convert UIImage.Orientation to CGImagePropertyOrientation
//        let orientation: CGImagePropertyOrientation
//        switch image.imageOrientation {
//        case .up: orientation = .up
//        case .down: orientation = .down
//        case .left: orientation = .left
//        case .right: orientation = .right
//        case .upMirrored: orientation = .upMirrored
//        case .downMirrored: orientation = .downMirrored
//        case .leftMirrored: orientation = .leftMirrored
//        case .rightMirrored: orientation = .rightMirrored
//        @unknown default: orientation = .up
//        }
//        
//        let request = VNGenerateImageFeaturePrintRequest()
//        let requestHandler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation, options: [:])
//        
//        do {
//            try requestHandler.perform([request])
//        } catch {
//            print("Can't make the request due to \(error)")
//            return nil
//        }
//        
//        guard let result = request.results?.first as? VNFeaturePrintObservation else { return nil }
//        return result
//    }
    struct DuplicateImage {
        let id: Int
        let image: UIImage
        // Add any additional properties here
    }
    struct node{
        let hash : Int
        let ind : Int
    }
    var groupImage = [[Int]]()
    var arrDupliImage = [[DuplicateImage]]()
    var arrAllImage = [DuplicateImage]()
    
    
    func convertToGrayScale(image: UIImage) -> UIImage? {
            let imageRect:CGRect = CGRect(x:0, y:0, width:image.size.width, height: image.size.height)
            let colorSpace = CGColorSpaceCreateDeviceGray()
            let width = image.size.width
            let height = image.size.height
            let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
            let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
            if let cgImg = image.cgImage {
                context?.draw(cgImg, in: imageRect)
                if let makeImg = context?.makeImage() {
                    let imageRef = makeImg
                    let newImage = UIImage(cgImage: imageRef)
                    return newImage
                }
            }
            return UIImage()
        }
    
    
    func featureprintObservationForImage(image: UIImage) -> VNFeaturePrintObservation? {
        let requestHandler = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])
        let request = VNGenerateImageFeaturePrintRequest()
        /*request.usesCPUOnly = true*/ // Simulator Testing

        do {
          try requestHandler.perform([request])
          return request.results?.first as? VNFeaturePrintObservation
        } catch {
          print("Vision Error: \(error)")
          return nil
        }
      }
    
    func compare(oImgObservation: VNFeaturePrintObservation?, dImgObservation: VNFeaturePrintObservation?) -> Float? {
//      let oImgObservation = featureprintObservationForImage(image: origImg)
//      let dImgObservation = featureprintObservationForImage(image: drawnImg)

        if let oImgObservation = oImgObservation {
            if let dImgObservation = dImgObservation {
          var distance: Float = -1

          do {
            try oImgObservation.computeDistance(&distance, to: dImgObservation)
          } catch {
            fatalError("Failed to Compute Distance")
          }

          if distance == -1 {
            return nil
          } else {
            return distance
          }
        } else {
          print("Drawn Image Observation found Nil")
        }
      } else {
        print("Original Image Observation found Nil")
      }
      return nil
    }
    
    func process1(){
        let startTime = Date()
        DispatchQueue.global().async{
            var imageData = [VNFeaturePrintObservation]()
            var visInd : [Int : Bool] = [:]
            let targetSize = CGSize(width: 80, height: 80)
            for i in 0..<self.image.count{
                mediaManager.fetchImage(for: self.image[i], size: targetSize) { image in
                    if let image = image{
                        let grayScaleImage = self.convertToGrayScale(image: image)
                        let oImgObservation = self.featureprintObservationForImage(image: grayScaleImage!)
                        imageData.append(oImgObservation ?? VNFeaturePrintObservation())
                    }
                }
                visInd[i] = false
            }
            
            
            for i in 0..<self.image.count{
                var indexArray = [Int]()
                if visInd[i] == false{
                    for j in i..<i+100{
                        if j >= self.image.count{
                                                break
                                            }
                        if visInd[j] == false {
                            if let result = self.compare(oImgObservation: imageData[i], dImgObservation: imageData[j]){
                                if result < 11.0 {
                                    visInd[j] = true
                                    indexArray.append(j)
                                }
                            }
                        }
                    }
                    if indexArray.count >= 2{
                        self.groupImage.append(indexArray)
                        DispatchQueue.main.async{
                            self.collectionView.reloadData()
                        }
                    }
                }
            }
            
        }
        let endTime = Date()
        
        let timeInterval = endTime.timeIntervalSince(startTime)
        
        print("Time taken to complete the function: \(timeInterval) seconds")
        }
    
    
    
    
    
    func process(){
        DispatchQueue.global().async{
            var imageData = [OSHashType]()
            var imageDataRaw = [Data]()
            let targetSize = CGSize(width: 100, height: 100)
            var visInd : [Int : Bool] = [:]
            let startTime = Date()
            for i in 0..<self.image.count{
                mediaManager.fetchImage(for: self.image[i], size: targetSize) { image in
                    if let image = image{
                        if let imgData = image.pngData(){
                            let lhsData = OSImageHashing.sharedInstance().hashImageData(imgData, with: .dHash)
                            imageData.append(lhsData)
                        }
                    }
                }
                visInd[i] = false
            }
//            print("imageData count Ind \(String(describing: index))  \(imageData.count)")
            //
            for i in 0..<self.image.count{
                var indexArray = [Int]()
                if visInd[i] == false{
                    for j in i..<i+100{
                        if j >= self.image.count {
                            break
                        }
                        if visInd[j] == false {
                            let result =  OSImageHashing.sharedInstance().hashDistance(imageData[i], to: imageData[j], with: .dHash)
                            if result < 11 {
                                visInd[j] = true
                                indexArray.append(j)
                            }
                        }
                    }
                    if indexArray.count > 1{
                        self.groupImage.append(indexArray)
                        DispatchQueue.main.async{
                            self.collectionView.reloadData()
                        }
                    }
                }
            }
            
            let endTime = Date()
            
            let timeInterval = endTime.timeIntervalSince(startTime)
            
            print("Time taken to complete the function: \(timeInterval) seconds")
        }
      
    }
    
    private func processImages() {
        let imageGrouping = SimilarImageGrouping(images: image)
        imageGrouping.process(onGroupFound: { [weak self] (group: [Int])  in
            guard let self = self else { return }
            self.groupImage.append(group)
            self.collectionView.reloadData()  // Incrementally reload the collection view
        }, completion: {
            // Optional: Perform any actions after processing is complete
            print("All groups processed.")
        })
    }
    
    func configure(image : [PHAsset], index : Int){
        self.image = image
//        if index == 0 {
//            
//            self.collectionView.reloadData()
//            
//            
//        }

    }
    
    @IBAction func downArrayButtonEvenet(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
//        process1()
        processImages()
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
        if trackCell[indexPath.row] == true {
            cell.layer.borderColor = UIColor.green.cgColor
            cell.layer.borderWidth = 2.0 // Set the border width as needed
        } else {
            cell.layer.borderColor = UIColor.clear.cgColor
        }
        
        let asset = self.image[groupImage[indexPath.section][indexPath.row]]
        let targetSize = CGSize(width: 100, height: 100)
        mediaManager.fetchImage(for: asset, size: targetSize) { image in
            
            if let image = image{
                self.cacheImage[self.groupImage[indexPath.section][indexPath.row]] = image
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
                if let Image1 = cacheImage[groupImage[indexPath.section][indexPath.row]]{
                    selectedCountImage = selectedCountImage + 1
                    selectedImageDelegate?.selectedImageIndex(index: groupImage[indexPath.section][indexPath.row] , image : Image1)
                }
                trackCell[groupImage[indexPath.section][indexPath.row]] = true
            }
            else{
                if trackCell[groupImage[indexPath.section][indexPath.row]] == true{
                    selectedCountImage = selectedCountImage - 1
                    if selectedCountImage == 0 {
                        trackCell.removeAll()
                    }
                    selectedImageDelegate?.deselection(index: groupImage[indexPath.section][indexPath.row])
                    trackCell[groupImage[indexPath.section][indexPath.row]] = false
                }
                else{
                    if let image1 = cacheImage[groupImage[indexPath.section][indexPath.row]]{
                        selectedImageDelegate?.selectedImageIndex(index: groupImage[indexPath.section][indexPath.row] , image: image1)
                        selectedCountImage = selectedCountImage + 1
                    }
                    
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


