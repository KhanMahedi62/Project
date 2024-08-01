//
//  ParentViewController.swift
//  Photos Apps
//
//  Created by logo_dev_f1 on 16/7/24.
//

import UIKit
import Photos
import XLPagerTabStrip


class ParentViewController: ButtonBarPagerTabStripViewController, selectedImageProtocol{
    @IBOutlet weak var selctImageLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    var photosMetaData = albumMetaData()
    var childViewController = [UIViewController]()
    var collectionView: UICollectionView?
    let imageManager = PHCachingImageManager()
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var upperView: UIView!
    var indexPair = [currentIndexSelectedIndex]()
    
    
    func configure(metaData : albumMetaData){
        photosMetaData = metaData
    }
    
    struct currentIndexSelectedIndex{
        var currntIndex : Int?
        var selectedIndex : Int?
    }
    
    // for scrolling to the next Cell
    func scrollToNextCell(){
        let cellSize = CGSizeMake(self.view.frame.width, self.view.frame.height);
        let contentOffset = collectionView?.contentOffset;
        guard let content = contentOffset else{
            return
        }
        collectionView?.scrollRectToVisible(CGRectMake(content.x + cellSize.width, content.y, cellSize.width, cellSize.height), animated: true);
    }
    
    func selectedImageIndex(index : Int){
        let indexPairElement = currentIndexSelectedIndex(currntIndex: currentIndex, selectedIndex: index)
        indexPair.append(indexPairElement)
        if collectionView == nil{
            registerCollectionView()
        }
        self.updateHeightMultiplier(to: 162/self.view.frame.height)
        DispatchQueue.main.async{
            
            self.collectionView?.reloadData()
        }
        scrollToNextCell()
        print("here is index : ")
        if indexPair.count > 0{
            nextButton.alpha = 1
            nextButton.isUserInteractionEnabled = true
            self.selctImageLabel.text = "Selected \(indexPair.count) Clips"
        }
    }
    
    func deselection(index : Int){
        print(currentIndex , indexPair.count , index)
        for i in 0..<indexPair.count {
            if i < indexPair.count{
                if index == indexPair[i].selectedIndex && currentIndex == indexPair[i].currntIndex{
                    indexPair.remove(at: i)
                }
            }
        }
        DispatchQueue.main.async{
            self.collectionView?.reloadData()
        }
        if indexPair.count == 0 {
            nextButton.alpha = 0.5
            nextButton.isUserInteractionEnabled = true
            self.selctImageLabel.text = "Select one or more Clip"
            collectionView?.removeFromSuperview()
            collectionView = nil
            updateHeightMultiplier(to: 104/self.view.frame.height)
        }
        else{
            self.selctImageLabel.text = "Selected \(indexPair.count) Clips"
        }
        
    }
    
