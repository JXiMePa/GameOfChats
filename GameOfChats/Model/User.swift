//
//  User.swift
//  GameOfChats
//
//  Created by Tarasenko Jurik on 25.06.2018.
//  Copyright © 2018 Tarasenko Jurik. All rights reserved.
//

import UIKit

class User: NSObject {
    
    var name: String?
    var email: String?
    var profileImageUrl: String?
    
    init(name: String, email: String, profileImageUrl: String) {
        self.name = name
        self.email = email
        self.profileImageUrl = profileImageUrl
    }
   
}
