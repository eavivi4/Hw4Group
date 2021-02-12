//
//  VerificationViewController.swift
//  Hw1
//
//  Created by Eden Avivi on 1/23/21.
//

import UIKit
import PhoneNumberKit


class VerificationViewController: UIViewController, PinTexFieldDelegate, UITextFieldDelegate {
    var fields: [PinTextField?] = []
    var currentField = 0

    // have a protocol and fix the deletion problem
    @IBOutlet weak var number1TextField: PinTextField!
    @IBOutlet weak var number2TextField: PinTextField!
    @IBOutlet weak var number3TextField: PinTextField!
    @IBOutlet weak var number4TextField: PinTextField!
    @IBOutlet weak var number5TextField: PinTextField!
    @IBOutlet weak var number6TextField: PinTextField!
    
    @IBOutlet weak var verfError: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set the UIGesture for the keyboard
        let tapView = UITapGestureRecognizer(target: self, action: #selector(tapFunc))
        view.addGestureRecognizer(tapView)
        
        //make error display disappear when no error is displayed
        verfError.text = nil
        
        //set delegates for each text field
        number1TextField.delegate = self
        number2TextField.delegate = self
        number3TextField.delegate = self
        number4TextField.delegate = self
        number5TextField.delegate = self
        number6TextField.delegate = self
        
        //Correction
        self.currentField = 0
        number1TextField.becomeFirstResponder()
        
        
        //initialize array so it will be easier to use
        fields = [number1TextField, number2TextField, number3TextField, number4TextField, number5TextField, number6TextField]
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range:NSRange, replacementString string: String) -> Bool
    {
        let currentText = textField.text ?? ""
        guard let range = Range(range, in: currentText) else {
            assertionFailure("range not defined")
            return true
        }
        let newText = currentText.replacingCharacters(in: range, with: string)

        //initialize the currentField for the appriopriate textField in case we are clicking on the a specific textField
        switch textField {
            case number1TextField:
                currentField = 0
            case number2TextField:
            currentField = 1
            case number3TextField:
                currentField = 2
            case number4TextField:
                currentField = 3
            case number5TextField:
                currentField = 4
            case number6TextField:
                currentField = 5
            default:
                break
            
        }
        if newText.count <= 1 {
            if newText.count == 0 {
                //if we are about to erase a field and there is a number after it, move everything back
                //but stay on the current textfield
                if currentField == 5 {
                    //if we are at the last field and we somehow got here, make it so the didPressBackspace goes
                    return true
                }
                if fields[currentField+1]?.text != "" {
                    var tempIndex = currentField
                    //loop through fields and move them back by one
                    while fields[tempIndex+1]?.text != nil {
                        //switch
                        fields[tempIndex]?.text = fields[tempIndex+1]?.text
                        //make last textfield always nil
                        fields[tempIndex+1]?.text = nil
                        tempIndex += 1
                        //if we are at the last text field, get out of loop
                        if tempIndex == 5 {
                            break
                        }
                    }
                    if currentField != 0
                    {
                        currentField -= 1
                        fields[currentField]?.becomeFirstResponder()
                    }
                } else {
                return true
                }
            } else {
                //if count is 1, regular case
                return true
            }
        } else {
            //case in which we are on a textField that already has a number in it and want to write more
            if currentField == 5 {
                //if we are trying to enter a character and we are at the last text field, just verify again
                //don't let the user type more than one character in that field
                OTPFieldVerify()
                return false
            }
            
            //save currentField so that it won't change
            var tempIndex = currentField
            //save the next text to be moved later
            var saveLater = fields[tempIndex+1]?.text
            //replace the next text field with the character entered, so it will be added after
            fields[tempIndex+1]?.text = String(newText[newText.index(before: newText.endIndex)])
            //go to the textfield with the new number
            tempIndex += 1
            //check that we are not at the last textfield, to not go out of range
            while tempIndex != 5 && fields[tempIndex+1]?.text != nil {
                //saveLater = detached, next = next textfield to be detached so it won't be over written
                
                //save the next textfield so it won't be overwritten by changing it to the previous textfield
                let next = fields[tempIndex+1]?.text
                //use the previously saved text to set the next text field
                fields[tempIndex+1]?.text = saveLater
                
                //make savelater what was previously saved
                saveLater = next ?? ""
                
                tempIndex += 1
                //can't access element after last text field
                if tempIndex == 5 {
                    break
                }
            }
            //make the changed textfield, the first responder and continue as usual
            fields[currentField+1]?.becomeFirstResponder()
            OTPFieldVerify()
        }
        return false
    }
    
