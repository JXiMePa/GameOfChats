//
//  UserCell.swift
//  GameOfChats
//
//  Created by Tarasenko Jurik on 25.06.2018.
//  Copyright © 2018 Tarasenko Jurik. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {
    
    lazy var profileImageView: CustomImageView = { //TODO: only for test not privat!
       let iv = CustomImageView()
        iv.image = UIImage(named: "gameofthrones_splash")
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = self.frame.height / 2
        iv.layer.masksToBounds = true
        return iv
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 60, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        
        detailTextLabel?.frame = CGRect(x: 60, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier) //.subtitle
        
        addSubview(profileImageView)
        _ = profileImageView.anchor(self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, topConstant: 8, leftConstant: 5, bottomConstant: 8, rightConstant: 5, widthConstant: 50)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
