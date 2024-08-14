//
//  HomeViewController.swift
//  Photos Apps
//
//  Created by logo_dev_f1 on 28/7/24.
//

import UIKit
import Photos
var mediaManager = MediaManager()

struct AlbumMetaData{
    var albumNames = [String]()
    var photosInAlbums = [[PHAsset]]()
}

class HomeViewController: UIViewController  {
    @IBOutlet weak var label: UILabel!
    
//    func DidFinish(image1: UIImage, image2: UIImage) {
//        <#code#>
//    }
    
    
    var firstTimeCallOfParentViewFlag = false
    var metaData = AlbumMetaData()
    @IBOutlet weak var imageViewTwo: UIImageView!
    @IBOutlet weak var imageViewOne: UIImageView!
    @IBAction func photosButtonAction(_ sender: Any) {
        if firstTimeCallOfParentViewFlag == false{
            mediaManager.requestAuthorization { [weak self] isAuthorized in
                guard let self = self else { return }
                
                if isAuthorized {
                    mediaManager.fetchAlbums { [weak self] albumNames, photosInAlbums in
                        guard let self = self else { return }
                        DispatchQueue.main.async {
                            self.metaData = AlbumMetaData(albumNames: albumNames , photosInAlbums: photosInAlbums)
                            let parentView = self.storyboard?.instantiateViewController(identifier: "PagerTabStripViewController") as! ParentViewController
                            parentView.configure(metaData: self.metaData)
                            self.firstTimeCallOfParentViewFlag = true
                            parentView.modalPresentationStyle = .fullScreen
                            self.present(parentView, animated: true, completion: nil)
                        }
                    }
                } else {
                    print("Access denied to photo library.")
                }
            }
        }
        else{
            let parentView = self.storyboard?.instantiateViewController(identifier: "PagerTabStripViewController") as! ParentViewController
            parentView.configure(metaData : self.metaData)
            parentView.modalPresentationStyle = .fullScreen
            self.present(parentView, animated: true, completion: nil)
        }
    }
    
    func DidFinish(image1: UIImage, image2: UIImage) {
        imageViewOne.image = image1
        imageViewTwo.image = image2
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
