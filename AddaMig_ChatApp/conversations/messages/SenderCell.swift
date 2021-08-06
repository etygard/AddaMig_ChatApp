//
//  SenderCell.swift
//  AddaMig_ChatApp
//
//  Created by Emma tygard on 2021-08-05.
//

import UIKit

class SenderCell: UITableViewCell {

    @IBOutlet weak var senderView: UIView!
    @IBOutlet weak var senderMessage: UILabel!
    
    @IBOutlet weak var senderDate: UILabel!
    
    //bubble shape view:
    override func layoutSubviews() {
        super.layoutSubviews()
        senderView.layer.cornerRadius = 20
    }
    
}

