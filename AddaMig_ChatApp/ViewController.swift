//
//  ViewController.swift
//  AddaMig_ChatApp
//
//  Created by Emma tygard on 2021-08-05.
//

import UIKit
import Firebase
import FirebaseDatabase

class ViewController: UIViewController {
    var ref: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        

        ref = Database.database().reference()
        
        self.ref.child("users").setValue(["username": "Torsten"])
        
        
        
        let userID = Auth.auth().currentUser?.uid
        ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { snapshot in
          // Get user value
          let value = snapshot.value as? NSDictionary
          let username = value?["username"] as? String ?? ""
          let user = User(username: username)

          // ...
        }) { error in
          print(error.localizedDescription)
        }
    }


}

