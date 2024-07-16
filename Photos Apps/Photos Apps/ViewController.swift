//
//  ViewController.swift
//  Photos Apps
//
//  Created by logo_dev_f1 on 14/7/24.
//




import UIKit
import Photos
import XLPagerTabStrip
class ViewController: UIViewController{
    
 

    @IBOutlet weak var collectionView: UICollectionView!
    var image = [PHAsset]()
    let imageManager = PHCachingImageManager()
    var albums = [PHAssetCollection]()
    var albumNames = [String]()
    var photosInAlbums = [[PHAsset]]()
    var imageCaching = NSCache<NSString, UIImage>()
    func requestAuthorization(){
        print("mahedi")
            PHPhotoLibrary.requestAuthorization { [weak self]  status in
                print(status)
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
        print("Smart Album size \(smartAlbums.count)")
        smartAlbums.enumerateObjects{ (collection, _, _) in
                self.albums.append(collection)
        }
           albums.enumerateObjects { (collection, _, _) in
               self.albums.append(collection)
           }
        print("album size \(albums.count)")

           self.fetchPhotosForAlbums()
       }
    
    
    
    
    func fetchPhotosForAlbums() {
         for album in albums {
             var photos = [PHAsset]()
             let options = PHFetchOptions()
             options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
             let assets = PHAsset.fetchAssets(in: album, options: options)
             assets.enumerateObjects { (asset, _, _) in
                 photos.append(asset)
             }
             if photos.count > 0{
                 self.albumNames.append(album.localizedTitle ?? "Untitled Album")
                 photosInAlbums.append(photos)
             }
             
         }
        
         DispatchQueue.main.async {
             self.collectionView.reloadData()
         }
     }
 


    
    override func viewDidLoad() {
        print("mahedi khan mahedi khan mahedi")
        super.viewDidLoad()
        // Do any additional setup after loading the view.
       
        collectionView.delegate = self
        collectionView.dataSource = self
        requestAuthorization()
    }


}

extension ViewController: UICollectionViewDataSource {
    static var dispatchQueue = DispatchQueue.global(qos: .background)
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("photoAlbums")
        print(photosInAlbums.count)
        return photosInAlbums.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("hi this is mahedi ")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! imageCell
        
        let asset = (photosInAlbums[indexPath.item].count > 0) ? photosInAlbums[indexPath.item][0] : nil
        print("mahedi khan")
        // Request image for the asset
        let targetSize = CGSize(width: 300, height: 300) // Adjust the size as needed
        cell.titleLabel.text = self.albumNames[indexPath.item]
        cell.countLabel.text = "\( self.photosInAlbums[indexPath.item].count)"
        
        if let ass = asset{
                if let cachedVersion = self.imageCaching.object(forKey: self.albumNames[indexPath.row] as NSString) {
                    DispatchQueue.main.async{
                        cell.imageViewCell.image = cachedVersion
                    }
                }
                else{
                    self.imageManager.requestImage(for: ass, targetSize: targetSize, contentMode: .aspectFill, options: nil) { (image, _) in
                        if let image = image{
                            self.imageCaching.setObject(image, forKey: self.albumNames[indexPath.row] as NSString)
                        }
                        DispatchQueue.main.async{
                            cell.imageViewCell.image = image
                        }
                    }
                }
            }
        else{
            cell.imageViewCell.image = UIImage(named: "default-placeholder")
        }
        cell.layer.cornerRadius = 10
        cell.layer.borderWidth = 0.1
        return cell
    }
}

extension ViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //let bounds = collectionView.bounds
        let widthVal = self.view.frame.width
        let cellsize = widthVal/2
        print("widthValue")
        print(widthVal)
        return CGSize(width: cellsize-10   , height: cellsize-10)
    }
    
}

extension ViewController : UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let disPlayView = self.storyboard?.instantiateViewController(identifier: "DisplayViewController") as! DisplayViewController
        disPlayView.configure(image: photosInAlbums[indexPath.item])
        navigationController?.pushViewController(disPlayView, animated: true)
//        present(disPlayView, animated: true)
    }
}

// XLPager for this view controller

extension ViewController : IndicatorInfoProvider{
    func indicatorInfo(for pagerTabStripController: XLPagerTabStrip.PagerTabStripViewController) -> XLPagerTabStrip.IndicatorInfo {
        return IndicatorInfo(title: "Albums")
    }
    
    
}



