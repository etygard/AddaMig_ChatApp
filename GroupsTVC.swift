//
//  GroupsTVC.swift
//  AddaMig_ChatApp
//
//  Created by Emma tygard on 2021-08-05.
//

import UIKit
import FirebaseStorage
import Firebase
import FirebaseDatabase

class GroupsTVC: UITableViewController {

    
    
    
    //properties:
    
    //fire base:
    var mRef:DatabaseReference!
    
    //vars:
    var userID:String?
    var groupsNames:[String] = [String]()
    var requestData:[String:String] = [String:String]()
    var currentDate:[String:String] = [String:String]()
     var data:[DataSnapshot] = [DataSnapshot]()
    
    
    
    
    //ctor:
    override func viewDidLoad() {
        
        //release data from vars on init:
       groupsNames.removeAll()
      tableView.reloadData()
        
        //current user ID:
        userID = Auth.auth().currentUser!.uid
        
        //firebase database REFerence
        mRef = Database.database().reference()
        
        //load all the data from the firebase to the TVC
        initFireBase()
        //check if current user exists in the database(precaution measurement)
        checkCurrentUser()
        
        //saves the user last login to the database:
        saveUserLastLogin()
        
        
        
    }
    
    
    
    
    
    //reset all the data and reload the table view func:
    func loadData() {
        
        // code to load data from network, and refresh the interface
        groupsNames.removeAll()
        tableView.reloadData()
    }
    
    //saves the user last login to the database:
    func saveUserLastLogin(){
        
        currentDate = ["lastLogin" : Utilities.init().getDate()]
        mRef.child("users").child(userID!).updateChildValues(currentDate)
        
    }
    
    //event listner to the firebase - > if there is a new entry -> add all the entrys into the dataSnapshot array -> 'data'
    // aterwards insert the values into the tableView:
    //adds the users IDS into an array to be used later to write the users requests to the database
    func initFireBase(){
        groupsNames.removeAll()
       tableView.reloadData()
        
        
        
    
        
        
        
        mRef.child("groupsNames").observe(DataEventType.childAdded) { (dataSnapShot) in
            
            for snap in dataSnapShot.children {
                
                
                
                let userSnap = snap as! DataSnapshot
               
                
                let name = userSnap.value as! String
                self.groupsNames.append(name)
              
            }
            
            
        self.data.append(dataSnapShot)
        
        
        self.tableView.insertRows(at: [IndexPath(row: self.data.count - 1 , section: 0)], with: .automatic)
            
            
        }
    }
    
    // MARK: - Table view data source
    
    //1
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    //data.count
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return data.count
    }
    
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "groupsCell", for: indexPath)
        
      
  
        //the firebase data by index:
        let user = data[indexPath.row]
        
        //the data as a key,Value

     
      let userDetails = user.value as! Dictionary<String, String>
     
//
//        //insert the data to the views in the tableViewCell:
     cell.textLabel!.text = user.key
      
        

        return cell
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
    
    //segue to MessagesTVC
    //retrive the user id which the user want to have conversation with
    // uses userDefaults to pass data between ConversationsTVC to MessagesTVC
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //user index on the table view
        var index = indexPath.row
        
        
        //retrive the user id which the user want to have conversation with
        // uses userDefaults to pass data between ConversationsTVC to MessagesTVC
        UserDefaults.standard.set(groupsNames[index], forKey: "groupName") //setObject
        
        
    }
    
    
    

    
    @IBAction func createNewGroup(_ sender: UIButton) {
        
        let createGroupAlert = UIAlertController(title: "Create Group", message: "Choose group name", preferredStyle: .alert)
        createGroupAlert.addTextField { (tf) in
            
            
      
            
            createGroupAlert.addAction(UIAlertAction(title: "ok", style: .default, handler: { (UIAlertAction) in
                
                if(tf.text!.isEmpty){
                    
                    
                }else{
                    
                    let groupName:[String:String] = ["groupName": tf.text ?? ""]
                   
                    self.mRef.child("groupsNames").child(tf.text!).updateChildValues(groupName)
                   
                    
                    
                }
               self.tableView.reloadData()
                
                
            }))
            
  
        }
        
        present(createGroupAlert, animated: true, completion: nil)
        
    }
    
    
    
    
    
    @IBAction func menuBarBtn(_ sender: UIBarButtonItem) {
        
        //alert text attributes:
        let messageFont = [kCTFontAttributeName: UIFont(name: "Avenir-Roman", size: 25.0)!]
        let messageAttrString = NSMutableAttributedString(string: "User Menu", attributes: messageFont as [NSAttributedString.Key : Any])
        
        //alert init:
        let topMenuAlert = UIAlertController(title: nil , message: nil, preferredStyle: .actionSheet)
        
        //appliment attribute:
        topMenuAlert.setValue(messageAttrString, forKey: "attributedMessage")
        
        
        topMenuAlert.addAction(UIAlertAction(title: "Find Contacts", style: .default, handler: { (findContactsAction) in
            
            let FindContactVC = self.storyboard?.instantiateViewController(withIdentifier: "findContactsTableView")
            self.present(FindContactVC!, animated: true, completion: nil)
            
        }))
        
        //setting btn:
        topMenuAlert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (settingAction) in
            
            
            let toSettingsVC = self.storyboard?.instantiateViewController(withIdentifier: "settingsViewController")
            self.present(toSettingsVC!, animated: true, completion: nil)
            
        }))
        // about btn:
        topMenuAlert.addAction(UIAlertAction(title: "About", style: .default, handler: { (aboutAction) in
            
        }))
        //logout btn
        topMenuAlert.addAction(UIAlertAction(title: "Log Out", style: .default, handler: { (logoutAction) in
            
            self.logout()
            self.checkCurrentUser()
            
        }))
        
        
        topMenuAlert.addAction(UIAlertAction(title: "Dismiss", style: .destructive, handler: { (logoutAction) in
            
            
        }))
        
        self.present(topMenuAlert, animated: true) {
            
        }
        
    }
    
    
   
}

