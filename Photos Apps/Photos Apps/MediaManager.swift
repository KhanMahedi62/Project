//
//  MediaManager.swift
//  Photos Apps
//
//  Created by logo_dev_f1 on 7/8/24.
//
import UIKit
import Foundation
import Photos
class MediaManager{
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization { status in
            let authorized = status == .authorized
            completion(authorized)
        }
    }
    
    func fetchAlbums(completion: @escaping ([String], [[PHAsset]]) -> Void) {
        var albums = [PHAssetCollection]()
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "estimatedAssetCount > 0")
        let userAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
        
        smartAlbums.enumerateObjects { (collection, _, _) in
            albums.append(collection)
        }
        userAlbums.enumerateObjects { (collection, _, _) in
            albums.append(collection)
        }
        
        fetchPhotosForAlbums(albums: albums, completion: completion)
    }
    func fetchPhotosForAlbums(albums: [PHAssetCollection],  completion: @escaping ([String], [[PHAsset]]) -> Void) {
        var albumNames = [String]()
        var photosInAlbums = [[PHAsset]]()
        
        let dispatchGroup = DispatchGroup()
        
        for album in albums {
            dispatchGroup.enter()
            
            var photos = [PHAsset]()
            let options = PHFetchOptions()
            options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            let assets = PHAsset.fetchAssets(in: album, options: options)
            
            assets.enumerateObjects { (asset, _, _) in
                photos.append(asset)
            }
            
            if photos.count > 0 {
                albumNames.append(album.localizedTitle ?? "Untitled Album")
                photosInAlbums.append(photos)
            }
            
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            // Call completion handler with the final results
            completion(albumNames, photosInAlbums)
        }
    }
    
    func fetchImage(for asset: PHAsset, size: CGSize, completion: @escaping (UIImage?) -> Void) {
        let imageManager = PHImageManager.default()
        let imageRequestOptions = PHImageRequestOptions()
        imageRequestOptions.isSynchronous = true // Ensure the image is fetched synchronously
        
        imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: imageRequestOptions) { image, _ in
            completion(image)
        }
    }
    
    func fetchVideoDuration(for asset: PHAsset, completion: @escaping (TimeInterval?) -> Void) {
        PHImageManager.default().requestAVAsset(forVideo: asset, options: nil) { (avAsset, _, _) in
            guard let avAsset = avAsset as? AVURLAsset else {
                completion(nil)
                return
            }
            
            let duration = avAsset.duration.seconds
            completion(duration)
        }
    }
    
    
}
