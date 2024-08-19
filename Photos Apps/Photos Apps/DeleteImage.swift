//
//  DeleteImage.swift
//  Photos Apps
//
//  Created by logo_dev_f1 on 18/8/24.
//

import Foundation
import UIKit
import Photos


class AssetManager{
    var trackDeleteAssets: Set<PHAsset> = []
    var delegate: [Int : ImageProcessingDelegate]  = [:]
    private init(){}
    static let shared = AssetManager()
    var photosInAlbums = [[PHAsset]]()
    var groupImageAll: [Int: [[PHAsset]]] = [:]
    var checkFlagForCompletingProcessing : [Int : Bool] = [:]
    
    func processImage(currentIndex: Int, completion: (() -> Void)? = nil) {
        let imageGrouping = SimilarImageGrouping(images: self.photosInAlbums[currentIndex])
        var groupImage = [[PHAsset]]()
        imageGrouping.process(onGroupFound: { [weak self] (group: [PHAsset]) in
            guard let self = self else { return }
            groupImage.append(group)
            self.groupImageAll[currentIndex] = groupImage
            self.delegate[currentIndex]?.didUpdateImages()
        }, completion: {
            DispatchQueue.main.async {
                completion?()
            }
        })
    }
    
    
    func deleteAssetsFromTotalAlbums(currentIndex : Int) {
        var updatedAlbum = groupImageAll[currentIndex] ?? [[PHAsset]]()
        for groupIndex in 0..<updatedAlbum.count {
            var updatedGroup = updatedAlbum[groupIndex]
            updatedGroup.removeAll { asset in
                self.trackDeleteAssets.contains(asset)
            }
            updatedAlbum[groupIndex] = updatedGroup
            groupImageAll[currentIndex] = updatedAlbum
            if let delegate = self.delegate[currentIndex]{
                delegate.didUpdateImages()
            }
        }
    }
    
}
