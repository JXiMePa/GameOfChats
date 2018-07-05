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
import MobileCoreServices
import AVFoundation

class ChatLogController: UICollectionViewController {
    
    private let chatLogCellId = "chatLogCellId"
    private var messages = [Message]()
    
    var user: User? {
        didSet {
            navigationItem.title = user?.name
            observeMessages()
        }
    }
    
    private let containerView: ChatInputContainerView = {
        let view = ChatInputContainerView()
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
    
    private lazy var uploadImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "upload_image_icon")
        iv.backgroundColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
        iv.layer.cornerRadius = 16
        iv.layer.masksToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadImage)))
        return iv
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
        
        containerView.addSubview(uploadImageView)
        _ = uploadImageView.anchor(left: containerView.leftAnchor, centerY: containerView.centerYAnchor, widthConstant: 44, heightConstant: 44)
        
        containerView.addSubview(inputTextField)
        _ = inputTextField.anchor(containerView.topAnchor, left: uploadImageView.rightAnchor, bottom: containerView.bottomAnchor, right: sendButton.leftAnchor, leftConstant: 8, rightConstant: 8)
        
        view.addSubview(separatorView)
        _ = separatorView.anchor(left: view.leftAnchor, bottom: containerView.topAnchor, right: view.rightAnchor, heightConstant: 1)
        
        
        observeKeyboardNotifications()
    }

    //Key Board Observe
    private func observeKeyboardNotifications() {
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

                //print("correctly fetch message from firebase")
                self?.messages.append(Message(dictionary: dictionary))
                
                DispatchQueue.main.async {
                    self?.collectionView?.reloadData()
                    guard let count = self?.messages.count else { return }
                    let indexPatch = IndexPath(item: count - 1, section: 0)
                    self?.collectionView?.scrollToItem(at: indexPatch, at: .bottom, animated: true)
                }
                
                }, withCancel: nil)
            
            }, withCancel: nil)
    }
    
    @objc private func handleUploadImage() {
        let imagePikerController = UIImagePickerController()
        
        imagePikerController.allowsEditing = true
        imagePikerController.delegate = self
        imagePikerController.mediaTypes = [kUTTypeImage, kUTTypeMovie] as [String]
        
        present(imagePikerController, animated: true, completion: nil)
    }
    
    private func uploadToFirebaseStorageUsingImage(_ image: UIImage, completion: @escaping (_ imageUrl: String) -> ()) {
        let ImageName = NSUUID().uuidString
        let ref = Storage.storage().reference().child("message_images").child(ImageName)
        
        if let uploadData = UIImageJPEGRepresentation(image, 0.1) {
            
            ref.putData(uploadData, metadata: nil) { (metaData, error) in // weak if self
                guard error == nil else { print("Failed to upload image: \(error!)"); return }
                
                ref.downloadURL(completion: { (url, error) in  // weak if self
                    guard error == nil else { print("Failed: \(error!)"); return }
                    
                    if let imageUrl = url?.absoluteString {
                        completion(imageUrl)
                    }
                    // print(url?.absoluteString)
                })
            }
        }
    }
    
    private func sendMessageWithImageUrl(_ imageUrl: String, image: UIImage) {
        
        let properties: [String : Any] = ["imageUrl": imageUrl, "imageWidth": image.size.width, "imageHight": image.size.height]
        
        sendMessageWithPropertis(properties)
    }
    
    @objc private func handleSendButton() {
        
        guard let text = inputTextField.text else { return }
        let properties: [String : Any] = ["text": text]
        
        sendMessageWithPropertis(properties)
    }
    
    private func sendMessageWithPropertis(_ properties: [String: Any]) {
        
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId() //unique key
        guard let toId = user?.id else { print("guard toId?"); return }
        guard let fromId = Auth.auth().currentUser?.uid else { print("guard fromId?"); return }
        let timestamp = Int(NSDate.timeIntervalSinceReferenceDate)
        
        var values: [String : Any] = ["toId": toId, "fromId": fromId, "timestamp": timestamp]
        
        properties.forEach { values[$0] = $1 }
        
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
    
    private var startingViewFrame: CGRect?
    private var blackBackgroundView: UIView?
    private var zoomImageView: UIImageView?
    
    
    //MARK: Custom Zooming Logic
     func performZoomIn(_ imageView: UIImageView) {

        self.zoomImageView = imageView
        self.zoomImageView?.isHidden = true
        
         startingViewFrame = imageView.superview?.convert(imageView.frame, to: nil)
        
        let zoomingImageView = UIImageView(frame: startingViewFrame!)
        zoomingImageView.backgroundColor = .clear
        zoomingImageView.image = imageView.image
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        if let keyWindow = UIApplication.shared.keyWindow {
            
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = .black
            blackBackgroundView?.alpha = 0
            
            keyWindow.addSubview(blackBackgroundView!)
            keyWindow.addSubview(zoomingImageView)
            
            UIView.animate(withDuration: 0.25) { [weak self] in
                self?.blackBackgroundView?.alpha = 1
                self?.containerView.alpha = 0
                
                //h2 = h1 / w1 * w2
                let height = imageView.frame.height / imageView.frame.width * keyWindow.frame.width
                
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                
                zoomingImageView.center = keyWindow.center
            }
        }
    }
    
    @objc private func handleZoomOut(_ tapGesture: UITapGestureRecognizer) {
        guard let zoomUotImageView = tapGesture.view else { return }
        zoomUotImageView.layer.cornerRadius = 15
        zoomUotImageView.clipsToBounds = true
        
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            
            zoomUotImageView.frame = (self?.startingViewFrame)!
            self?.blackBackgroundView?.alpha = 0
            self?.containerView.alpha = 1
            
        }, completion: { (completed: Bool) in
           zoomUotImageView.removeFromSuperview()
            self.zoomImageView?.isHidden = false
        })

    }
    
}

