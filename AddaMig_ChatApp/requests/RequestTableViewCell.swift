//
//  RequestTableViewCell.swift
//  AddaMig_ChatApp
//
//  Created by Emma tygard on 2021-08-05.
//

import UIKit

class RequestTableViewCell: UITableViewCell {
    //properties:
    
    //outlets:
    @IBOutlet weak var contactName: UILabel!
    @IBOutlet weak var contactStatus: UILabel!
    @IBOutlet weak var contactProfileImg: UIImageView!
    @IBOutlet weak var acceptBtn: UIButton!
    @IBOutlet weak var rejectBtn: UIButton!
    
    override func awakeFromNib() {
        contactProfileImg.layer.cornerRadius = contactProfileImg.frame.height / 2
    }
   
}

