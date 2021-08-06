//
//  ContactsCell.swift
//  AddaMig_ChatApp
//
//  Created by Emma tygard on 2021-08-05.
//

import UIKit

class ContactsCell: UITableViewCell {


    @IBOutlet weak var contactRemoveBtn: UIButton!
    @IBOutlet weak var contactName: UILabel!
    @IBOutlet weak var contactProfileImg: UIImageView!
    
    @IBOutlet weak var contactStatus: UILabel!
    
    override func awakeFromNib() {
        contactProfileImg.layer.cornerRadius = contactProfileImg.frame.height / 2
    }
}

