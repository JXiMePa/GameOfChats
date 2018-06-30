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
    
    private var messages = [Message]()
    private var groupMessage = [String: Message]()
    private let userCellId = "userCellId"
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Loggout", style: .plain, target: self, action: #selector(handleLoggout))
        
        let usersButton = UIBarButtonItem(image: #imageLiteral(resourceName: "new_message_icon"), style: .plain, target: self, action: #selector(handleNewMessage))
        // let chatLog = UIBarButtonItem(title: "Chat", style: .plain, target: self, action: #selector(showChatLogController))
        
        tableView.register(UserCell.self, forCellReuseIdentifier: userCellId)
        
        navigationItem.rightBarButtonItems = [usersButton]
        
        checkUserIsLoggedIn()
        //observeMessages()

    }
    
    private func observeUserMessages() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return } // user ID
        
        let ref = Database.database().reference().child("user_messages").child(uid)
        ref.observe(.childAdded, with: { [weak self] (snapshot) in
            let messageId = snapshot.key
            
            let messageReference = Database.database().reference().child("messages").child(messageId)
            messageReference.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    let message = Message()
                    message.setValuesForKeys(dictionary)
                    
                    if let id = message.toId {
                        self?.groupMessage[id] = message
                        
                        guard let value = self?.groupMessage.values else { return }
                        self?.messages = Array(value)
                        
                        //Potentially crash - "!", but message must have timestamp.
                        self?.messages.sort { $0.timestamp!.int32Value > $1.timestamp!.int32Value
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                }
                
            }, withCancel: nil)
            
            
        }, withCancel: nil)
    }
    
    private func observeMessages() {
        
        let ref = Database.database().reference().child("messages")
        ref.observe(.childAdded, with: { [weak self] (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let message = Message()
                message.setValuesForKeys(dictionary)
                
                if let id = message.toId {
                    self?.groupMessage[id] = message
                    
                    guard let value = self?.groupMessage.values else { return }
                    self?.messages = Array(value)
                    
                    //Potentially crash - "!", but message must have timestamp.
                    self?.messages.sort { $0.timestamp!.int32Value > $1.timestamp!.int32Value
                    }
                }
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
            
        }, withCancel: nil)
    }
    
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
                
//                guard let name = dictionary["name"],
//                    let email = dictionary["email"],
//                    let profileImageUrl = dictionary["profileImageUrl"] else { return }
//
//                let user = User(name: name , email: email, profileImageUrl: profileImageUrl, id: nil)
                
                let user = User()
                user.setValuesForKeys(dictionary)
                self?.setupNavBarWithUser(user: user)
            }
        }
    }
    
    func setupNavBarWithUser(user: User) {
        
        messages.removeAll()
        groupMessage.removeAll()
        tableView.reloadData()
        
        observeUserMessages()
        
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
    
    @objc func showChatLogControllerForUser(_ user: User) {
        
        let layaut = UICollectionViewFlowLayout()
        let chatLogController = ChatLogController(collectionViewLayout: layaut)
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    @objc private func handleNewMessage() {
        
        let newMessageController = NewMessageController()
        let navCoontroller = UINavigationController(rootViewController: newMessageController)
        
        newMessageController.messagesController = self
        present(navCoontroller, animated: true, completion: nil)
    }
    
    @objc private func handleLoggout() {
        
        do {
            try Auth.auth().signOut()
            
        } catch let loggoutError {
            print("loggoutError: ", loggoutError)
        }
        
        let loginController = LoginController()
        loginController.messagesController = self //3
        present(loginController, animated: true, completion: nil)
    }
    
}//end

extension MessagesController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let message = messages[indexPath.row]
        guard let chatPartnerId = message.chatPartnerId() else { return }
        
        let ref = Database.database().reference().child("users").child(chatPartnerId)
        ref.observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
            
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            
            let user = User()
            user.setValuesForKeys(dictionary)
            self?.showChatLogControllerForUser(user)
            
        }, withCancel: nil)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: userCellId, for: indexPath) as! UserCell
        
        cell.message = messages[indexPath.row]
        
        return cell
    }
}

//print(snapshot)
//Snap (7wviQLvOgwg3WbzGOBsoukMrHct2) {
//    email = "Drakoniha@gmail.com";
//    name = Drakoniha;
//    profileImageUrl = "https://firebasestorage.googleapis.com/v0/b/gameofchats-18146.appspot.com/o/profile_images%2F07AB8C12-1FC4-447B-A722-DF8E4DA46201.png?alt=media&token=9bc7df01-9ad7-46f5-ab5b-edfb0275e93a";
//}
