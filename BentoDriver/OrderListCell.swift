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
        
        self.backgroundColor = UIColor.clearColor()
        
        // Circle
        circleImageView = UIImageView(frame: CGRectMake(20, self.frame.height / 2 + 20, 20, 20))
        self.addSubview(circleImageView)
        
        // Address
        addressLabel = UILabel(frame: CGRectMake(20 + self.circleImageView.frame.width + 20, 10, self.frame.size.width - 40 - 20, 60))
        addressLabel.numberOfLines = 2
        addressLabel.font = UIFont(name: "OpenSans-Bold", size: 17)
        addressLabel.textColor = UIColor.whiteColor()
        self.addSubview(addressLabel)
        
        // Name
        nameLabel = UILabel(frame: CGRectMake(20 + self.circleImageView.frame.width + 20, self.addressLabel.frame.origin.y + 60, self.frame.size.width - 40 - 20, 20))
        nameLabel.font = UIFont(name: "OpenSans-Bold", size: 14)
        nameLabel.textColor = UIColor.lightGrayColor()
        self.addSubview(nameLabel!)
        
        // Arrow note: using uiscreen to frame this because cell width is stuck at 320 for some reason...
        arrowImageView = UIImageView(frame: CGRectMake(UIScreen.mainScreen().bounds.width - 40, self.frame.height / 2 + 20, 20, 20))
        arrowImageView.image = UIImage(named: "gray-arrow-64")
        self.addSubview(arrowImageView)
        
        // Timestamp
        createdAtLabel = UILabel(frame: CGRectMake(self.arrowImageView.frame.origin.x - 70, self.frame.height / 2 + 20, 60, 20))
        createdAtLabel.font = UIFont.systemFontOfSize(13.0)
        createdAtLabel.textAlignment = .Right
        createdAtLabel.textColor = UIColor.whiteColor()
        self.addSubview(createdAtLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
