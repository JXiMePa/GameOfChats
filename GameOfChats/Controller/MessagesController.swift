//
//  ViewController.swift
//  GameOfChats
//
//  Created by Tarasenko Jurik on 22.06.2018.
//  Copyright © 2018 Tarasenko Jurik. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase


final class MessagesController: UITableViewController {
    
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Loggout", style: .plain, target: self, action: #selector(handleLoggout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "new_message_icon"), style: .plain, target: self, action: #selector(handleNewMessage))
        
        checkUserIsLoggedIn()
    }
    
    //MARK: isLoginCheck
    private func checkUserIsLoggedIn() {

        if Auth.auth().currentUser?.uid == nil {
            performSelector(onMainThread: #selector(handleLoggout), with: nil, waitUntilDone: false)
            
        } else {
            let uid = Auth.auth().currentUser?.uid
            
            Database.database().reference().child("users").child(uid!).observeSingleEvent(of: .value) { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    self.navigationItem.title = dictionary["name"] as? String
                }
            }
        }
    }
    
    
    @objc private func handleNewMessage() {
        
       let newMessageController = NewMessageController()
       let navCoontroller = UINavigationController(rootViewController: newMessageController)
        
        present(navCoontroller, animated: true, completion: nil)
    }
    
    @objc private func handleLoggout() {
        
        do {
            try Auth.auth().signOut()
        } catch let loggoutError {
            print(loggoutError)
        }
        
        let loginController = LoginController()
        present(loginController, animated: true, completion: nil)
    }
    
}//end

