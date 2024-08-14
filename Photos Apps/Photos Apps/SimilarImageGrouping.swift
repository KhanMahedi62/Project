import UIKit
import CocoaImageHashing
import Photos

class SimilarImageGrouping {
    private let images: [PHAsset]
    private let mediaManager = MediaManager()
    init(images: [PHAsset]) {
        self.images = images
    }

    func process(onGroupFound: @escaping ([Int]) -> Void, completion: @escaping () -> Void) {
        DispatchQueue.global().async {
            var imageData = [OSHashType]()
            var visInd: [Int: Bool] = [:]
            let targetSize = CGSize(width: 100, height: 100)
            let startTime = Date()

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
                // Process image groups
                for i in 0..<self.images.count {
                    var indexArray = [Int]()
                    if visInd[i] == false {
                        for j in i..<min(i + 100, self.images.count) {
                            if visInd[j] == false {
                                let distance = OSImageHashing.sharedInstance().hashDistance(imageData[i], to: imageData[j], with: .dHash)
                                if distance < 11 {
                                    visInd[j] = true
                                    indexArray.append(j)
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

                let endTime = Date()
                let timeInterval = endTime.timeIntervalSince(startTime)
                print("Time taken to complete the function: \(timeInterval) seconds")
            }
        }
    }
}

