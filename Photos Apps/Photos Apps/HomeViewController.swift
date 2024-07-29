//
//  HomeViewController.swift
//  Photos Apps
//
//  Created by logo_dev_f1 on 28/7/24.
//

import UIKit
import Photos
class HomeViewController: UIViewController {
    var firstTimeCallOfParentViewFlag = false
    var trackPhotoalbums: [Int: Bool] = [:]
    var image = [PHAsset]()
    let imageManager = PHCachingImageManager()
    var albums = [PHAssetCollection]()
    var albumNames = [String]()
    var photosInAlbums = [[PHAsset]]()
    var childViewController = [UIViewController]()
    var totalAlbums = 0
    
    func requestAuthorization(){
        PHPhotoLibrary.requestAuthorization { [weak self]  status in
            if status == .authorized{
                self?.fetchAlbums()
            }
        }
    }
    
    
    func fetchAlbums() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "estimatedAssetCount > 0")
        let albums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
        totalAlbums = smartAlbums.count + albums.count
        smartAlbums.enumerateObjects{ (collection, _, _) in
            self.albums.append(collection)
        }
        albums.enumerateObjects { (collection, _, _) in
            self.albums.append(collection)
        }
        
        self.fetchPhotosForAlbums()
    }
    
    
    
    func fetchPhotosForAlbums() {
        
        for album in self.albums {
            var photos = [PHAsset]()
            let options = PHFetchOptions()
            options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            let assets = PHAsset.fetchAssets(in: album, options: options)
            assets.enumerateObjects { (asset, _, _) in
                photos.append(asset)
            }
                if photos.count > 0{
                    self.albumNames.append(album.localizedTitle ?? "Untitled Album")
                    self.photosInAlbums.append(photos)
                }
                else {
                    self.totalAlbums = self.totalAlbums - 1
                }
            DispatchQueue.main.async{
                if self.photosInAlbums.count == self.totalAlbums {
                    let parentView = self.storyboard?.instantiateViewController(identifier: "PagerTabStripViewController") as! ParentViewController
                    parentView.configure(photoAlbums: self.photosInAlbums, albumNames: self.albumNames)
                    self.firstTimeCallOfParentViewFlag = true
                    self.navigationController?.pushViewController(parentView, animated: true)
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
            parentView.configure(photoAlbums: self.photosInAlbums, albumNames: self.albumNames)
            DisplayViewController.countImage = 0 
            self.navigationController?.pushViewController(parentView, animated: true)
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
