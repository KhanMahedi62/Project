//
//  ViewController.swift
//  practice
//
//  Created by logo_dev_f1 on 5/6/24.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var lebel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func add(_ a: Any, _ b: Any) -> Any? {
        if let intA = a as? Int, let intB = b as? Int {
            return intA + intB
        } else if let floatA = a as? Float, let floatB = b as? Float {
            return floatA + floatB
        } else if let intA = a as? Int, let floatB = b as? Float {
            return Float(intA) + floatB
        } else if let floatA = a as? Float, let intB = b as? Int {
            return floatA + Float(intB)
        } else {
            return nil
        }
    }
    
    
    func multiply(_ a: Any, _ b: Any) -> Any? {
        if let intA = a as? Int, let intB = b as? Int {
            return intA * intB
        } else if let floatA = a as? Float, let floatB = b as? Float {
            return floatA * floatB
        } else if let intA = a as? Int, let floatB = b as? Float {
            return Float(intA) * floatB
        } else if let floatA = a as? Float, let intB = b as? Int {
            return floatA * Float(intB)
        } else {
            return nil
        }
    }
    
    
    func divide(_ a: Any, _ b: Any) -> Any? {
        if let intA = a as? Int, let intB = b as? Int {
            
            if intB != 0 {
                if intA % intB != 0{
                    return Float(intA)*1.0/Float(intB)*1.0
                }
                else {
                    return intA / intB
                }
            } else {
                return nil
            }
        } else if let floatA = a as? Float, let floatB = b as? Float {
            if floatB != 0.0 {
                return floatA / floatB
            } else {
                return nil
            }
        } else if let intA = a as? Int, let floatB = b as? Float {
            if floatB != 0.0 {
                return Float(intA) / floatB
            } else {
                return nil
            }
        } else if let floatA = a as? Float, let intB = b as? Int {
            if intB != 0 {
                return floatA / Float(intB)
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    func subtract(_ a: Any, _ b: Any) -> Any? {
        if let intA = a as? Int, let intB = b as? Int {
            return intA - intB
        } else if let floatA = a as? Float, let floatB = b as? Float {
            return floatA - floatB
        } else if let intA = a as? Int, let floatB = b as? Float {
            return Float(intA) - floatB
        } else if let floatA = a as? Float, let intB = b as? Int {
            return floatA - Float(intB)
        } else {
            return nil
        }
    }
    
    
    
    var gloabalVal : [Any] = []
    var ok : Int = 0
    var currentNumber : String = ""
    @IBAction func btn(_ sender: UIButton) {
        if okk == 1 {
            currentNumber = ""
            gloabalVal.removeAll()
            ok = 0 ;
        }
        let text = sender.titleLabel?.text
        if let vl = text{
            print(vl)
            
            currentNumber.append(vl)
            lebel.text = currentNumber
        }
    }
    
 
    
    @IBAction func clearDisplay(_ sender: Any) {
        lebel.text = ""
        currentNumber = ""
        ok = 0 ;
        gloabalVal.removeAll()
    }
    
    var okk : Int = 0 ;
    @IBAction func operationPressed(_ sender: UIButton) {
        print("khanmahedi")
        let text = sender.titleLabel?.text
 
        if let digit = text{
     
            print(digit)
            var num : Any = 0
            
//                for i in 0..<currentNumber.count {
//                    let index = currentNumber.index(currentNumber.startIndex, offsetBy: i)
//                    let value : Character = currentNumber[index]
//                    
//                    if let vl = Int(String (value)){
//                        num = num*10 + vl ;
//                        
//                    }else{
//                        
//                    }
//                }
            var len : Int = 0
            for i in 0..<currentNumber.count {
                let index = currentNumber.index(currentNumber.startIndex, offsetBy: i)
                if currentNumber[index] == "." {
                    len = i+1 ;
                }
            }
            
            if let val = Int(currentNumber){
                num = val
            }
            else {
                if let fVal = Float(currentNumber){
                    num = fVal
                }
                else{
                    
                }
            }
            
            print(num)
            gloabalVal.append(num)
            print(gloabalVal.count)
            if digit == "+" && gloabalVal.count > 0{
                ok = 1
            }
            
            if digit == "-" && gloabalVal.count > 0 {
                ok = 2 ;
            }
            
            if digit ==  "X" && gloabalVal.count > 0{
                ok = 3 ;
            }
            print("dig \(digit)")
            if digit == "/" && gloabalVal.count > 0 {
                ok = 4
            }
            okk = 0 ;
            print("yes \(ok)")
            
            gloabalVal.append(num)
            print("num \(num)")
            var value : Any?
            if digit == "=" && ok != 0{
               
                if ok == 1{
                    value = add(gloabalVal[0], num)
                    print("value \(value) + \(gloabalVal[0])")
                }
                if ok == 2 {
                    value = subtract(gloabalVal[0], num)
                }
                if ok == 3 {
                    value = multiply(gloabalVal[0],num)
                }
                if ok == 4 {
                    print("ok \(ok)")
                  
                    value = divide(gloabalVal[0], num)
                    print("value \(value)")
                }
                
             
                if let vl = value{
                    gloabalVal.removeAll()
                    ok = 0
                    print("here \(currentNumber)")
                    var curr  = String(describing: vl)
                    
                    lebel.text = curr
                    gloabalVal.append(vl)
                    print("array val \(gloabalVal[0])")
                    okk = 1 ;
                }
                    
                   
                   
                
                
            }
            currentNumber = ""
        }
    }
    
}

