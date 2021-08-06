//
//  MessageCell.swift
//  AddaMig_ChatApp
//
//  Created by Emma tygard on 2021-08-05.
//

import UIKit

class MessageCell: UITableViewCell {

 
    @IBOutlet weak var receiverView: UIView!
    
    @IBOutlet weak var message: UILabel!
    
    
    
    @IBOutlet weak var date: UILabel!
    
 
    

    //bubble shape view:
    override func layoutSubviews() {
        super.layoutSubviews()
        receiverView.layer.cornerRadius = 20
    }
    
    
}

