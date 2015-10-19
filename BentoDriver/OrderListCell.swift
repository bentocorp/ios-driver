//
//  OrderListCell.swift
//  BentoDriver
//
//  Created by Joseph Lau on 10/19/15.
//  Copyright © 2015 Joseph Lau. All rights reserved.
//

import UIKit

class OrderListCell: UITableViewCell {

    var circleImageView: UIImageView!
    var addressLabel: UILabel!
    var nameLabel: UILabel!
    var createdAtLabel: UILabel!
    var arrowImageView: UIImageView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        // Initialization code
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Circle
        self.circleImageView = UIImageView(frame: CGRectMake(10, 20, 20, 20))
        self.circleImageView.image = UIImage(named: "yellow-circle-64")
        self.addSubview(self.circleImageView)
        
        // Address
        self.addressLabel = UILabel(frame: CGRectMake(40, 5, self.frame.size.width - 40 - 20, 20))
        self.addressLabel.numberOfLines = 2
        self.addressLabel.font = UIFont.boldSystemFontOfSize(15.0)
        self.addSubview(self.addressLabel)
        
        // Name
        self.nameLabel = UILabel(frame: CGRectMake(40, self.addressLabel.frame.origin.y + 30, self.frame.size.width - 40 - 20, 20))
        self.addSubview(self.nameLabel!)
        
        // Timestamp
        //        self.createdAtLabel = UILabel
        
        // Arrow
        self.arrowImageView = UIImageView(frame: CGRectMake(self.frame.width - 20, self.frame.height / 2 - 5, 10, 10))
        self.arrowImageView.image = UIImage(named: "yellow-arrow-64")
        self.addSubview(self.arrowImageView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
