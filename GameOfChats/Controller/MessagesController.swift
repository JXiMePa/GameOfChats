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
        
       let usersButton = UIBarButtonItem(image: #imageLiteral(resourceName: "new_message_icon"), style: .plain, target: self, action: #selector(handleNewMessage))
       let chatLog = UIBarButtonItem(title: "Chat", style: .plain, target: self, action: #selector(showChatLogController))
        
        navigationItem.rightBarButtonItems = [usersButton, chatLog]
        
        checkUserIsLoggedIn()
    }
    
    //MARK: isLoginCheck
    private func checkUserIsLoggedIn() {
        
        if Auth.auth().currentUser?.uid == nil {
            performSelector(onMainThread: #selector(handleLoggout), with: nil, waitUntilDone: false)
            
        } else {
            fetchUserAndSetupNavBarTitle()
        }
    }
    
    func fetchUserAndSetupNavBarTitle() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value) { [weak self] (snapshot) in
            
            if let dictionary = snapshot.value as? [String: String] {
                
                guard let name = dictionary["name"],
                    let email = dictionary["email"],
                    let profileImageUrl = dictionary["profileImageUrl"] else { return }
                
                let user = User(name: name , email: email, profileImageUrl: profileImageUrl)
                
                self?.setupNavBarWithUser(user: user)
            }
        }
    }
    
     func setupNavBarWithUser(user: User) {
        
        let titleView = UIView()
        let containerView = UIView()
        titleView.addSubview(containerView)
        
        let profileImageView = CustomImageView()
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        if let profileImageUrl = user.profileImageUrl {
            profileImageView.loadImageWithUrl(profileImageUrl)
            
            containerView.addSubview(profileImageView)
            
            _ = profileImageView.anchor(left: containerView.leftAnchor, centerY: containerView.centerYAnchor, widthConstant: 40, heightConstant: 40)
        }
        
        let nameLabel = UILabel()
        nameLabel.text = user.name
        
        containerView.addSubview(nameLabel)
        _ = nameLabel.anchor(left: profileImageView.rightAnchor, right: containerView.rightAnchor, centerY: profileImageView.centerYAnchor, leftConstant: 8, heightConstant: 40)
        
        _ = containerView.anchor(centerX: titleView.centerXAnchor, centerY: titleView.centerYAnchor)
        
        self.navigationItem.titleView = titleView
    }
    
    @objc private func showChatLogController() {
        
        let layaut = UICollectionViewFlowLayout()
        let chatLogController = ChatLogController(collectionViewLayout: layaut)
        navigationController?.pushViewController(chatLogController, animated: true)
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
            print("loggoutError: ", loggoutError)
        }
        
        let loginController = LoginController()
        loginController.messagesController = self
        present(loginController, animated: true, completion: nil)
    }
    
}//end

