//
//  ViewController.swift
//  practice
//
//  Created by logo_dev_f1 on 5/6/24.
//

import UIKit


// what is ok??
// what is temporaryArray??


    
    class ViewController: UIViewController {
        var temporayArrayForStoringOpearand : [Float] = []
        var operationSelectorFlag : Int = 0
        var currentNumber : String = ""
        var afterEqualFlag : Int = 0
        
        // rename
        @IBOutlet weak var displayLebel: UILabel!
        
        override func viewDidLoad() {
            super.viewDidLoad()
            // Do any additional setup after loading the view.
        }
        
        @IBAction func digitButtonPressed(_ sender: UIButton) {
            if afterEqualFlag == 1 {
                currentNumber = ""
                temporayArrayForStoringOpearand.removeAll()
                operationSelectorFlag = 0 ;
            }
            let text = sender.titleLabel?.text
            if let charecterPressd = text{
                currentNumber.append(charecterPressd)
                displayLebel.text = currentNumber
            }
        }
        // reset function for resetting all
        func resetAll(){
            displayLebel.text = ""
            currentNumber = ""
            operationSelectorFlag = 0 ;
            temporayArrayForStoringOpearand.removeAll()
            afterEqualFlag = 0 ;
        }
        //getting operationvalue
        func gettingOperationValue(operationSelectorFlag : Int , operandOne : Float , operandTwo : Float , temporayArrayForStoringValue : [Float]) -> Float{
            var value : Float = 0.0
            
            switch operationSelectorFlag{
            case 1: value = operandOne + operandTwo
            case 2: value = operandOne - operandTwo
            case 3: value = operandOne * operandTwo
            default: value = operandOne / operandTwo
            }
            
            return value
        }
        // getting selector flag
        func gettingSelectorFlag(operationPress : String , lengthOfTempArray : Int , operationSelectorFlag : Int) -> Int{
            switch (operationPress, lengthOfTempArray > 0){
            case ("+", true): return 1
            case ("-", true): return 2
            case ("X", true): return 3
            case ("/", true): return 4
            default: return operationSelectorFlag
            }
        }
        
        @IBAction func clearDisplay(_ sender: Any) {
            // make a method
           resetAll()
        }
        
        
        @IBAction func operationPressed(_ sender: UIButton) {
            guard let operationPress = sender.titleLabel?.text else {return}
            
            var inputValue : Float = 0.0
            if let floatValue = Float(currentNumber){
                inputValue = floatValue
            }
            
            
            temporayArrayForStoringOpearand.append(inputValue)
            var lenthOfTempArray = temporayArrayForStoringOpearand.count
            
            operationSelectorFlag = gettingSelectorFlag(operationPress: operationPress, lengthOfTempArray: lenthOfTempArray, operationSelectorFlag: operationSelectorFlag)
            
            afterEqualFlag = 0 ;
            temporayArrayForStoringOpearand.append(inputValue)
            // need to remove
            var finalValueAfterOperation : Float
            if operationPress == "=" && operationSelectorFlag != 0{
                
                if inputValue == 0.0{
                    displayLebel.text = "inf"
                    resetAll()
                    return
                }
                finalValueAfterOperation = gettingOperationValue(operationSelectorFlag: operationSelectorFlag, operandOne: temporayArrayForStoringOpearand[0], operandTwo: inputValue, temporayArrayForStoringValue: temporayArrayForStoringOpearand)
                
                var finalOutput = finalValueAfterOperation
                    temporayArrayForStoringOpearand.removeAll()
                    operationSelectorFlag = 0
                    let intValue = Int(finalValueAfterOperation)
                    displayLebel.text = Float(intValue) == finalValueAfterOperation ? String(describing: intValue) : String(describing: finalValueAfterOperation)
                    temporayArrayForStoringOpearand.append(finalValueAfterOperation)
                    afterEqualFlag = 1 ;
            }
            currentNumber = ""
        }
        
    }

