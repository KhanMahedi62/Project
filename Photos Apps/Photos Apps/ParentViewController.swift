//
//  ParentViewController.swift
//  Photos Apps
//
//  Created by logo_dev_f1 on 16/7/24.
//

import UIKit
import Photos
import XLPagerTabStrip



class ParentViewController: ButtonBarPagerTabStripViewController{
    var albumNames = [String]()
    var photosInAlbums = [[PHAsset]]()
    var childViewController = [UIViewController]()
    var totalAlbums = 0
    var albumToIndexMap : [String : Int] = [:]

    func configure(photoAlbums : [[PHAsset]] , albumNames : [String]){
        photosInAlbums = photoAlbums
        self.albumNames = albumNames
    }
    
   
    
    //ovverriding function of xlpager For returning childViews
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        for i in 0..<photosInAlbums.count{
                let childVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DisplayViewController") as! DisplayViewController
                childVC.barTitle = self.albumNames[i]
                DispatchQueue.main.async{
                    childVC.configure(image: self.photosInAlbums[i], index: i)
                }
            albumToIndexMap[albumNames[i]] = i
                childViewController.append(childVC)
        }
        
        return childViewController
    }
    
    let lightGreenColor = UIColor(red: 0.65, green: 0.85, blue: 0.45, alpha: 1.0)
    override func viewDidLoad() {
        // change selected bar color
        settings.style.buttonBarBackgroundColor = .white
        settings.style.buttonBarItemBackgroundColor = .white
        settings.style.selectedBarBackgroundColor = lightGreenColor
        settings.style.buttonBarItemFont = .boldSystemFont(ofSize: 14)
        settings.style.selectedBarHeight = 2.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = .black
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        changeCurrentIndexProgressive = { [weak self] (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = .black
            newCell?.label.textColor = self?.lightGreenColor
            if let text = newCell?.label.text{
                if let index = self?.albumToIndexMap[text]{
                    if let child = self?.childViewController[index] as?
                        DisplayViewController{
//                        print(child)
//                        child.trackCell.removeAll()
//                        child.collectionView?.reloadData()
//                        if let oldText = oldCell?.label.text{
//                            if let oldIndex = self?.albumToIndexMap[text]{
//                                if let oldChild = self?.childViewController[oldIndex] as? DisplayViewController{
//                                    print("old image \(oldChild.countImage)")
//                                    child.countImage = oldChild.countImage
//                                }
//                            }
//                        }
                        child.updateSelectedCount()
                        
                    }
                }
            }
        }
        buttonBarView.delegate = self
        super.viewDidLoad()
        
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



