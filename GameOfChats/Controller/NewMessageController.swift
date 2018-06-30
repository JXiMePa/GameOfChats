//
//  NewMessageController.swift
//  GameOfChats
//
//  Created by Tarasenko Jurik on 25.06.2018.
//  Copyright © 2018 Tarasenko Jurik. All rights reserved.
//

import UIKit
import FirebaseDatabase

class NewMessageController: UITableViewController {
    
    private let newMessageCellId = "newMessageCellId"
    private var users = [User]()
    weak var messagesController: MessagesController? //2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        tableView.register(UserCell.self, forCellReuseIdentifier: newMessageCellId)
        
        fetchUser()
    }
    
    private func fetchUser() {
        
        Database.database().reference().child("users").observe(.childAdded, with: { [weak self] (snapshot) in
            
            if let dictionary = snapshot.value as? [String: Any] {
                
                //guard let name = dictionary["name"], let email = dictionary["email"], let profileImageUrl = dictionary["profileImageUrl"] else {
                   // print("name?, email?, ProfileImage?"); return }
                
                //let user = User(name: name, email: email, profileImageUrl: profileImageUrl, id: snapshot.key)
                
                let user = User()
                user.setValuesForKeys(dictionary)
                user.id = snapshot.key
                
                self?.users.append(user)
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
            
        }, withCancel: nil)
    }
    
    @objc private func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
}

extension NewMessageController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: newMessageCellId, for: indexPath) as! UserCell
        
        let user = users[indexPath.row]
        
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        
        if let profileImageUrl = user.profileImageUrl {
            
            cell.profileImageView.loadImageWithUrl(profileImageUrl)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ConstantsValue.messageRowsHight
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            let user = self.users[indexPath.row]
            
            self.messagesController?.showChatLogControllerForUser(user) //1
        }
    }
}





