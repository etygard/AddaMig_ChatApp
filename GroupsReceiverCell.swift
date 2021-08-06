//
//  GroupsReceiverCell.swift
//  AddaMig_ChatApp
//
//  Created by Emma tygard on 2021-08-05.
//

import UIKit

class GroupsReceiverCell: UITableViewCell {

    @IBOutlet weak var receiverView: UIView!
    
    @IBOutlet weak var receiverMessage: UILabel!
    
    @IBOutlet weak var receiverDate: UILabel!
    @IBOutlet weak var receiverName: UILabel!
    
    
    //bubble shape view:
    override func layoutSubviews() {
        super.layoutSubviews()
        receiverView.layer.cornerRadius = 20
    }
}

