//
//  CocoaImageCheckViewController.swift
//  Photos Apps
//
//  Created by logo_dev_f1 on 8/8/24.
//

import UIKit
import CocoaImageHashing
import Vision
class CocoaImageCheck: UIViewController {
    var image1 : UIImage?
    var image2 : UIImage?
    func DidFinish(image1: UIImage, image2: UIImage) {
        self.image1 = image1
        self.image2 = image2
    }
    var arrDupliImage = [[DuplicateImage]]()
    var arrAllImage = [DuplicateImage]()
    func process(_ image: UIImage) -> VNFeaturePrintObservation? {
        guard let cgImage = image.cgImage else { return nil }
        
        // Convert UIImage.Orientation to CGImagePropertyOrientation
        let orientation: CGImagePropertyOrientation
        switch image.imageOrientation {
        case .up: orientation = .up
        case .down: orientation = .down
        case .left: orientation = .left
        case .right: orientation = .right
        case .upMirrored: orientation = .upMirrored
        case .downMirrored: orientation = .downMirrored
        case .leftMirrored: orientation = .leftMirrored
        case .rightMirrored: orientation = .rightMirrored
        @unknown default: orientation = .up
        }
        
        let request = VNGenerateImageFeaturePrintRequest()
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation, options: [:])
        
        do {
            try requestHandler.perform([request])
        } catch {
            print("Can't make the request due to \(error)")
            return nil
        }
        
        guard let result = request.results?.first as? VNFeaturePrintObservation else { return nil }
        return result
    }
    struct DuplicateImage {
        let id: Int
        let image: UIImage
        // Add any additional properties here
    }
    func findDuplicateImage() {
            var images: [OSTuple<NSString, NSData>] = []
            for i in 0..<arrAllImage.count {
                let imgData = arrAllImage[i].image.pngData()!
                images.append(OSTuple<NSString, NSData>(first: NSString(string: "\(i)"), andSecond: imgData as NSData))
            }
            
    //
            let similarImageIdsAsTuples = OSImageHashing.sharedInstance().similarImages(with: OSImageHashingQuality.high, forImages: images)
            
            var arrayID = [[NSString]]()
            for tuple in similarImageIdsAsTuples {
                let id = [tuple.first!, tuple.second!]
                arrayID.append(id)
            }
            
            var resultArray = [[NSString]]()
            
            for (i,arrayI) in arrayID.enumerated() {
//                DispatchQueue.main.async {
//                    self.lblNumberOfPhoto.text = R.string.localizable.processing_similar_photos_number("\(i)", "\(arrayID.count)")
//                }
                
                if i == 0 {
                    resultArray.append(arrayI)
                } else {
                    var isContains = false
                    for (j,result) in resultArray.enumerated() {
                        if result.contains(arrayI[1]) && result.contains(arrayI.first!) {
                            isContains = true
                            break
                        } else if result.contains(arrayI.first!)  {
                            var newdata = result
                            resultArray.remove(at: j)
                            newdata.append(arrayI[1])
                            resultArray.insert(newdata, at: j)
                            isContains = true
                            break
                        } else if result.contains(arrayI[1]) {
                            var newdata = result
                            resultArray.remove(at: j)
                            newdata.append(arrayI.first!)
                            resultArray.insert(newdata, at: j)
                            isContains = true
                            break
                        }
                    }
                    if !isContains {
                        resultArray.append(arrayI)
                    }
                }
            }
            
            arrDupliImage.removeAll()
            
            for similarImageID in resultArray {
                var dupliImageTabel = [DuplicateImage]()
                
                for imgId in similarImageID {
                    let data = arrAllImage.filter { (dupImg) -> Bool in
                        return dupImg.id == imgId.integerValue
                    }
                    if !data.isEmpty {
                        dupliImageTabel.append(data.first!)
                    }
                }
                arrDupliImage.append(dupliImageTabel)
            }
    }
    
    func featureprintObservationForImage(image: UIImage) -> VNFeaturePrintObservation? {
        let requestHandler = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])
        let request = VNGenerateImageFeaturePrintRequest()
        request.usesCPUOnly = true // Simulator Testing

        do {
          try requestHandler.perform([request])
          return request.results?.first as? VNFeaturePrintObservation
        } catch {
          print("Vision Error: \(error)")
          return nil
        }
      }

      func compare(origImg: UIImage, drawnImg: UIImage) -> Float? {
        let oImgObservation = featureprintObservationForImage(image: origImg)
        let dImgObservation = featureprintObservationForImage(image: drawnImg)

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

    
    func setImage(){
        imageViewOne.image = image1
        imageViewTwo.image = image2
        guard let firstImageData = image1?.pngData(),
              let secondImageData = image2?.pngData() else {
               print("Error: One or both images could not be converted to Data.")
               return
           }
//        let similarImageIdsAsTuples = OSImageHashing.sharedInstance().similarImages(with: OSImageHashingQuality.high, forImages: images)
           // Compare images using OSImageHashing
        let pHash1 = OSImageHashing.sharedInstance().hashImageData(firstImageData, with: .dHash)
        let pHash2 = OSImageHashing.sharedInstance().hashImageData(secondImageData, with: .dHash)
        print(" one \(pHash1) , two  \(pHash2)")
        let result = OSImageHashing.sharedInstance().compareImageData(firstImageData, to: secondImageData, with: .pHash)
        let result1 = OSImageHashing.sharedInstance().compareImageData(firstImageData, to: secondImageData, with: .aHash)
        let resultt =  OSImageHashing.sharedInstance().hashDistance(pHash1, to: pHash2, with: .dHash)
        let result2 = OSImageHashing.sharedInstance().compareImageData(firstImageData, to: secondImageData, with: .dHash)
        let finalResult = compare(origImg: image1!, drawnImg: image2!)
           // Handle the result
          
        if result == true || result1 || result2 {
            label.textColor = .green
            label.text = "Same \(resultt)"
        }
        else{
            label.textColor = .red
            label.text = "Not Same \(resultt)"
        }
    }
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var imageViewTwo: UIImageView!
    @IBOutlet weak var imageViewOne: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setImage()
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
