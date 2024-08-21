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
    private init(){}
    static let shared = AssetManager()
    var photosInAlbums = [[PHAsset]]()
    var groupImageAll: [Int: infroationAboutAlbums] = [:]
    
    struct infroationAboutAlbums{
        var albumPhotos = [[PHAsset]]()
        var checkFlagForCompletingProcessing = false
    }
    
    
    func processImage(currentIndex: Int, groupCompletion: (() -> Void)? = nil, completion: (() -> Void)? = nil) {
        let imageGrouping = SimilarImageGrouping(images: self.photosInAlbums[currentIndex])
        var groupImage = [[PHAsset]]()
        
        imageGrouping.process(onGroupFound: { [weak self] (group: [PHAsset]) in
            guard let self = self else { return }
            groupImage.append(group)
            let groupInformation = infroationAboutAlbums(albumPhotos: groupImage , checkFlagForCompletingProcessing: false)
            self.groupImageAll[currentIndex] = groupInformation
            DispatchQueue.main.async {
                groupCompletion?()
            }
        }, completion: {
            DispatchQueue.main.async {
                completion?()
            }
        })
    }

    
    
    func deleteAssetsFromTotalAlbums(currentIndex: Int, groupCompletion: (() -> Void)? = nil, completion: (() -> Void)? = nil) {
        var updatedAlbum = groupImageAll[currentIndex]?.albumPhotos ?? [[PHAsset]]()
        for groupIndex in 0..<updatedAlbum.count {
            var updatedGroup = updatedAlbum[groupIndex]
            updatedGroup.removeAll { asset in
                self.trackDeleteAssets.contains(asset)
            }
            updatedAlbum[groupIndex] = updatedGroup
            DispatchQueue.main.async {
                groupCompletion?()
            }
        }
        let groupInformation = infroationAboutAlbums(albumPhotos: updatedAlbum , checkFlagForCompletingProcessing: groupImageAll[currentIndex]?.checkFlagForCompletingProcessing ?? false)
        groupImageAll[currentIndex] = groupInformation
        DispatchQueue.main.async {
            completion?()
        }
    }
    
}