    func registerCollectionView(){
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = CGSize(width: 0, height: 0)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView?.register(UINib(nibName: "ImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ImageCell")
        collectionView?.dataSource = self
        collectionView?.delegate = self
        
    }
    
    func updateHeightMultiplier(to multiplier: CGFloat) {
        if let superview = upperView.superview {
            let existingConstraints = superview.constraints.filter { $0.firstItem === upperView && $0.firstAttribute == .height }
            superview.removeConstraints(existingConstraints)
        }
        let newHeightConstraint = NSLayoutConstraint(
            item: upperView!,
            attribute: .height,
            relatedBy: .equal,
            toItem: upperView.superview,
            attribute: .height,
            multiplier: multiplier,
            constant: 0
        )
        if let superview = upperView.superview {
            superview.addConstraint(newHeightConstraint)
        }
        heightConstraint = newHeightConstraint
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
        self.setupCollectionView()
    }
    
    
    private func setupCollectionView() {
        guard let collectionView = collectionView else { return }
        upperView.addSubview(collectionView)
        collectionView.backgroundColor = UIColor.clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.centerYAnchor.constraint(equalTo: upperView.centerYAnchor),
            collectionView.leadingAnchor.constraint(equalTo: upperView.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: upperView.trailingAnchor, constant: 0),
            collectionView.heightAnchor.constraint(equalTo: upperView.heightAnchor, multiplier: 58/upperView.bounds.height)
        ])
    }
    
    @IBAction func downArrowButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    //ovverriding function of xlpager For returning childViews
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        for i in 0..<photosMetaData.photosInAlbums.count{
            let childVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DisplayViewController") as! DisplayViewController
            childVC.barTitle = photosMetaData.albumNames[i]
            DispatchQueue.main.async{
                childVC.configure(image: self.photosMetaData.photosInAlbums[i], index: i)
            }
            childVC.selectedImageDelegate = self
            childViewController.append(childVC)
        }
        
        
        return childViewController
    }
    
    let currentTextColor = UIColor(red: 2/255.0, green: 202/255.0, blue: 254/255.0, alpha: 1.0)
    let oldTextColor  = UIColor(red: 104/255.0, green: 116/255.0, blue: 128/255.0, alpha: 1.0)
    override func viewDidLoad() {
        // change selected bar color
        settings.style.buttonBarItemBackgroundColor = UIColor(red: 30/255.0, green: 30/255.0, blue: 33/255.0, alpha: 1.0)
        if let gilroySemibold = UIFont(name: "Gilroy-Semibold", size: 15) {
            settings.style.buttonBarItemFont = gilroySemibold
        }
        settings.style.selectedBarHeight = 1.0
        settings.style.buttonBarMinimumLineSpacing = 18
        changeCurrentIndexProgressive = { [weak self] (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = self?.oldTextColor
            newCell?.label.textColor = self?.currentTextColor
            if let gilroySemibold = UIFont(name: "Gilroy-Semibold", size: 15) {
                newCell?.label.font = gilroySemibold
            }
            if let gilroyMedium = UIFont(name: "Gilroy-Medium", size: 15) {
                
                newCell?.label.font = gilroyMedium
            }
        }
        buttonBarView.delegate = self
        super.viewDidLoad()
        registerCollectionView()
        if indexPair.count == 0 {
            nextButton.alpha = 0.5
            nextButton.isUserInteractionEnabled = false
            self.selctImageLabel.text = "Select one or more Clip"
        }
        nextButton.layer.cornerRadius = 4
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionView {
            return indexPair.count
        }
        else{
            return viewControllers.count
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.collectionView {
            print("i am entering in the collectionview here ")
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as? ImageCollectionViewCell else {
                return UICollectionViewCell()
            }
            if let index = indexPair[indexPath.row].selectedIndex , let currentInd = indexPair[indexPath.row].currntIndex{
                print("hi this is \(index) \(currentIndex)")
                let asset = photosMetaData.photosInAlbums[currentInd][index]
                let targetSize = CGSize(width: 100, height: 100)
                self.imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: nil) { (image, _) in
                    if let image = image{
                        cell.configure(image: image)
                    }
                }
            }
            cell.imageView.layer.cornerRadius = 4.64
            return cell
        }
        else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? ButtonBarViewCell else {
                return UICollectionViewCell()
            }
            cell.label.text = photosMetaData.albumNames[indexPath.row]
            
            
            let childController = viewControllers[indexPath.item] as! IndicatorInfoProvider // swiftlint:disable:this force_cast
            let indicatorInfo = childController.indicatorInfo(for: self)
            
            cell.label.text = indicatorInfo.title
            cell.label.font = settings.style.buttonBarItemFont
            cell.label.textColor = settings.style.buttonBarItemTitleColor ?? cell.label.textColor
            cell.contentView.backgroundColor = settings.style.buttonBarItemBackgroundColor ?? cell.contentView.backgroundColor
            cell.backgroundColor = settings.style.buttonBarItemBackgroundColor ?? cell.backgroundColor
            if let image = indicatorInfo.image {
                cell.imageView.image = image
            }
            if let highlightedImage = indicatorInfo.highlightedImage {
                cell.imageView.highlightedImage = highlightedImage
            }
            
            configureCell(cell, indicatorInfo: indicatorInfo)
            
            if pagerBehaviour.isProgressiveIndicator {
                if let changeCurrentIndexProgressive = changeCurrentIndexProgressive {
                    changeCurrentIndexProgressive(currentIndex == indexPath.item ? nil : cell, currentIndex == indexPath.item ? cell : nil, 1, true, false)
                }
            } else {
                if let changeCurrentIndex = changeCurrentIndex {
                    changeCurrentIndex(currentIndex == indexPath.item ? nil : cell, currentIndex == indexPath.item ? cell : nil, false)
                }
            }
            cell.isAccessibilityElement = true
            cell.accessibilityLabel = indicatorInfo.accessibilityLabel ?? cell.label.text
            cell.accessibilityTraits.insert([.button, .header])
            return cell
        }
    }
    
    
    func calculateLabelWidth(text: String, font: UIFont, maxWidth: CGFloat) -> CGFloat {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = font
        label.text = text
        label.frame.size = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
        label.sizeToFit()
        return label.frame.size.width
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        if collectionView == self.collectionView {
            print("I am in heree")
            let collectionViewHeight = collectionView.frame.height
            print("collection View Height \(collectionViewHeight)")
            return CGSize(width: collectionViewHeight, height: collectionViewHeight)
        }
        else{
            let text = photosMetaData.albumNames[indexPath.row]
            let font = UIFont.systemFont(ofSize: 18)
            let maxWidth: CGFloat = 300
            let width = calculateLabelWidth(text: text, font: font, maxWidth: maxWidth)
            return CGSize(width: CGFloat(width + 10) , height: collectionView.frame.size.height)
        }
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











