//
//  ConversationsTableViewController.swift
//  AddaMig_ChatApp
//
//  Created by Emma tygard on 2021-08-05.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class ConversationsTableViewController: UITableViewController {


    //properties:

    //fire base:
    var mRef:DatabaseReference!
    
    //vars:
    var userID:String?
    var data:[DataSnapshot] = [DataSnapshot]()
    var searchDataFilter:[DataSnapshot] = [DataSnapshot]()
    
    var allUserIDs:[String] = [String]()
    var allUserIDsFilter:[String] = [String]()
    
    var requestData:[String:String] = [String:String]()
    var currentDate:[String:String] = [String:String]()

 
    
    
    
    //ctor:
    override func viewDidLoad() {
        
        //release data from vars on init:
       clearReloadData()
        
        //current user ID:
        userID = Auth.auth().currentUser!.uid
        
        //firebase database REFerence
        mRef = Database.database().reference()
        
        //load all the data from the firebase to the TVC
        initFireBase()
        //check if current user exists in the database(precaution measurement)
        checkCurrentUser()
        
       
        
        
        
    }
    
    
    
    //searchTF -> search in the tableView -> search in the database:
    @IBAction func searchBarTF(_ sender: UITextField) {
        
    
        
        let tfText = sender.text
        
        for dat in searchDataFilter {
            
            let name = dat.childSnapshot(forPath: "nickName").value as! String
      let aUserID = dat.childSnapshot(forPath: "ID").value as! String
          

            if (name.contains(tfText!)) {
                
                print(name)
                data.removeAll()
                data.append(dat)
                allUserIDs.removeAll()
                allUserIDs.append(aUserID)
                self.tableView.reloadData()

            }
            
        if tfText!.isEmpty {
                
                data = searchDataFilter
                allUserIDs = allUserIDsFilter
                self.tableView.reloadData()
                
            }
      
            
        }
        
    }
    
    
    
    
    
    @IBAction func searchBtn(_ sender: UIBarButtonItem) {
        
    }
    
   

   
    
  
    
    //event listner to the firebase - > if there is a new entry -> add all the entrys into the dataSnapshot array -> 'data'
    // aterwards insert the values into the tableView:
    //adds the users IDS into an array to be used later to write the users requests to the database
    func initFireBase(){
       
        
        clearReloadData()
 
        mRef.child("users").observe(DataEventType.value, with: { (dataSnapShot) in
            //loop of the children of the users -> id > data
            for snap in dataSnapShot.children {
                
                let userSnap = snap as! DataSnapshot
                
                //users ID array:
                let uid = userSnap.key //the uid of each user
                
                
                
                
                self.mRef.child("contacts").child(self.userID!).child(uid).observe(DataEventType.value, with: { (dataSnapShot) in
                    
                    
                    for snap in dataSnapShot.children {
                        
                        let userSnap = snap as! DataSnapshot
                        
                        
                        let value = userSnap.value as! String
                        
                        if(value == "saved"){
                            
                            
                            if uid != self.userID{
                                self.allUserIDs.append(uid)
                                self.allUserIDsFilter.append(uid)
                                
                                self.mRef.child("users").child(uid).observe(DataEventType.value, with: { (snapShot) in
                                    
                                    
                                    //insert the user data into data array and send it to the tableView:
                                    self.data.append(snapShot)
                                    self.searchDataFilter.append(snapShot)
                                    self.tableView.insertRows(at: [IndexPath(row: self.data.count - 1 , section: 0)], with: .automatic)

                                    
                                })
                                
                            }
                        }
                    }
                    
                })
                
            }
        })
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "conversationsTableViewCell", for: indexPath) as! ConversationsTableViewCell
        
        
        
        //the firebase data by index:
        let user = data[indexPath.row]
        
        //the data as a key,Value
        let userDetails = user.value as! Dictionary<String, String>
        
        //insert the data to the views in the tableViewCell:
        let profilePic = userDetails[Constants.usersFields.userProfilePic] ?? ""
        let nickName = userDetails[Constants.usersFields.nickName] ?? ""
        let status = userDetails[Constants.usersFields.status] ?? ""
        let lastLogin = userDetails[Constants.usersFields.lastLogin] ?? ""
        
        cell.contactName.text = nickName
        cell.contactStatus.text = status
        cell.contactDate.text = lastLogin
        
        //insert the profile pic of the user into the selected view:
        if let url = URL(string: profilePic){
            
            do {
                let data = try Data(contentsOf: url)
                cell.contactProfileImg.image = UIImage(data: data)
                
            }catch let err {
                print(" Error : \(err.localizedDescription)")
            }
            
            
        }

        
        return cell
    }
    
    
    
    
    
    
    //init the menu bar buttons:
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
        UserDefaults.standard.set(allUserIDs[index], forKey: "uID") //setObject
        
        
     
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toMessagesVC"{
            print("test")
        }else{
        data.removeAll()
        tableView.reloadData()
        }
    }
    
    
    
  
    //reset all the data and reload the table view func:
    func clearReloadData () {
        // code to load data from network, and refresh the interface
        data.removeAll()
        allUserIDs.removeAll()
        tableView.reloadData()
        
    }

}

