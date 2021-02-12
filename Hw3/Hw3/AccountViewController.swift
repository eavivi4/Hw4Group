//
//  AccountViewController.swift
//  Hw3
//
//  Created by Eden Avivi on 2/9/21.
//

import UIKit



class AccountViewController: UIViewController, UIPickerViewDataSource, UIPickerViewAccessibilityDelegate {
    
    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var totalAmountLabel: UILabel!
    
    @IBOutlet weak var pickerPopUp: UIPickerView!
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var popUpTextField: UITextField!
    @IBOutlet weak var popUpErrLabel: UILabel!
    
    @IBOutlet weak var doneButtonOutlet: UIButton!
    @IBOutlet weak var depositOutlet: UIButton!
    @IBOutlet weak var withdrawOutlet: UIButton!
    @IBOutlet weak var transferOutlet: UIButton!
    @IBOutlet weak var deleteOutlet: UIButton!
    @IBOutlet var tapGestureRecognizer: UITapGestureRecognizer!
    
    var accountsToTransfer : [Account] = []
    var pickedAccountIndex = 0
    var currentCell = Account()
    var currentIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //initialize labels by account
        accountNameLabel.text = currentCell.name
        totalAmountLabel.text = String(format: "%.2f", currentCell.amount)
        
        //set popup
        popUpView.center = CGPoint(x: self.view.center.x, y: self.view.center.y)
        popUpView.isHidden = true
        pickerPopUp.dataSource = self
        pickerPopUp.delegate = self
        popUpErrLabel.text = nil
        self.tapGestureRecognizer.isEnabled = false
        
