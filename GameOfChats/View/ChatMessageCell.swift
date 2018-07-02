//
//  ChatMessageCell.swift
//  GameOfChats
//
//  Created by Tarasenko Jurik on 30.06.2018.
//  Copyright © 2018 Tarasenko Jurik. All rights reserved.
//

import UIKit

class ChatMessageCell: UICollectionViewCell {
    
    var messageViewWidth: NSLayoutConstraint?
    var messageViewLeftAnchor: NSLayoutConstraint?
    var messageViewRightAnchor: NSLayoutConstraint?
    
    let textMessage: UILabel = { //TODO: only for test not privat!
        let label = UILabel()
        label.font = ConstantsValue.font
        label.layer.cornerRadius = 15
        label.textAlignment = .center
        label.layer.masksToBounds = true
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    let profileImageView: CustomImageView = { //TODO: only for test not privat!
        let iv = CustomImageView()
        iv.layer.cornerRadius = 16
        iv.layer.masksToBounds = true
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(profileImageView)
        _ = profileImageView.anchor(left: self.leftAnchor, bottom: self.bottomAnchor, leftConstant: 8, widthConstant: 32, heightConstant: 32)
        
        addSubview(textMessage)
        _ = textMessage.anchor(self.topAnchor, bottom: self.bottomAnchor, rightConstant: 12)
        messageViewRightAnchor = textMessage.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8)
        messageViewRightAnchor?.isActive = true
        messageViewLeftAnchor = textMessage.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8)
        messageViewWidth = textMessage.widthAnchor.constraint(equalToConstant: 200)
        messageViewWidth?.isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
