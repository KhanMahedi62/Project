import UIKit
import CocoaImageHashing
import Photos

class SimilarImageGrouping {
    private let images: [PHAsset]
    private let mediaManager = MediaManager()
    init(images: [PHAsset]) {
        self.images = images
    }

    func process(onGroupFound: @escaping ([PHAsset]) -> Void, completion: @escaping () -> Void) {
        DispatchQueue.global().async {
            var imageData = [OSHashType]()
            var visInd: [Int: Bool] = [:]
            let targetSize = CGSize(width: 100, height: 100)

            // Fetch image data
            let group = DispatchGroup()
            for i in 0..<self.images.count {
                group.enter()
                self.mediaManager.fetchImage(for: self.images[i], size: targetSize) { image in
                    defer { group.leave() }
                    if let image = image, let imgData = image.pngData() {
                        let hash = OSImageHashing.sharedInstance().hashImageData(imgData, with: .dHash)
                        imageData.append(hash)
                    }
                }
                visInd[i] = false
            }

            group.notify(queue: .global()) {
                for i in 0..<self.images.count {
                    var indexArray = [PHAsset]()
                    if visInd[i] == false {
                        for j in i..<min(i + 100, self.images.count) {
                            if visInd[j] == false {
                                let distance = OSImageHashing.sharedInstance().hashDistance(imageData[i], to: imageData[j], with: .dHash)
                                if distance < 11 {
                                    visInd[j] = true
                                    indexArray.append(self.images[j])
                                }
                            }
                        }
                        if indexArray.count > 1 {
                            DispatchQueue.main.async {
                                onGroupFound(indexArray)  // Notify about the new group
                            }
                        }
                    }
                }

                DispatchQueue.main.async {
                    completion()  // Notify when processing is complete
                }
            }
        }
    }
}

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


//func featureprintObservationForImage(image: UIImage) -> VNFeaturePrintObservation? {
//    let requestHandler = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])
//    let request = VNGenerateImageFeaturePrintRequest()
//    do {
//      try requestHandler.perform([request])
//      return request.results?.first as? VNFeaturePrintObservation
//    } catch {
//      print("Vision Error: \(error)")
//      return nil
//    }
//  }
//
//func compare(oImgObservation: VNFeaturePrintObservation?, dImgObservation: VNFeaturePrintObservation?) -> Float? {
////      let oImgObservation = featureprintObservationForImage(image: origImg)
////      let dImgObservation = featureprintObservationForImage(image: drawnImg)
//
//    if let oImgObservation = oImgObservation {
//        if let dImgObservation = dImgObservation {
//      var distance: Float = -1
//
//      do {
//        try oImgObservation.computeDistance(&distance, to: dImgObservation)
//      } catch {
//        fatalError("Failed to Compute Distance")
//      }
//
//      if distance == -1 {
//        return nil
//      } else {
//        return distance
//      }
//    } else {
//      print("Drawn Image Observation found Nil")
//    }
//  } else {
//    print("Original Image Observation found Nil")
//  }
//  return nil
//}
