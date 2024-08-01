//
//  HomeViewController.swift
//  Photos Apps
//
//  Created by logo_dev_f1 on 28/7/24.
//

import UIKit
import Photos

struct albumMetaData{
    var albumNames = [String]()
    var photosInAlbums = [[PHAsset]]()
}

class HomeViewController: UIViewController {
    var firstTimeCallOfParentViewFlag = false
    var metaData = albumMetaData()
    var totalAlbums = 0
    func requestAuthorization(){
        PHPhotoLibrary.requestAuthorization { [weak self]  status in
            if status == .authorized{
                self?.fetchAlbums()
            }
        }
        
    }
    
    // fetching all albums
    func fetchAlbums() {
        var albums = [PHAssetCollection]()
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "estimatedAssetCount > 0")
        let userAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
        totalAlbums = smartAlbums.count + userAlbums.count
        smartAlbums.enumerateObjects{ (collection, _, _) in
            albums.append(collection)
        }
        userAlbums.enumerateObjects { (collection, _, _) in
            albums.append(collection)
        }
        
        self.fetchPhotosForAlbums(albums : albums)
    }
    
    
    // fetching photos for all albums
    func fetchPhotosForAlbums(albums: [PHAssetCollection]) {
        
        for album in albums {
            var photos = [PHAsset]()
            let options = PHFetchOptions()
            options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            let assets = PHAsset.fetchAssets(in: album, options: options)
            assets.enumerateObjects { (asset, _, _) in
                photos.append(asset)
            }
            if photos.count > 0{
                self.metaData.albumNames.append(album.localizedTitle ?? "Untitled Album")
                self.metaData.photosInAlbums.append(photos)
            }
            else {
                self.totalAlbums = self.totalAlbums - 1
            }
            DispatchQueue.main.async{
                if self.metaData.photosInAlbums.count == self.totalAlbums {
                    let parentView = self.storyboard?.instantiateViewController(identifier: "PagerTabStripViewController") as! ParentViewController
                    parentView.configure(metaData : self.metaData)
                    self.firstTimeCallOfParentViewFlag = true
                    parentView.modalPresentationStyle = .fullScreen
                    self.present(parentView, animated: true, completion: nil)
                }
                
            }
        }
    }
    
    @IBAction func photosButtonAction(_ sender: Any) {
        if firstTimeCallOfParentViewFlag == false{
            requestAuthorization()
        }
        else{
            let parentView = self.storyboard?.instantiateViewController(identifier: "PagerTabStripViewController") as! ParentViewController
            parentView.configure(metaData : self.metaData)
            parentView.modalPresentationStyle = .fullScreen
            self.present(parentView, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
