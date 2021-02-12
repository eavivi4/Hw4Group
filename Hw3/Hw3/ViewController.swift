//
//  ViewController.swift
//  Hw1
//
//  Created by Eden Avivi on 1/13/21.
//

import UIKit
import PhoneNumberKit
var e164 = ""
class ViewController: UIViewController {
    // outlet declaration
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var phoneTextView: PhoneNumberTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // intialize the screen with default actions like no errors or confirmation showing and keyboard dismiss gesture recognizer
        errorLabel.text = nil
        let tapView = UITapGestureRecognizer(target: self, action: #selector(tapFunc))
        view.addGestureRecognizer(tapView)
        
        //Show the last correctly verified phoneNumber
        if Storage.phoneNumberInE164 != nil && Storage.authToken != nil {
            let storageNumber = Storage.phoneNumberInE164
            let newStorageNum = String(storageNumber?.dropFirst(2) ?? "") //cast as string and drop +1
            phoneTextView.text = newStorageNum
        }
    }
    
    // selector for UI tap gesture recognizer
    @objc func tapFunc() {
        view.endEditing(true)
    }
    
    // MARK: -UI action handlers
    @IBAction func confirmButton() {
    
        // if pressing the confirmation button, make keyboard go away
        self.view.endEditing(true)
        
        // convert to e164 style
        if var phoneNumber = phoneTextView.text {
            let e164Clear: Set<Character> = ["(", ")", "-", " "]
            phoneNumber.removeAll(where: {e164Clear.contains($0)})
            
            // error checking starting with empty number, erasing country code, valid characters and then length checking
            if phoneNumber.isEmpty {
                errorLabel.textColor = UIColor.red
                errorLabel.text = "Please enter a phone number"
            } else if phoneNumber.contains("*") == true {
                errorLabel.textColor = UIColor.red
                errorLabel.text = "Please enter a phone number without * sign"
            } else if phoneNumber.contains("#") == true {
                errorLabel.textColor = UIColor.red
                errorLabel.text = "Please enter a phone number without # sign"
            } else if phoneNumber.contains("+") == true {
                errorLabel.textColor = UIColor.red
                errorLabel.text = "Please enter a phone number without + sign"
            } else if phoneNumber.prefix(1) == "0" {
                errorLabel.textColor = UIColor.red
                errorLabel.text = "Please do not enter leading zeros"
            } else if phoneNumber.prefix(1) == "1" {
                errorLabel.textColor = UIColor.red
                errorLabel.text = "Please do not enter the country code"
                //Because of area code +1 for US
            } else if phoneNumber.count < 10 {
                errorLabel.textColor = UIColor.red
                errorLabel.text = "Please enter a full phone number"
            } else if phoneNumber.count > 10 {
                errorLabel.textColor = UIColor.red
                errorLabel.text = "Please enter a phone number with less numbers"
            } else {
                //Move to next page here
                e164 = "+1" + phoneNumber
                if Storage.phoneNumberInE164 == e164 {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let walletViewController = storyboard.instantiateViewController(withIdentifier: "walletViewController")
                    let viewControllers = [walletViewController]

                    self.navigationController?.setViewControllers(viewControllers, animated: true)
                    self.navigationController?.setNavigationBarHidden(true, animated: true)
                } else {
              
                Api.sendVerificationCode(phoneNumber: e164, completion: { response, error in
                    //in case of error
                    if error == nil && response != nil {
                        //in case of success
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        guard let verificationViewController = storyboard.instantiateViewController(withIdentifier: "verificationViewController") as? VerificationViewController else {
                            assertionFailure("couldn't find vc")
                            return
                        }
                        self.navigationController?.pushViewController(verificationViewController, animated: true)
                    } else {
                        if let err = error?.message {
                            self.errorLabel.textColor = UIColor.red
                            self.errorLabel.text = err
                        }
                    }
                        
                })
            }
        }
    }
        
    }
}

