//
//  WalletViewController.swift
//  Hw3
//
//  Created by Eden Avivi on 2/4/21.
//

import UIKit
var w = Wallet()

class WalletViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    var accountNames: [String] = []
    
    @IBOutlet weak var userNameLabel: UITextField!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
   
    @IBOutlet weak var createView: UIView!
    @IBOutlet weak var popUpTextField: UITextField!
    @IBOutlet weak var popUpErrLabel: UILabel!
    
    
    @IBOutlet weak var logOutButtonOutlet: UIButton!
    @IBOutlet weak var addButtonOutlet: UIButton!
    
    @IBOutlet var tapGestureRecognizer: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set delegates
        userNameLabel.delegate = self
        tableView.dataSource = self
        self.tableView.delegate = self
        
        
        //set pop up initialization
        createView.center = CGPoint(x: self.view.center.x, y: self.view.center.y)
        createView.sizeToFit()
        createView.isHidden = true
        popUpTextField.delegate = self
        popUpErrLabel.text = nil
        self.tapGestureRecognizer.isEnabled = false
        
        if Storage.authToken != nil {
            Api.user(completion: { response, error in
                w = Wallet.init(data: response ?? ["": (Any).self] , ifGenerateAccounts: false)
                Api.setAccounts(accounts: w.accounts, completion: { response, error in
                })
                let phoneNumber = Storage.phoneNumberInE164 ?? ""
                let userNameString = w.userName ?? ""
                if userNameString == "" {
                    //if there is no username, show phone number
                    self.userNameLabel.text = "\(phoneNumber)"
                } else {
                    //present the user name
                    self.userNameLabel.text = "\(userNameString)"
                }
                // totalAmount is calculated
                self.totalAmountLabel.text = "Your Total Amount is $\(String(format: "%.2f", w.totalAmount))"
                
                //keep updating
                self.tableView.reloadData()
            })
        }
    }
    
  
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == popUpTextField {
            
            //if pressing return on popup, just disable keyboard, only done saves name
            self.view.endEditing(true)
            return false
        }
        
        //if the user presses return, the username is set in response
        Api.setName(name: userNameLabel.text ?? "", completion: { response, error in
        })
        
        // if deleted everything and pressed return, show the phonenumber
        if userNameLabel.text == "" {
            userNameLabel.text = Storage.phoneNumberInE164
        }
        
        //dismiss keyboard on return
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func startedEditing(_ sender: Any) {
        self.tapGestureRecognizer.isEnabled = true
    }
    
    @IBAction func logOutButton() {
        
        //go to starting page when trying to log out
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "viewController")
        let viewControllers = [viewController]
        self.navigationController?.setViewControllers(viewControllers, animated: true)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @IBAction func addButton() {
        
        //add the custom popup
        createView.isHidden = false
        createView.layer.shadowColor = UIColor.black.cgColor
        createView.layer.shadowOpacity = 0.3
        createView.layer.shadowOffset = .zero
        createView.layer.shadowRadius = 10
        createView.backgroundColor = UIColor.white
        createView.layer.cornerRadius = 25
        
        //disable background interaction until done
        tableView.isUserInteractionEnabled = false
        userNameLabel.isUserInteractionEnabled = false
        addButtonOutlet.isUserInteractionEnabled = false
        logOutButtonOutlet.isUserInteractionEnabled = false
        
        //set the placeholder
        var total = w.accounts.count
        //have error checking for duplicate names
        if w.accounts.count != 0 {
            for index in 0...total - 1 {
                self.accountNames.append(w.accounts[index].name)
            }
        }
        
        while self.accountNames.contains("Account \(total + 1)") {
            total += 1
        }
        self.popUpTextField.placeholder = "Account \(total + 1)"
    }
    
    @IBAction func xButtonPopUp() {
        //hide view
        createView.isHidden = true
        
        //enable background interaction when done
        tableView.isUserInteractionEnabled = true
        userNameLabel.isUserInteractionEnabled = true
        addButtonOutlet.isUserInteractionEnabled = true
        logOutButtonOutlet.isUserInteractionEnabled = true
        
        //disable keyboard
        self.popUpTextField.endEditing(true)
        
        //clear error if exists
        self.popUpErrLabel.text = nil
        
        //clear textfield
        self.popUpTextField.text = nil
    }
    
    @IBAction func doneButtonPopUp() {
    
        //enable background interaction when done
        tableView.isUserInteractionEnabled = true
        userNameLabel.isUserInteractionEnabled = true
        addButtonOutlet.isUserInteractionEnabled = true
        logOutButtonOutlet.isUserInteractionEnabled = true
        
        //set name
        var accountName = popUpTextField.text ?? ""
       
        //no duplicate names
        if accountNames.contains(accountName) {
            popUpErrLabel.text = "No duplicate names"
            popUpErrLabel.textColor = .red
        } else {
            
            //hide the popup
            createView.isHidden = true
            
            if accountName == "" {
                //default account name
                accountName = popUpTextField.placeholder ?? ""
            }
            
            //add a new account
            Api.addNewAccount(wallet: w, newAccountName: accountName, completion: { _, _ in
            })
            
            //add the account to the wallet
            Api.setAccounts(accounts: w.accounts, completion: { response, error in
                //reload the data and have the pop up be correct
                self.tableView.reloadData()
            })
        
            //stop editing if creating done
            self.popUpTextField.endEditing(true)
            self.popUpTextField.text = nil
            self.popUpErrLabel.text = nil
        
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //transfer to each account's viewcontroller when selecting it
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let accountViewController = storyboard.instantiateViewController(withIdentifier: "accountViewController")
        let viewControllers = [accountViewController]
        
        self.navigationController?.setViewControllers(viewControllers, animated: true)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        let newAccountView = accountViewController as? AccountViewController
        
        //initialize the cell to be in the next viewcontroller
        newAccountView?.currentCell = w.accounts[indexPath.row]
        newAccountView?.currentIndex = indexPath.row
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        assert(section == 0)
        
        //return the number of accounts to be printed
        return w.accounts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell(style: .value1, reuseIdentifier: "Cell")
            //for each account print name                     amount
            cell.textLabel?.text = w.accounts[indexPath.row].name
            cell.detailTextLabel?.text = String(format: "%.2f", w.accounts[indexPath.row].amount)
                return cell
    }

    @IBAction func tap(_ sender: Any) {
        self.view.endEditing(true)
        self.createView.endEditing(true)
        self.tapGestureRecognizer.isEnabled = false
        
    }
}
