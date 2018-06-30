//
//  ChatLogController.swift
//  GameOfChats
//
//  Created by Tarasenko Jurik on 28.06.2018.
//  Copyright © 2018 Tarasenko Jurik. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class ChatLogController: UICollectionViewController {
    
    private let chatLogCellId = "chatLogCellId"
    private var messages = [Message]()
    
    var user: User? {
        didSet {
            navigationItem.title = user?.name
            observeMessages()
        }
    }
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
        return view
    }()
    
    private let sendButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        button.setTitle("Send", for: .normal)
        button.addTarget(self, action: #selector(handleSendButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var inputTextField: UITextField = {
       let tf = UITextField()
        tf.placeholder = "   Enter message..."
        tf.delegate = self
        return tf
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        return view
    }()
    
    //MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        collectionView?.alwaysBounceVertical = true
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: chatLogCellId)
        
        view.addSubview(containerView)
        _ = containerView.anchor(left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, heightConstant: 50)
        
        containerView.addSubview(sendButton)
        _ = sendButton.anchor(containerView.topAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, widthConstant: 80)
        
        containerView.addSubview(inputTextField)
        _ = inputTextField.anchor(containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: sendButton.leftAnchor, leftConstant: 8, rightConstant: 8)
        
        view.addSubview(separatorView)
        _ = separatorView.anchor(left: view.leftAnchor, bottom: containerView.topAnchor, right: view.rightAnchor, heightConstant: 1)
    }
    
    private func observeMessages()  {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let userMessageRef = Database.database().reference().child("user_messages").child(uid)
        
        userMessageRef.observe(.childAdded, with: { [weak self] (snapshot) in
         
        let messageId = snapshot.key
        let messagesRef = Database.database().reference().child("messages").child(messageId)
        
            messagesRef.observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                
                let message = Message()
                //potential Craching!!! if keys don't match
                message.setValuesForKeys(dictionary)
                
                if message.chatPartnerId() == self?.user?.id {
                    self?.messages.append(message)
                    
                    DispatchQueue.main.async {
                        self?.collectionView?.reloadData()
                    }
                }
                
                
            }, withCancel: nil)
            
        }, withCancel: nil)
    }
    
    @objc private func handleSendButton() {
        
        let ref = Database.database().reference().child("messages")
        guard let text = inputTextField.text else { return }
        
        // best thing to include the name inside of the messages.
        let childRef = ref.childByAutoId() //unique key
        
        guard let toId = user?.id else { print("toId???"); return }
        guard let fromId = Auth.auth().currentUser?.uid else { print("fromId?"); return }
        
        let timestamp = NSDate.timeIntervalSinceReferenceDate
        let values = ["text": text, "toId": toId, "fromId": fromId, "timestamp": timestamp] as [String : Any]
       // childRef.updateChildValues(values)
        childRef.updateChildValues(values) { (error, databaseReferense) in
            guard error == nil else { print(error!); return }
            
            let userMessagesRef = Database.database().reference().child("user_messages").child(fromId)
            let messageId = childRef.key //-LGEwuVgTv8aFEh4OuMp
            
            userMessagesRef.updateChildValues([messageId : 1])
            
            //recipient - oderjuva4
            let recipientUserMessagesRef = Database.database().reference().child("user_messages").child(toId)
            
            recipientUserMessagesRef.updateChildValues([messageId : 1])
        }
        
        inputTextField.text = ""
    }
    
}

extension ChatLogController: UICollectionViewDelegateFlowLayout {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: chatLogCellId, for: indexPath) as! ChatMessageCell
        
        let message = messages[indexPath.item]
        cell.textView.text = message.text
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 80)
    }
}

extension ChatLogController: UITextFieldDelegate { //Enter Interaction
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSendButton()
        return true
    }
}
