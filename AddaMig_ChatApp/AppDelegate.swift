//
//  AppDelegate.swift
//  AddaMig_ChatApp
//
//  Created by Emma tygard on 2021-08-05.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseSignIn


//testar att cleana projectet


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate{

    var enteredEmail = ""
     var enteredPassword = ""
      
     var showError = false
    var isLoggedin = false
      var doThis = {}

      //fire base:
      var mRef:DatabaseReference!
      
      
      //vars:
      var userID:String?
      var requestData:[String:String] = [String:String]()
      var currentDate:[String:String] = [String:String]()

      var window: UIWindow?


      func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
          
          FirebaseApp.configure()
          GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
          GIDSignIn.sharedInstance().delegate = self
        
          mRef = Database.database().reference()
          userID = Auth.auth().currentUser!.uid
         saveUserLastLogin()
        
          return true
      }
      
      //saves the user last login to the database:
      func saveUserLastLogin(){
          
          currentDate = ["lastLogin" : Utilities.init().getDate()]
          mRef.child("users").child(userID!).updateChildValues(currentDate)
          
                          let firebaseAuth = Auth.auth()
                      do {
                        try firebaseAuth.signOut()
                      } catch let signOutError as NSError {
                        print ("ERROR", signOutError)
                      }
                          doThis()
                          print("Du är nu utloggad")
                          isLoggedin = false
                      }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {

        
        
      
        
        if let error = error {
            
            return
        }
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        /*Auth.auth().signIn(with: credential) { (authResult, error) in
            
            if let error = error {
                // ...
                return
            }
           
            
        }*/
        
            Auth.auth().signIn(withEmail: enteredEmail, password: enteredPassword, completion: { loginresult, loginerror in
                if(loginerror == nil)
                {
                    self.isLoggedin = true
                } else {
                    self.showError = true
                }
            })
            
                }
        
        func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
          
        }
        
        @available(iOS 9.0, *)
        func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any])
            -> Bool {
                return GIDSignIn.sharedInstance().handle(url,
                                                         sourceApplication:options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                                                         annotation: [:])
        }
        
        
        
        
        func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
            return GIDSignIn.sharedInstance().handle(url,
                                                     sourceApplication: sourceApplication,
                                                     annotation: annotation)
        }
        
        
        

        }
        


