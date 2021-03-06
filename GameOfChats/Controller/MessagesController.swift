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
    private var timer: Timer?
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Loggout", style: .plain, target: self, action: #selector(handleLogout))
        
        let usersButton = UIBarButtonItem(image: #imageLiteral(resourceName: "new_message_icon"), style: .plain, target: self, action: #selector(handleNewMessage))
        // let chatLog = UIBarButtonItem(title: "Chat", style: .plain, target: self, action: #selector(showChatLogController))
        
        tableView.register(UserCell.self, forCellReuseIdentifier: userCellId)
        
        navigationItem.rightBarButtonItems = [usersButton]
        
        checkUserIsLoggedIn()
        
        tableView.allowsMultipleSelectionDuringEditing = true //*1 del
    }
    
    private func observeUserMessages() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return } // userID
        
        let ref = Database.database().reference().child("user_messages").child(uid)
        ref.observe(.childAdded, with: { [weak self] (snapshot) in
            
            let userId = snapshot.key
            Database.database().reference().child("user_messages").child(uid).child(userId).observe(.childAdded, with: { [weak self] (snapshot) in
                
                let messageId = snapshot.key
                self?.fetchMessageWithMessageId(messageId)
                
                }, withCancel: nil)
            
            }, withCancel: nil)
        
        ref.observe(.childRemoved) { [weak self] (snapshot)  in
            
            self?.groupMessage.removeValue(forKey: snapshot.key)
            self?.attemptReloadOfTable()
        }
        
    }
    
    private func fetchMessageWithMessageId(_ messageId: String) {
        
        let messageReference = Database.database().reference().child("messages").child(messageId)
        messageReference.observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let message = Message(dictionary: dictionary)
                
                if let chatPartnerId = message.chatPartnerId() {
                    self?.groupMessage[chatPartnerId] = message
                }
                
                self?.attemptReloadOfTable()
            }
        }, withCancel: nil)
    }
    
    private func attemptReloadOfTable() {
        //MARK: FIX!..  it will wait 0.1 sec if not cancel reload Table
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    @objc private func handleReloadTable() {
        self.messages = Array(self.groupMessage.values)
        self.messages.sort { $0.timestamp!.int32Value > $1.timestamp!.int32Value } //"!"
        
        DispatchQueue.main.async {
            //print("Table reload count test ")
            self.tableView.reloadData()
        }
    }
    
    private func checkUserIsLoggedIn() {
        
        if Auth.auth().currentUser?.uid == nil {
            performSelector(onMainThread: #selector(handleLogout), with: nil, waitUntilDone: false)
            
        } else {
            fetchUserAndSetupNavBarTitle()
        }
    }
    
    func fetchUserAndSetupNavBarTitle() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value) { [weak self] (snapshot) in
            
            if let dictionary = snapshot.value as? [String : Any] {
                
                let user = User()
                //if keys don't match potential Craching!!!
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
        _ = containerView.anchor(centerX: titleView.centerXAnchor, centerY: titleView.centerYAnchor)
        
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
    
    @objc private func handleLogout() {
        
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print("logout Error: ", logoutError)
        }
        
        let loginController = LoginController()
        loginController.messagesController = self //3
        present(loginController, animated: true, completion: nil)
    }
}

extension MessagesController {
    //*3 del
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let message  = self.messages[indexPath.row]
        guard let partnerId = message.chatPartnerId() else { return }
        
        Database.database().reference().child("user_messages").child(uid).child(partnerId).removeValue { (error, reference) in
            
            if error != nil {
                print("Failed deleate Message: \(error as Any)")
                return
            }
            
            self.groupMessage.removeValue(forKey: partnerId)
            self.attemptReloadOfTable()
            
//           //wrong way  ------
//            self.messages.remove(at: indexPath.row)
//            self.tableView.deleteRows(at: [indexPath], with: .automatic)
//            //--------------
            
        }
    }
    //*2 del
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let message = messages[indexPath.row]
        guard let chatPartnerId = message.chatPartnerId() else { return }
        
        let ref = Database.database().reference().child("users").child(chatPartnerId)
        ref.observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
            
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            
            let user = User()
            user.id = chatPartnerId
            //if keys don't match potential Craching!!!
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
