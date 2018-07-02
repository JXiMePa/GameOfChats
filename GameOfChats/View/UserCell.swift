//
//  UserCell.swift
//  GameOfChats
//
//  Created by Tarasenko Jurik on 25.06.2018.
//  Copyright © 2018 Tarasenko Jurik. All rights reserved.
//



import UIKit
import Firebase
import FirebaseDatabase

class UserCell: UITableViewCell {
    
    var message: Message? {
        didSet {
            setupNameAndProfileImage()
            
            detailTextLabel?.text = message?.text
            if let seconds = message?.timestamp?.doubleValue {
                let timeDate = Date(timeIntervalSinceNow: seconds) //TODO: Wrong time!
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:MM a"
                timeLabel.text = dateFormatter.string(from: timeDate)
            }
        }
    }
    
    let timeLabel: UILabel = {
       let label = UILabel()
        label.text = "HH:MM:SS"
        label.textAlignment = .right
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = #colorLiteral(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
        return label
    }()
    
    lazy var profileImageView: CustomImageView = { //TODO: only for test not privat!
        let iv = CustomImageView()
        iv.image = UIImage(named: "gameofthrones_splash")
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = self.frame.height / 2
        iv.layer.masksToBounds = true
        return iv
    }()
    
    private func setupNameAndProfileImage() {

        if let id = message?.chatPartnerId() {
            let ref = Database.database().reference().child("users").child(id)
            
            ref.observe(.value, with: { [weak self] (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    self?.textLabel?.text = dictionary["name"] as? String
                    
                    if let profileImageUrl = dictionary["profileImageUrl"] as? String {
                        self?.profileImageView.loadImageWithUrl(profileImageUrl)
                    }
                }
            }, withCancel: nil)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 60, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        
        detailTextLabel?.frame = CGRect(x: 60, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier) //.subtitle
        
        addSubview(profileImageView)
        _ = profileImageView.anchor(left: self.leftAnchor, centerY: self.centerYAnchor, topConstant: 8, leftConstant: 8, bottomConstant: 8, widthConstant: 50, heightConstant: 50)
        
        addSubview(timeLabel)
        _ = timeLabel.anchor(self.topAnchor, right: self.rightAnchor, topConstant: 14, rightConstant: 8, widthConstant: 85, heightConstant: textLabel?.frame.height ?? 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
