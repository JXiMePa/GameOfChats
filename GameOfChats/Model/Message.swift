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
    
     var fromId: String?
     var text: String?
     var timestamp: NSNumber?
     var toId: String?
     var imageUrl: String?
     var imageHight: NSNumber?
     var imageWidth: NSNumber?
    
    func chatPartnerId() -> String? {
        return fromId == Auth.auth().currentUser?.uid ? toId : fromId
    }
    
    init(dictionary: [String: Any]) {
        super.init()
        
        fromId = dictionary["fromId"] as? String
        text = dictionary["text"] as? String
        timestamp = dictionary["timestamp"] as? NSNumber
        toId = dictionary["toId"] as? String
        imageUrl = dictionary["imageUrl"] as? String
        imageHight = dictionary["imageHight"] as? NSNumber
        imageWidth = dictionary["imageWidth"] as? NSNumber
    }
    
}