extension ChatLogController: UICollectionViewDelegateFlowLayout {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: chatLogCellId, for: indexPath) as! ChatMessageCell
        
        cell.chatLogController = self // #1
        
        let message = messages[indexPath.item]
        cell.textMessage.text = message.text
        
        cell.message = message
        
        setupCell(cell, message: message)
        
        if let text = message.text {
            cell.messageViewWidth?.constant = estimateFrameForText(text).width + 32
            
        } else if message.imageUrl != nil { // if text nil
            cell.messageViewWidth?.constant = 200
            
        }
        
        cell.playButton.isHidden = message.videoUrl == nil
        
        return cell
    }
    
    private func setupCell(_ cell: ChatMessageCell, message: Message) {
        
        if let profileImageUrl = self.user?.profileImageUrl {
            cell.profileImageView.loadImageWithUrl(profileImageUrl)
        }
        
        if let messageImageUrl = message.imageUrl {
            cell.messageImageView.loadImageWithUrl(messageImageUrl)
            cell.messageImageView.isHidden = false
            cell.textMessage.isHidden = true
        } else {
            cell.messageImageView.isHidden = true
            cell.textMessage.isHidden = false
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
        
        let message = messages[indexPath.item]
        if let text = message.text {
            hight = estimateFrameForText(text).height + 20
        } else if let imageWidth = message.imageWidth as? CGFloat, let imageHight = message.imageHight as? CGFloat {
            // h1 / w1 = h2 / w2,   h1 = h2 / w2 * w1
            hight = imageHight / imageWidth * 200
        }
        
        return CGSize(width: view.frame.width, height: hight)
    }
}

extension ChatLogController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let videoUrl = info[UIImagePickerControllerMediaURL] as? URL {
            // we selected Video
            handleVideoSelectedForUrl(videoUrl)

          } else {
            // we selected Image
            handleImageSelectedForInfo(info)
        }
        dismiss(animated: true, completion: nil)
    }
    
    private func handleVideoSelectedForUrl(_ url: URL) {

        let uploadTask = Storage.storage().reference().child("message_movies").child(UUID().uuidString + ".mov")
        
       let task = uploadTask.putFile(from: url, metadata: nil) {
            [weak self] (metadata, error) in
            
            guard error == nil else { print("Video?"); return }
            
            uploadTask.downloadURL(completion: { [weak self] (url, error) in
                
                guard error == nil else { print("Video?"); return }
                guard let videoUrl = url else { return }
                
                if let thumbnailImage = self?.thumbnailImageForVideoUrl(videoUrl) {
                
                    self?.uploadToFirebaseStorageUsingImage(thumbnailImage, completion: { (imageUrl) in

                        let properties: [String: Any] = ["imageUrl": imageUrl, "imageWidth": thumbnailImage.size.width, "imageHeight": thumbnailImage.size.height, "videoUrl": videoUrl.absoluteString]
                        
                        self?.sendMessageWithPropertis(properties)
                    })
                }
            })
        }
        
        task.observe(.progress) { [weak self] (snapshot) in
            
            if let completedUnitCount = snapshot.progress?.completedUnitCount {
                // progress will implement
                self?.navigationItem.title = "\(completedUnitCount) bute"
            }
        }
        
        task.observe(.success) { [weak self] _ in
                self?.navigationItem.title = self?.user?.name
        }
        
    }//
    
    //first frame CMTime(value: 1, timescale: 60)
    private func thumbnailImageForVideoUrl(_ videoUrl: URL) -> UIImage? {
        let asset = AVAsset(url: videoUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTime(value: 1, timescale: 60), actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)
            
        } catch let error {
            print(error)
        }
        return nil
    }
    
    private func handleImageSelectedForInfo(_ info: [String: Any]) {
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = editedImage
            
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {

            uploadToFirebaseStorageUsingImage(selectedImage) { [weak self] (imageUrl) in
                self?.sendMessageWithImageUrl(imageUrl, image: selectedImage)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension ChatLogController: UITextFieldDelegate { //"Enter" keyboard Interaction
    //inputTextField.delegate = self
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSendButton()
        return true
    }
}
