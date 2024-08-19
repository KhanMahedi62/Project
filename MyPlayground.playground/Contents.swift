import UIKit
import Vision

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

let balloon1 = UIImage(named: "balloon_1.jpg")!
let balloon1FeaturePrint = process(balloon1)!

let balloon2 = UIImage(named: "balloon_2.jpg")!
let balloon2FeaturePrint = process(balloon2)!

let balloon3 = UIImage(named: "balloon_3.jpg")!
let balloon3FeaturePrint = process(balloon3)!

let balloon4 = UIImage(named: "balloon_4.jpg")!
let balloon4FeaturePrint = process(balloon4)!

let heart = UIImage(named: "heart.jpg")!
let heartFeaturePrint = process(heart)!

let plane = UIImage(named: "plane.jpg")! // Original photo by https://unsplash.com/@nbb_photos
let planeFeaturePrint = process(plane)!

var balloon1ToBallon2Distance: Float = .infinity
var balloon1ToBallon3Distance: Float = .infinity
var balloon1ToBallon4Distance: Float = .infinity
var balloon1ToHeartDistance: Float = .infinity
var balloon1ToPlaneDistance: Float = .infinity

do {
    try balloon1FeaturePrint.computeDistance(&balloon1ToBallon2Distance, to: balloon2FeaturePrint)
    try balloon1FeaturePrint.computeDistance(&balloon1ToBallon3Distance, to: balloon3FeaturePrint)
    try balloon1FeaturePrint.computeDistance(&balloon1ToBallon4Distance, to: balloon4FeaturePrint)
    try balloon1FeaturePrint.computeDistance(&balloon1ToHeartDistance, to: heartFeaturePrint)
    try balloon1FeaturePrint.computeDistance(&balloon1ToPlaneDistance, to: planeFeaturePrint)
} catch {
    print("Couldn't compute the distance")
}

