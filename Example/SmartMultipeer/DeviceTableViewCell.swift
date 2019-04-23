//
//  DeviceTableViewCell.swift
//  MultipeerConnectivityExample
//
//  Created by Ajay Sagar Parwani on 4/18/19.
//  Copyright © 2019 Ajay Sagar Parwani. All rights reserved.
//

import UIKit

class DeviceTableViewCell: UITableViewCell {

    @IBOutlet weak var labelDeviceName: UILabel!
    @IBOutlet weak var labelDeviceState: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
