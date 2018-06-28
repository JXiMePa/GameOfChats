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

        collectionView?.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        navigationItem.title = "Chat Log Controller"
        
        view.addSubview(containerView)
        _ = containerView.anchor(left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, heightConstant: 50)
        
        containerView.addSubview(sendButton)
        _ = sendButton.anchor(containerView.topAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, widthConstant: 80)
        
        containerView.addSubview(inputTextField)
        _ = inputTextField.anchor(containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: sendButton.leftAnchor, leftConstant: 8, rightConstant: 8)
        
        view.addSubview(separatorView)
        _ = separatorView.anchor(left: view.leftAnchor, bottom: containerView.topAnchor, right: view.rightAnchor, heightConstant: 1)
    }
    
    @objc private func handleSendButton() {
        let ref = Database.database().reference().child("messages")
        guard let text = inputTextField.text else { return }
        
        // best thing to include the name inside of the messages.
        let childRef = ref.childByAutoId() //unique key
        
        childRef.updateChildValues(["text": text])
        inputTextField.text = ""
    }
    
}

extension ChatLogController: UITextFieldDelegate { //Enter Interaction
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSendButton()
        return true
    }
}
