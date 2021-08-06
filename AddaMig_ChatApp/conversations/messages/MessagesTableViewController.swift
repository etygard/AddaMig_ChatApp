//
//  MessagesTableViewController.swift
//  AddaMig_ChatApp
//
//  Created by Emma tygard on 2021-08-05.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseDatabase


class MessagesTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    //properties:
    
    //outlets:
    
    @IBOutlet weak var chatboxTF: UITextField!
    
    //chatBox View outlets:
    @IBOutlet weak var chatBoxViewToFatherView: NSLayoutConstraint!
    @IBOutlet weak var chatBoxViewToSageArea: NSLayoutConstraint!
    @IBOutlet weak var chatBoxView: UIView!
    
    
    //outlests:
    @IBOutlet weak var tableView: UITableView!
    
    //vars:
    var reciverUserID:String = String()
    var messages: [DataSnapshot] = [DataSnapshot] ()
    
    
    //firebase init:
    var ref:DatabaseReference!
    var refHandler:DatabaseHandle!
    var userID:String?
    
    //ctor:
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //retrive the user id which the user want to have conversation with
        // uses userDefaults to pass data between ConversationsTVC to MessagesTVC
         reciverUserID = UserDefaults.standard.string(forKey: "uID") ?? ""
        
        //user ID retract from database
        userID = Auth.auth().currentUser?.uid
        
        //sets the tableView data from the database into the app:
       
        
        //database reference:
        ref = Database.database().reference()
        
        
        checkCurrentUser()
        setupFireBase()

        
        //delegate listeners:
        chatboxTF.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        chatboxTF.delegate = self
        
        
         chatBoxView.layer.cornerRadius = 20
        
    }
    
    
    

    
    
    
    
    //event listner to the firebase - > if there is a new entry -> add all the entrys into the dictionary -> 'messages'
    // aterwards insert the values into the tableView:
    func setupFireBase() {
        //user id from the database:
        // ref to the database:
        ref = Database.database().reference()
        //added message listner - > if added to FB will be added to the tableView
        var refHandle = ref.child("messages").child(userID!).child(reciverUserID).observe(DataEventType.childAdded, with:  { (dataSnapshot) in
            self.messages.append(dataSnapshot)
            self.tableView.insertRows(at: [IndexPath(row: self.messages.count - 1 , section: 0)], with: .automatic)
            
            
            //reload the tableView to the last row:
            self.refreshToLastCell()
            
            
        })
        
        
    }
    
   
    
    
    //remove the observer from the firebase when the VC is off
    deinit {
        
        ref.child("messages").child(userID!).child(reciverUserID).removeObserver(withHandle: refHandler)
    }
    
    //send message button:
    @IBAction func messageSendBtn(_ sender: UIButton) {
        
        //saves the date and msg to the database via dictionary:
        saveMessageToDataBase()
        //clears the chatbox textfield:
        chatboxTF.text = ""
        //reload the tableView to the last row:
        refreshToLastCell()
    }
    
    //saves data to the database:
    //dictionary that holds two entrys:
    //1) text msg
    //2) date of message
    //afterwards insert them into the user messages entry  inside the user table
    //prevent emprty messages
    func saveMessageToDataBase () {
        
        //prevent emprty messages:
        if chatboxTF.text!.count > 0 {
            //Dictionary:
            var data = [String: String]()
            //dictionary that holds two entrys:
            //1) text msg
            //2) date of message
            //afterwards insert them into the user messages entry  inside the user table:
            data[Constants.MessageFields.text] = chatboxTF.text
            data[Constants.MessageFields.dateTime] = Utilities.init().getDate()
            data["from"] = userID
            ref.child("messages").child(userID!).child(reciverUserID).childByAutoId().setValue(data)
            ref.child("messages").child(reciverUserID).child(userID!).childByAutoId().setValue(data)
        }
    }
    
    
    //checks if a user is logged in -> if so continue to main VC
    //else -> send user to login VC
    func checkCurrentUser () {
        
        if(Auth.auth().currentUser  == nil){
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "authViewController") {
                self.navigationController?.present(vc, animated: true, completion: nil)
                
            }
        }
        
    }
    
    
    //returns the number of the sections in the messages tableview
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //returns the number of rows in the message table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    
    //cell setup ->
    //connecting the id of the cell to the cell func
    // extracting the message from the messages[DataSnapshot] var which is located in the firebase
    // casting the message content of the message into a dictionary, String,String
    // extracting the message contect from the MessageContent var into a new var as String casted.
    //modify the cell text label to accep the text
    //returns the cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "senderCell")! as! SenderCell
        
        let receiverCell = tableView.dequeueReusableCell(withIdentifier: "receiverMessageCell")! as! MessageCell
        
       
   
        let message = messages[indexPath.row]
        
        let msgContent = message.value as! Dictionary<String, String>
        
        let text = msgContent[Constants.MessageFields.text]
        let date = msgContent[Constants.MessageFields.dateTime]
        
        
        
       if msgContent["from"] == userID{
        
        cell.senderMessage.text = text
        cell.senderDate.text = date
        
       print()
        
        
        return cell
          }
        
        receiverCell.message.text = text
        receiverCell.date.text = date
        
        return receiverCell
    }
    
    
    
    //log out the user of the app
    //if it trows an error the catch phrase will 'catch' that error
    func logout() {
        
        let fAuth =  Auth.auth()
        
        do{
            try fAuth.signOut()
        }catch let signOutError as NSError{
            
            print("error siging out " + signOutError.localizedDescription)
        }
        
        
    }
    
    //reload the tableView to the last row:
    func refreshToLastCell() {
        
        //reload the tableView to the last row:
        tableView.reloadData()
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: self.messages.count - 1 , section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
        }
        
    }
    
    
    //keyboard up/down listener:
    override func awakeFromNib() {
        
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardLayoutConstraint.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardLayoutConstraint.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    
    //keyboard up:
    @objc func keyboardWillShow (_ notification: Notification) {
        
        //changing the priority to eliminate the keyboard bug in the new phones
        //layout will strech above the keyboard when is up
        //so changing the priority of one of the two constraints (one to safe are and other to
        //the father view itself
        //so when the keyboard is up the priority will shift from the safe area to the father view constraint.
        chatBoxViewToSageArea.priority = UILayoutPriority(rawValue: 500)
        
    }
    
    //keyboard down:
    @objc func keyboardWillHide(_ notification:Notification){
        
        
        //changing the priority to eliminate the keyboard bug in the new phones
        //layout will strech above the keyboard when is up
        //so changing the priority of one of the two constraints (one to safe are and other to
        //the father view itself
        //so when the keyboard is up the priority will shift from the safe area to the father view constraint.
        chatBoxViewToSageArea.priority = UILayoutPriority(rawValue: 900)
    }
    
  
    
    
}



extension MessagesTableViewController: UITextViewDelegate{
    
    
    
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        //saves the date and msg to the database via dictionary:
        saveMessageToDataBase()
        //clears the chatbox textfield:
        chatboxTF.text = ""
        //reload the tableView to the last row:
        refreshToLastCell()
        textField.endEditing(true)
        return true
        
        
    }
    
    
}

