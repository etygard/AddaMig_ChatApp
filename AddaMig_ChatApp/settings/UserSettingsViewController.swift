//
//  UserSettingsViewController.swift
//  AddaMig_ChatApp
//
//  Created by Emma tygard on 2021-08-05.
//

import Foundation
import UIKit
import Firebase
import FirebaseStorage


class UserSettingsViewController: UIViewController {
    
    //properties:

    
    //vars:
    var data:[String:String] = [String:String]()
    var imagePicker = UIImagePickerController()
    
    //firebase:
    var ref:DatabaseReference!
    var fAuth = Auth.auth()
    
    var userID:String?
    var picName:String?
    var imgChose:Bool?
    
    
    //outlets:
    @IBOutlet weak var nickNameTF: UITextField!
    @IBOutlet weak var statusTF: UITextField!
    @IBOutlet weak var profilePicIV: UIImageView!
    
    
    //ctor:
    override func viewDidLoad() {
        imgChose = false
        //img interaction as an action:
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped(gesture:)))
        profilePicIV.addGestureRecognizer(tapGesture)
        profilePicIV.isUserInteractionEnabled = true
   
        //init current user ID string:
        userID = Auth.auth().currentUser?.uid
        ref = Database.database().reference()
        
        
        //delegates:
        nickNameTF.delegate = self
        statusTF.delegate = self
        imagePicker.delegate = self
        
        picName = self.fAuth.currentUser?.displayName?.lowercased()
        picName = picName?.removeWhitespace()
        
        //init the textfields so they will show the last saved data:
        initFields()
        
        
        profilePicIV.layer.cornerRadius = profilePicIV.frame.height / 2
       
    }
    
    //add an tap gesture Recognizer to the imageView:
    @objc func imageTapped(gesture: UIGestureRecognizer) {
        // if the tapped view is a UIImageView then set it to imageview
        if (gesture.view as? UIImageView) != nil {
            
            //get a pic from the phone library:
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true) {
                self.imgChose = true
            }

        }
        
    }

    
    
    //saves the data into the database:
    //save the profile pic, nickname and status:
    @IBAction func saveSettingsBtn(_ sender: UIButton) {
        
        //if textfields are empety -> alert dialog - error
        //else -> save data into the database:
        if statusTF.text!.isEmpty || nickNameTF.text!.isEmpty {
            
            Utilities.init().showAlert(title: "Error", message: "Please enter your nick name and status and try again", vc: self)
            
            
        }else{
        
        // helper func: send user to main VC:
        Utilities.init().toMainVC(vc: self, storyboard: self.storyboard!, identifier: "navigationController")
            
          //name of the pic that will be save in the data base
            //taken from the user displayname
            var picName = self.fAuth.currentUser?.displayName?.lowercased() ?? "noDisplayName"
            picName = picName.removeWhitespace()
            
            if imgChose == true {
            uploadImage(self.profilePicIV.image!) { (url) in
            
                var picData:[String:String] = [String:String]()
                picData["user_profile_pic"] = url?.absoluteString
                
                //profile pic into the database:
                self.ref.child("users").child(self.userID!).updateChildValues(picData)
                
            }
            }
            //status and nickname dictionary into the database:
            self.data["status"] = self.statusTF.text
            self.data["nickName"] = self.nickNameTF.text
            
            self.ref.child("users").child(self.userID!).updateChildValues(self.data)
          
        }

        
    }
    
    
    //init the textfields so they will show the last saved data:
    func initFields(){
        //single event observer to retrive the user details:
        ref.child("users").child(userID!).observeSingleEvent(of: .value) { (dataSnapshot) in
            
           let value = dataSnapshot.value as? NSDictionary
    
            self.statusTF.text = value?.value(forKey: "status") as? String
            self.nickNameTF.text = value?.value(forKey: "nickName") as? String
            
            if dataSnapshot.hasChild("user_profile_pic") {
            let picPath:String = (value?.value(forKey: "user_profile_pic") as? String)!
            
           
            
            if let url = URL(string: picPath){
                
                do {
                    let data = try Data(contentsOf: url)
                    self.profilePicIV.image = UIImage(data: data)
                    
                }catch let err {
                    print(" Error : \(err.localizedDescription)")
                }
                
                
            }
            
            }
        }
    


}
    
  
    
    
}

//keyboard return enable
extension UserSettingsViewController: UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.endEditing(true)
        
        return true
    }
    
    //phone library pic -> to the imageView
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
       
            
            
            //compress the image size:
            if let imageData = image.jpeg(.lowest) {
                
                let newImage : UIImage = UIImage(data: imageData)!
                
               profilePicIV.image = newImage
              
            }
            
            
            
        
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    //uploads image into the storage database:
    func uploadImage(_ image:UIImage , completion: @escaping (_ url: URL?) -> ()){
        //firebase storage ref:
        let storageRef = Storage.storage().reference().child("images").child(picName ?? self.userID!)
        let imgData = profilePicIV.image?.pngData()
        
        let metaData = StorageMetadata()
        metaData.contentType = "image"
        storageRef.putData(imgData!, metadata: metaData) { (metadata, err) in
            storageRef.downloadURL(completion: { (url, error) in
                completion(url!)
            })
        }
        
    }
    

    
}


// string extention to remove whitespace of a given string:
extension String {
    func replace(string:String, replacement:String) -> String {
        return self.replacingOccurrences(of: string, with: replacement, options: NSString.CompareOptions.literal, range: nil)
    }
    
    func removeWhitespace() -> String {
        return self.replace(string: " ", replacement: "_")
    }
}

/// Returns the data for the specified image in JPEG format.
/// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
/// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    extension UIImage {
        enum JPEGQuality: CGFloat {
            case lowest  = 0
            case low     = 0.25
            case medium  = 0.5
            case high    = 0.75
            case highest = 1
        }
        
        /// Returns the data for the specified image in JPEG format.
        /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
        /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
        func jpeg(_ jpegQuality: JPEGQuality) -> Data? {
            return jpegData(compressionQuality: jpegQuality.rawValue)
        }
    }


