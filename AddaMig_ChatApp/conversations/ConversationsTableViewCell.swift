//
//  ConversationsTableViewCell.swift
//  AddaMig_ChatApp
//
//  Created by Emma tygard on 2021-08-05.
//

import UIKit

class ConversationsTableViewCell: UITableViewCell {

    @IBOutlet weak var contactDate: UILabel!
    
    @IBOutlet weak var contactProfileImg: UIImageView!
    @IBOutlet weak var contactName: UILabel!
    
    @IBOutlet weak var contactStatus: UILabel!
    
    
    
    override func awakeFromNib() {
        contactProfileImg.layer.cornerRadius = contactProfileImg.frame.height / 2
    }
}

