//
//  FindContactsTableViewController.swift
//  AddaMig_ChatApp
//
//  Created by Emma tygard on 2021-08-05.
//

import UIKit
import Firebase

class FindContactsTableViewController: UITableViewController{
    
    //properties:
    
    //firebase:
    var mRef:DatabaseReference!
    
    //vars:
    var userID:String?
    var data:[DataSnapshot] = [DataSnapshot]()
    var allUserIDs:[String] = [String]()
    var requestData:[String:String] = [String:String]()
    var friendsList:[String] = [String]()
    
    
    //ctor:
    override func viewDidLoad() {
        
        
        
        userID = Auth.auth().currentUser!.uid
        mRef = Database.database().reference()
        initFireBase()
        
    }
    
    
    
    //sends the user to main VC <- back button
    @IBAction func backToMainVCBtn(_ sender: Any) {
        //Utils helper func to send the user to another storyboard:
        Utilities.init().sendToAnotherVC(vc: self, storyboard: self.storyboard!, identifier: "navigationController")
        
        
    }
    
    
    //event listner to the firebase - > if there is a new entry -> add all the entrys into the dataSnapshot array -> 'data'
    // aterwards insert the values into the tableView:
    //adds the users IDS into an array to be used later to write the users requests to the database
    func initFireBase(){
        
     
        
        mRef.child("users").observe(DataEventType.value, with: { (dataSnapShot) in
      //loop of the children of the users -> id > data
            for snap in dataSnapShot.children {

                let userSnap = snap as! DataSnapshot
                
                //users ID array:
                let uid = userSnap.key //the uid of each user
                
                if uid != self.userID{
                self.allUserIDs.append(uid)
               
                self.mRef.child("users").child(uid).observe(DataEventType.value, with: { (snapShot) in
                    
                    
                    //insert the user data into data array and send it to the tableView:
                    self.data.append(snapShot)
                    self.tableView.insertRows(at: [IndexPath(row: self.data.count - 1 , section: 0)], with: .automatic)
                        
                    
                    
                })
                }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "findContactsTableViewCell", for: indexPath) as! FindContactCell
        
       
        //the firebase data by index:
        let user = data[indexPath.row]

        //the data as a key,Value
        let userDetails = user.value as! Dictionary<String, String>

        //insert the data to the views in the tableViewCell:
     let profilePic = userDetails[Constants.usersFields.userProfilePic] ?? ""
        let nickName = userDetails[Constants.usersFields.nickName] ?? ""
        let status = userDetails[Constants.usersFields.status] ?? ""

        cell.contactName.text = nickName ?? ""
        cell.contactStatus.text = status ?? ""

        
        //insert the profile pic of the user into the selected view:
        if let url = URL(string: profilePic){

            do {
                let data = try Data(contentsOf: url)
               cell.contactProfileImg.image = UIImage(data: data)

            }catch let err {
                print(" Error : \(err.localizedDescription)")
            }

           
      

        }

       
        
        //adds functionality to the cell button:
        cell.add.tag = indexPath.row
        cell.add.addTarget(self, action: #selector(buttonSelected), for: .touchUpInside)
            
      
        
        
        return cell
    }
 
    //cell button functionality:
    //sender.tag.self -> button index:
    //extract the right index from the IDS array
    //write the requested entries to the database
    //write to the sending user and accepting user logs of the request:
    @objc func buttonSelected(sender: UIButton, path:Int){
        
        var index:Int = sender.tag.self
        
        var sent:[String:String] = ["request_type":"sent"]
        var receive:[String:String] = ["request_type":"received"]
        
        //write sent entry to the current user id -> added user -> sent
        self.mRef.child("chat_requests").child(self.userID!).child(allUserIDs[index]).updateChildValues(sent)
        //writes receive entry to the added user - > current user id -> received
        self.mRef.child("chat_requests").child(allUserIDs[index]).child(self.userID!).updateChildValues(receive)
        
    }
    
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

