//
//  PostService.swift
//  AddaMig_ChatApp
//
//  Created by Emma tygard on 2021-08-05.
//

import Foundation


import UIKit
import FirebaseStorage
import FirebaseDatabase

struct PostService {
    
    
    static func create(for image: UIImage) {
        let imageRef = Storage.storage().reference().child("test_image.jpg")
        StorageService.uploadImage(image, at: imageRef) { (downloadURL) in
            guard let downloadURL = downloadURL else {
                return
            }
            
            let urlString = downloadURL.absoluteString
            print("image url: \(urlString)")
        }
    }
    
    
    
    
}

