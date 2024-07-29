//
//  ChildViewController.swift
//  Photos Apps
//
//  Created by logo_dev_f1 on 16/7/24.
//

import UIKit
import XLPagerTabStrip
class ChildViewController: UIViewController {
    var activityIndicator: UIActivityIndicatorView!
    var itemInfo : IndicatorInfo?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        activityIndicator = UIActivityIndicatorView(style: .large)
           activityIndicator.color = .white
           activityIndicator.hidesWhenStopped = true
           activityIndicator.center = view.center
           view.addSubview(activityIndicator)
         activityIndicator.startAnimating()
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

extension ChildViewController : IndicatorInfoProvider{
    public func indicatorInfo(for pagerTabStripController: XLPagerTabStrip.PagerTabStripViewController) -> XLPagerTabStrip.IndicatorInfo {
        return IndicatorInfo(title: "Photo Apps")
    }
    
    
}


