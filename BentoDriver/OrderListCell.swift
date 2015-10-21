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
        self.circleImageView = UIImageView(frame: CGRectMake(10, self.frame.height / 2 + 10, 20, 20))
        self.addSubview(self.circleImageView)
        
        // Address
        self.addressLabel = UILabel(frame: CGRectMake(40, 10, self.frame.size.width - 40 - 20, 40))
        self.addressLabel.numberOfLines = 2
        self.addressLabel.font = UIFont.boldSystemFontOfSize(15.0)
        self.addressLabel.textColor = UIColor.whiteColor()
        self.addSubview(self.addressLabel)
        
        // Name
        self.nameLabel = UILabel(frame: CGRectMake(40, self.addressLabel.frame.origin.y + 40, self.frame.size.width - 40 - 20, 20))
        self.nameLabel.font = UIFont.systemFontOfSize(13.0)
        self.nameLabel.textColor = UIColor.whiteColor()
        self.addSubview(self.nameLabel!)
        
        // Arrow note: using uiscreen to frame this because cell width is stuck at 320 for some reason...
        self.arrowImageView = UIImageView(frame: CGRectMake(UIScreen.mainScreen().bounds.width - 40, self.frame.height / 2 + 10, 20, 20))
        self.arrowImageView.image = UIImage(named: "gray-arrow-64")
        self.addSubview(self.arrowImageView)
        
        // Timestamp
        self.createdAtLabel = UILabel(frame: CGRectMake(self.arrowImageView.frame.origin.x - 70, self.frame.height / 2 + 10, 60, 20))
        self.createdAtLabel.font = UIFont.systemFontOfSize(13.0)
        self.createdAtLabel.textAlignment = .Right
        self.createdAtLabel.textColor = UIColor.darkGrayColor()
        self.addSubview(self.createdAtLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
