//
//  CustomButton.swift
//  creatingCalculatorAutoLayout
//
//  Created by logo_dev_f1 on 13/6/24.
//

import UIKit

@IBDesignable 
class CustomButton : UIButton{
    
    @IBInspectable
    var bgColor : UIColor?{
        set{
            backgroundColor = newValue
        }
        get{
            return backgroundColor
        }
    }
    
   
    
    override init(frame: CGRect){

        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
        print("mahedi khan")
        print(layer.bounds.midX)
//        setupButton()
    }

    func setupButton() {
        layer.cornerRadius = (self.frame.height/2)
    }
    
    private func setShadow() {
        layer.shadowColor   = UIColor.black.cgColor
//        layer.shadowOffset  = CGSize(width: 0.0, height: 6.0)
        layer.shadowRadius  = 8
        layer.shadowOpacity = 0.5
//        clipsToBounds       = true
//        layer.masksToBounds = false
    }
    
    func shake() {
        let shake           = CABasicAnimation(keyPath: "position")
        shake.duration      = 0.1
        shake.repeatCount   = 2
        shake.autoreverses  = true
        
        let fromPoint       = CGPoint(x: center.x - 8, y: center.y)
        let fromValue       = NSValue(cgPoint: fromPoint)
        
        let toPoint         = CGPoint(x: center.x + 8, y: center.y)
        let toValue         = NSValue(cgPoint: toPoint)
        
        shake.fromValue     = fromValue
        shake.toValue       = toValue
        
        layer.add(shake, forKey: "position")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        print(self.titleLabel?.text ?? "null")
        setupButton()
        // Custom layout code for subviews
    }
}


