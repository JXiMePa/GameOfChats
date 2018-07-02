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
        view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        return view
    }()
    
    private let sendButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
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
    
    private var containerViewBottomAnchor: NSLayoutConstraint?
    
    //MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.keyboardDismissMode = .onDrag
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 58, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        collectionView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        collectionView?.alwaysBounceVertical = true
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: chatLogCellId)
        
        view.addSubview(containerView)
        _ = containerView.anchor(left: view.leftAnchor, right: view.rightAnchor, heightConstant: 50)
        containerViewBottomAnchor = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        containerViewBottomAnchor?.isActive = true
        
        containerView.addSubview(sendButton)
        _ = sendButton.anchor(containerView.topAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, widthConstant: 80)
        
        containerView.addSubview(inputTextField)
        _ = inputTextField.anchor(containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: sendButton.leftAnchor, leftConstant: 8, rightConstant: 8)
        
        view.addSubview(separatorView)
        _ = separatorView.anchor(left: view.leftAnchor, bottom: containerView.topAnchor, right: view.rightAnchor, heightConstant: 1)
        
        observeKeyboardNotifications()
    }
    
    ///----------------------------------------
    //Key Board Observe Copy/Past
    private func observeKeyboardNotifications() { //Key Board Observer
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow), name: .UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: .UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func keyboardHide(notification: Notification) {
        
        self.containerViewBottomAnchor?.constant = 0
        
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func keyboardShow(notification: Notification) {
        
        guard let keyBoardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect else { return }
        self.containerViewBottomAnchor?.constant = -keyBoardFrame.height
        
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    ///----------------------------------------
    
    fileprivate func estimateFrameForText(_ text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    private func observeMessages()  {
        
        guard let uid = Auth.auth().currentUser?.uid, let toId = user?.id else { return }
        
        let userMessageRef = Database.database().reference().child("user_messages").child(uid).child(toId)
        userMessageRef.observe(.childAdded, with: { [weak self] (snapshot) in
       
        let messagesRef = Database.database().reference().child("messages").child(snapshot.key)
        messagesRef.observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                
                let message = Message()
                //potential Craching!!! if keys don't match
                message.setValuesForKeys(dictionary)
            
                 //print("correctly fetch message from firebase")
                    self?.messages.append(message)
                    DispatchQueue.main.async {
                        self?.collectionView?.reloadData()
                    }

            }, withCancel: nil)
            
        }, withCancel: nil)
    }
    
    @objc private func handleSendButton() {
        
        let ref = Database.database().reference().child("messages")
        guard let text = inputTextField.text else { return }
        
        // best thing to include the name inside of the messages.
        let childRef = ref.childByAutoId() //unique key
        
        guard let toId = user?.id else { print("guard toId?"); return }
        guard let fromId = Auth.auth().currentUser?.uid else { print("guard fromId?"); return }
        
        let timestamp = NSDate.timeIntervalSinceReferenceDate
        let values = ["text": text, "toId": toId, "fromId": fromId, "timestamp": timestamp] as [String : Any]

        childRef.updateChildValues(values) { [weak self] (error, databaseReferense) in
            guard error == nil else { print(error!); return }
            
            let userMessagesRef = Database.database().reference().child("user_messages").child(fromId).child(toId)
            let messageId = childRef.key //-LGEwuVgTv8aFEh4OuMp
            
            self?.inputTextField.text = nil
            
            userMessagesRef.updateChildValues([messageId : 1])
            
            //recipient - одержувач
            let recipientUserMessagesRef = Database.database().reference().child("user_messages").child(toId).child(fromId)
            recipientUserMessagesRef.updateChildValues([messageId : 1])
        }
    }
}

extension ChatLogController: UICollectionViewDelegateFlowLayout {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: chatLogCellId, for: indexPath) as! ChatMessageCell
        
        let message = messages[indexPath.item]
        cell.textMessage.text = message.text
        
        setupCell(cell, message: message)
        
        if let text = message.text {
        cell.messageViewWidth?.constant = estimateFrameForText(text).width + 32
            
        }
        return cell
    }
    
    private func setupCell(_ cell: ChatMessageCell, message: Message) {
        
        if let profileImageUrl = self.user?.profileImageUrl {
      cell.profileImageView.loadImageWithUrl(profileImageUrl)
        }
        
        if message.fromId == Auth.auth().currentUser?.uid {
            // blue message
            cell.textMessage.backgroundColor = ConstantsValue.backgroundBlueColor
            cell.textMessage.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            cell.profileImageView.isHidden = true
            cell.messageViewRightAnchor?.isActive = true
            cell.messageViewLeftAnchor?.isActive = false
            
        } else {
            // grey message
            cell.textMessage.backgroundColor = #colorLiteral(red: 0.8149032598, green: 0.8149032598, blue: 0.8149032598, alpha: 1)
            cell.textMessage.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            cell.profileImageView.isHidden = false
            cell.messageViewRightAnchor?.isActive = false
            cell.messageViewLeftAnchor?.isActive = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var hight: CGFloat = 80
        
        if let text = messages[indexPath.item].text {
            hight = estimateFrameForText(text).height + 20
        }
        return CGSize(width: view.frame.width, height: hight)
    }
}

extension ChatLogController: UITextFieldDelegate { //Enter Interaction
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSendButton()
        return true
    }
}
