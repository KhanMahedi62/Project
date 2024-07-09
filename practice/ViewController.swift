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
    var operationString : String = ""
    var currentNumber : String = ""
    var afterEqualFlag : Int = 0
    var charFlag : Bool = false
    
    @IBOutlet weak var zeroButton: UIButton!
    @IBOutlet weak var divisionButton: UIButton!
    @IBOutlet weak var twoButton: UIButton!
    @IBOutlet weak var sevenButton: UIButton!
    @IBOutlet weak var sixButton: UIButton!
    @IBOutlet weak var fiveButton: UIButton!
    @IBOutlet weak var fourButton: UIButton!
    
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var multiplicationButton: UIButton!
    @IBOutlet weak var threeButton: UIButton!
    @IBOutlet var customButton: CustomButton!

    @IBOutlet weak var reminderButton: UIButton!
    @IBOutlet weak var plusMinusButton: UIButton!
    @IBOutlet weak var dotButton: UIButton!
    @IBOutlet weak var nineButton: UIButton!
    @IBOutlet weak var eightButton: UIButton!
    @IBOutlet weak var buttonOne: UIButton!
    
    @IBOutlet weak var plusButton: UIButton!
    
    @IBOutlet weak var equalButton: UIButton!
    
    @IBOutlet var buttonArray = [UIButton]()
    
    // rename
    @IBOutlet weak var displayLebel: UILabel!
    
    @IBOutlet weak var clear: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
//        view.layoutIfNeeded()
//        print(equalButton.bounds.height)
//        clear.layer.cornerRadius = clear.bounds.height/2
//        buttonOne.layer.cornerRadius = buttonOne.bounds.height/2
//        twoButton.layer.cornerRadius = twoButton.bounds.height/2
//        threeButton.layer.cornerRadius = threeButton.bounds.height/2
//        fourButton.layer.cornerRadius = fourButton.bounds.height/2
//        fiveButton.layer.cornerRadius = fiveButton.bounds.height/2
//        sixButton.layer.cornerRadius = sixButton.bounds.height/2
//        sevenButton.layer.cornerRadius = sevenButton.bounds.height/2
//        eightButton.layer.cornerRadius = eightButton.bounds.height/2
//        nineButton.layer.cornerRadius = nineButton.bounds.height/2
//        multiplicationButton.layer.cornerRadius = multiplicationButton.bounds.height/2
//        minusButton.layer.cornerRadius = minusButton.bounds.height/2
//        plusButton.layer.cornerRadius = plusButton.bounds.height/2
//        dotButton.layer.cornerRadius = dotButton.bounds.height/2
//        equalButton.layer.cornerRadius = equalButton.bounds.height/2
//        divisionButton.layer.cornerRadius = divisionButton.bounds.height/2
//        plusMinusButton.layer.cornerRadius = plusMinusButton.bounds.height/2
//        reminderButton.layer.cornerRadius = reminderButton.bounds.height/2
//        zeroButton.layer.cornerRadius = zeroButton.bounds.height/2
        // Do any additional setup after loading the view.
    }
    
    @IBAction func digitButtonPressed(_ sender: UIButton) {
        if afterEqualFlag == 1 {
            currentNumber = ""
            temporayArrayForStoringOpearand.removeAll()
            operationString = ""
        }
        if let charecterPressd = sender.titleLabel?.text{
            if charecterPressd == "." && charFlag{
                return
            }
            if charecterPressd == "." {
                charFlag = true
            }
            currentNumber.append(charecterPressd)
            displayLebel.text = currentNumber
        }
    }
    enum Operation {
        case addition
        case subtraction
        case multiplication
        case division
    }

    func performOperation(_ num1: Float, _ num2: Float, operationString: String) -> Float? {
        guard let operation = operation(operationString) else {
            return nil
        }
        switch operation {
        case .addition:
            return num1 + num2
        case .subtraction:
            return num1 - num2
        case .multiplication:
            return num1 * num2
        case .division:
            guard num2 != 0 else {
                return nil
            }
            return num1 / num2
        }
    }

    func operation(_ operationString: String) -> Operation? {
        switch operationString {
        case "+":
            return .addition
        case "-":
            return .subtraction
        case "X":
            return .multiplication
        case "/":
            return .division
        default:
            return nil
        }
    }

    func resetAll(){
        currentNumber = ""
        operationString = ""
        temporayArrayForStoringOpearand.removeAll()
        afterEqualFlag = 0
        charFlag = false
        return;
    }

    @IBAction func clearDisplay(_ sender: Any) {
        displayLebel.text = ""
        resetAll()
    }
    
    @IBAction func operationPressed(_ sender: UIButton) {
        guard let operationPress = sender.titleLabel?.text else {return}

        var inputValue : Float = 0.0
        if let floatValue = Float(currentNumber){
            inputValue = floatValue
        }
        temporayArrayForStoringOpearand.append(inputValue)
        if operationPress != "=" {
            operationString = operationPress
        }
        afterEqualFlag = 0
        temporayArrayForStoringOpearand.append(inputValue)
        if operationPress == "=" && operationString != ""{
            if let finalValueAfterOperation = performOperation(temporayArrayForStoringOpearand[0], inputValue, operationString: operationString){
                temporayArrayForStoringOpearand.removeAll()
                operationString = ""
                let intValue = Int(finalValueAfterOperation)
                displayLebel.text = Float(intValue) == finalValueAfterOperation ? String(describing: intValue) : String(describing: finalValueAfterOperation)
                temporayArrayForStoringOpearand.append(finalValueAfterOperation)
                afterEqualFlag = 1
                charFlag = false
            }
            else{
                displayLebel.text = "inf"
                charFlag = false
                resetAll()
                return
            }
        }
        currentNumber = ""
    }
}

