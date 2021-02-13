# [The Big Bang Theory]!
## Eden Avivi: 917278048, Ma Eint Poe: 915140330, 

# WalletViewController additions with Hw4

**Outlet declaration** Added custom popup UI View for creating a new account in the wallet, with a textfield and an error label. Added outlets for background actions to be disbled when the pop up appears and added a UITapGestureRecognizer for the keyboard to be dismissed when the pop up appears.

**viewDidLoad()** Added initialization for where the view will appear, setting it up so that on different devices, it will always appear at the center of the screen. Also initialized the elements of the popup and set it to be hidden until needed.

**textFieldShouldReturn(_ textField: UITextField)** Added that the textfield in the popup will apply to this delegate and if it is specifically that textfield, just dismiss the keyboard so that the user can press done (it hides that button).

**startedEditing(_ sender: Any)** Function enabling the tap gesture recognizer when user starts editing the sender of this function.

**addButton()** Added button, so that when the user presses on it, it creates the popup (changing its aesthetics) and disables all background interaction until the user is done interacting with the pop up. Then, to set the placeholder for the default account name, the account names are entered into an array, which checks if the default name already exists and if it is, while it exists, add to the index until the name does not exist. Then, it is set to be the default name of "Account n+1" or "Account lastNumberInThe TableView +1".

**xButtonPopUp()** Button on the pop up that lets the user exit the pop up without adding an account, this is added as a functionality of a regular pop up, since it could be pressed by accident by the user. This function hides the pop up and brings back user interaction to the background elements of the view controller and also dismisses the keyboard.

**doneButtonPopUp()** Button on the pop up that lets the user intialize an account name which is typed into the text field or to just press it empty, in which case an account with the default name will be created. It also clears the text field, reload the tableview to contain this account and returns user interaction to background elements while hidding the pop up.

**tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)** Function from the table view protocol in which there is access to the currently selected cell. If a user selects a cell, AccountViewController is presented, while the cell passed to that view controller is the one selected by the user, having it customizable to what the user selects.

**tap(_ sender: Any)** When the user taps on the sender of this function, the keyboard is dismissed and tap gesture recognizer is disabled.

# AccountViewController

**Outlet declaration** Outlets created for labels to present on the screen, intializing the picker custom pop up. Also outlets created to disable buttons when the custom pop up appears and a tap gesture for dismissing the keyboard.
*Also added variables to be intialized by previous view controller, index of current selected UIPicker element by user and array for UIPicker, to be accessed across all of the functions*

**viewDidLoad()** The labels are initialized by the specific current account selected, the pop up is set like the previous view controller and initialize array for the transfer picker, which does not include the current account in it.

**doneButton()** If the user decides to go back into the WalletViewController, the done button does so.

**depositButton()** Using a UIAlertController, the user is presented with an option to enter amount to deposit into the account out of nowhere and dismissing the keyboard using the text field and enter button or when pressing the cancel button, the alert is dismissed and so is the keyboard. The type of keyboard for the textfield is intialized to be of decimal pad type.

**withdrawButton()** Using a UIAlertController, the user is presented with an option to enter amount to withdraw from the account and dismissing the keyboard using the text field and enter button. When the user tries to withdraw more than the account has, the application withdraws the total amount in the account, as to not create a negative balance. When pressing the cancel button, the alert is dismissed and so is the keyboard. The type of keyboard for the textfield is intialized to be of decimal pad type.

**transferButton()** When pressing the transfer button, the pop up is initialized and displayed. The interaction with the background elements is disabled, as with the previous custom pop up.

**popUpDone()** Take the amount indicatded in the textfield by the user and check if the account can trasnfer that amount, if not, present an error on the error label. If the account can transfer, hide the pop up and enable interaction with background elements. Then since the index of the array of the picker is always off by one, fix the offset and transfer from the current account into the one picked in the UIPicker, update the label on the AcountViewController, reload the UIPicker, dismiss keyboard and reset the textfield.

**popUpX()** If the user decides to not transfer money, the x button on the pop up enables the interaction with background elements and hides the pop up while dismissing the keyboard.

**deleteButton()** If the user presses the delete button, the account is removed from the wallet and the user is immediately moved back into WalletViewController.

**numberOfComponents(in pickerView: UIPickerView)** Returns the number of components needed for the UIPicker, in this case, one is needed.

**pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int)** Returns the number of rows for the component, in this case, it is the number of accounts, not including the current one.

**pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int)** Presents the names of the accounts and their amount separated by some space (without the current account).

**pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)** Returns the index that the user selects, to keep track of which account the user wants to transfer money into.

**startedEditing(_ sender: Any)** Function, like the previous one in WalletViewController, enabling the tap gesture recognizer when user starts editing the sender of this function.

**tap(_ sender: Any)** When the user taps on the sender of this function, like the previous one in WalletViewController, the keyboard is dismissed and tap gesture recognizer is disabled.
