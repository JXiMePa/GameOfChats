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

     let textView: UITextView = { //TODO: only for test not privat!
        let textView = UITextView()
        textView.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.layer.cornerRadius = 15
        textView.textAlignment = .center
        return textView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(textView)
       _ = textView.anchor(self.topAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, rightConstant: 12)
        messageViewWidth = textView.widthAnchor.constraint(equalToConstant: 200)
        messageViewWidth?.isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