        //initialize array for UIPicker
        accountsToTransfer = w.accounts
        accountsToTransfer.remove(at: currentIndex)
        
    }
    
    @IBAction func doneButton() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let walletViewController = storyboard.instantiateViewController(withIdentifier: "walletViewController")
        let viewControllers = [walletViewController]
        self.navigationController?.setViewControllers(viewControllers, animated: true)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    @IBAction func depositButton() {
        
        //adds actions to alert for the popup
        let alert = UIAlertController(title: "Deposit", message: "Enter how much to deposit", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Enter", comment: "Cancel action"), style: .default, handler: { _ in
            let text = Double(alert.textFields?.first?.text ?? "0")
            
            //deposit
            Api.deposit(wallet: w, toAccountAt: self.currentIndex, amount: text ?? 0.0, completion: { _, _ in
        
            })
            
            //update amount on label
            self.totalAmountLabel.text = String(format: "%.2f", w.accounts[self.currentIndex].amount)
            //disable keyboard
            self.view.endEditing(true)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Default action"), style: .cancel, handler: { _ in
            
            //disable keyboard
            self.view.endEditing(true)
            
        }))
        
        //have textfield for amount
        alert.addTextField(configurationHandler: {_ in
            alert.textFields?.first?.keyboardType = UIKeyboardType.decimalPad
        })
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func withdrawButton() {
        
        //adds actions to alert for the popup
        let alert = UIAlertController(title: "Withdraw", message: "Enter how much to withdraw", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Enter", comment: "Cancel action"), style: .default, handler: { _ in
            
            let text = Double(alert.textFields?.first?.text ?? "0")
            var number = text ?? 0.0
            let difference = w.accounts[self.currentIndex].amount - number
            
            //check so that there isn't a negative balance
            if difference < 0 {
                //if withdrawing too much, just take all the amount in account
                number = w.accounts[self.currentIndex].amount
            }
            Api.withdraw(wallet: w, fromAccountAt: self.currentIndex, amount: number, completion: { _, _ in
            })
            
            //update amount on label
            self.totalAmountLabel.text = String(format: "%.2f", w.accounts[self.currentIndex].amount)
            //disable keyboard
            self.view.endEditing(true)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Default action"), style: .cancel, handler: { _ in
            
            //disable keyboard
            self.view.endEditing(true)
            
        }))
        
        //have textfield for amount
        alert.addTextField(configurationHandler: {_ in
            alert.textFields?.first?.keyboardType = UIKeyboardType.decimalPad
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func transferButton() {
        
        //set the custom popup
        popUpView.isHidden = false
        depositOutlet.isUserInteractionEnabled = false
        transferOutlet.isUserInteractionEnabled = false
        withdrawOutlet.isUserInteractionEnabled = false
        deleteOutlet.isUserInteractionEnabled = false
        doneButtonOutlet.isUserInteractionEnabled = false
        popUpView.layer.shadowColor = UIColor.black.cgColor
        popUpView.layer.shadowOpacity = 0.3
        popUpView.layer.shadowOffset = .zero
        popUpView.layer.shadowRadius = 10
        popUpView.backgroundColor = UIColor.white
        popUpView.layer.cornerRadius = 25
        
    }
    @IBAction func popUpDone() {
        
        //when done, set variable for amount
        let transferAmount = Double(popUpTextField?.text ?? "0.0") ?? 0.0
        let difference = w.accounts[self.currentIndex].amount - transferAmount
        
        //check so that there isn't a negative balance
        if difference < 0 {
            //if withdrawing too much, make error
            popUpErrLabel.text = "No sufficient funds"
            popUpErrLabel.textColor = .red
            
        } else {
            
            //hide pop up
            popUpView.isHidden = true
            depositOutlet.isUserInteractionEnabled = true
            transferOutlet.isUserInteractionEnabled = true
            withdrawOutlet.isUserInteractionEnabled = true
            deleteOutlet.isUserInteractionEnabled = true
            doneButtonOutlet.isUserInteractionEnabled = true
            
            //since the pickedIndex is always off by one, change it so it  points to correct account to transfer to
            if currentIndex == pickedAccountIndex {
                if currentIndex == w.accounts.count {
                    pickedAccountIndex -= 1
                } else {
                    pickedAccountIndex += 1
                }
            }
        
            //transfer
            Api.transfer(wallet: w, fromAccountAt: currentIndex, toAccountAt: pickedAccountIndex, amount: transferAmount, completion: { _, _ in
            
            })
        
            //update amount on label
            self.totalAmountLabel.text = String(format: "%.2f", w.accounts[self.currentIndex].amount)
            
            //update UIPicker after transfer
            pickerPopUp.reloadAllComponents()
            
            //disable keyboard
            self.view.endEditing(true)
            popUpTextField.text = nil
        }
    }
    
    @IBAction func popUpX() {
        
        //hide pop up
        popUpView.isHidden = true
        depositOutlet.isUserInteractionEnabled = true
        transferOutlet.isUserInteractionEnabled = true
        withdrawOutlet.isUserInteractionEnabled = true
        deleteOutlet.isUserInteractionEnabled = true
        doneButtonOutlet.isUserInteractionEnabled = true
        self.view.endEditing(true)
    }
    
    @IBAction func deleteButton() {
        Api.removeAccount(wallet: w, removeAccountat: currentIndex, completion: {
            _, _ in
            
            //go back to the walletview after deleting an account
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let walletViewController = storyboard.instantiateViewController(withIdentifier: "walletViewController")
            let viewControllers = [walletViewController]
            self.navigationController?.setViewControllers(viewControllers, animated: true)
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        })
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
        
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {

        //number of rows for picker
        return w.accounts.count - 1
    }
        
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        //data to present in picker
        return accountsToTransfer[row].name + "          " + String(format: "%.2f", accountsToTransfer[row].amount)
        }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        //have the index of the currently selected index for transfer
        pickedAccountIndex = row
    }
    
    @IBAction func startedEditing(_ sender: Any) {
        self.tapGestureRecognizer.isEnabled = true
    }
    
    @IBAction func tap(_ sender: Any) {
        self.view.endEditing(true)
        self.popUpView.endEditing(true)
        self.tapGestureRecognizer.isEnabled = false
    }
}