    func OTPFieldVerify() {
        let fieldsString = fields.compactMap{$0?.text}
        let codeParameter = fieldsString.reduce("") { $0 + $1}
        if codeParameter.count == 6 {
                Api.verifyCode(phoneNumber: e164, code: codeParameter, completion: { response, error in
                    if error == nil {
                        //preparation
                        Storage.phoneNumberInE164 = e164
                        let authToken = response?["auth_token"] as? String
                        Storage.authToken = authToken
                                        
                        //move onto next view controller
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let walletViewController = storyboard.instantiateViewController(withIdentifier: "walletViewController")
                        let viewControllers = [walletViewController]
                        self.navigationController?.setViewControllers(viewControllers, animated: true)
                        self.navigationController?.setNavigationBarHidden(true, animated: true)
                        
                    } else {
                        if let err = error?.message {
                            self.verfError.textColor = UIColor.red
                            self.verfError.text = err
                        }
                    }
                })
        }
}
    
    // selector for UI tap gesture recognizer
    @objc func tapFunc() {
        view.endEditing(true)
    }
    
    @IBAction func resendButton() {
        
      //resend the code, do the same thing in the previous view controller
        Api.sendVerificationCode(phoneNumber: e164, completion: { response, error in
            if error != nil && response == nil {
                if let err = error?.message {
                    self.verfError.textColor = UIColor.red
                    self.verfError.text = err
                }
            }
        })
    }
    
    
    // MARK: -PinTexFieldDelegate protocol implementation
    func didPressBackspace(textField: PinTextField) {
        //Regular backspace cases: need two cases
        //one where we are on the current field and one where we are on the field after (count 1 or 0)
        if let current = textField.text {
            if current.count == 1 {
                switch textField {
                    case self.number1TextField:
                            self.currentField = 0
                            self.number1TextField = nil
                    case self.number2TextField:
                            currentField = 1
                            self.fields[currentField]?.text = nil
                            self.currentField -= 1
                            self.fields[currentField]?.becomeFirstResponder()
                    case self.number3TextField:
                            currentField = 2
                            self.fields[currentField]?.text = nil
                            self.currentField -= 1
                            self.fields[currentField]?.becomeFirstResponder()
                    case self.number4TextField:
                            currentField = 3
                            self.fields[currentField]?.text = nil
                            self.currentField -= 1
                            self.fields[currentField]?.becomeFirstResponder()
                    case self.number5TextField:
                        currentField = 4
                        self.fields[currentField]?.text = nil
                        self.currentField -= 1
                        self.fields[currentField]?.becomeFirstResponder()
                    case self.number6TextField:
                        currentField = 5
                        self.fields[currentField]?.text = nil
                        self.currentField -= 1
                        self.fields[currentField]?.becomeFirstResponder()
                    default:
                            break
                    }
            } else {
                // if we are in an empty place and we press delete, we delete the previous one and go into it
                switch textField {
                case self.number2TextField:
                    self.currentField -= 1
                    self.fields[currentField]?.becomeFirstResponder()
                    self.fields[currentField]?.text = nil
                case self.number3TextField:
                    self.currentField -= 1
                    self.fields[currentField]?.becomeFirstResponder()
                    self.fields[currentField]?.text = nil
                case self.number4TextField:
                    self.currentField -= 1
                    self.fields[currentField]?.becomeFirstResponder()
                    self.fields[currentField]?.text = nil
                case self.number5TextField:
                    self.currentField -= 1
                    self.fields[currentField]?.becomeFirstResponder()
                    self.fields[currentField]?.text = nil
                case self.number6TextField:
                    self.currentField -= 1
                    self.fields[currentField]?.becomeFirstResponder()
                    self.fields[currentField]?.text = nil
                default:
                    break
                }
            }
        }
        
    }
}
