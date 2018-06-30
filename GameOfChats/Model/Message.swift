//
//  Message.swift
//  GameOfChats
//
//  Created by Tarasenko Jurik on 28.06.2018.
//  Copyright © 2018 Tarasenko Jurik. All rights reserved.
//

import UIKit
import Firebase


class Message: NSObject {
  
   @objc var fromId: String?
   @objc var text: String?
   @objc var timestamp: NSNumber?
   @objc var toId: String?
    
    func chatPartnerId() -> String? {
        return fromId == Auth.auth().currentUser?.uid ? toId : fromId
    }

}
