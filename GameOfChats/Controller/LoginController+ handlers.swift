//
//  LoginController+ handlers.swift
//  GameOfChats
//
//  Created by Tarasenko Jurik on 25.06.2018.
//  Copyright © 2018 Tarasenko Jurik. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase

extension LoginController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func handleSelectProfileImage() {
        
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = editedImage
            
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            profileImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleRegister() {
        print("Start Register!")
        
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else { print("Form is not valid")
            return }
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] (user, error) in
            
            if error != nil { print("error!")
                return }
            
            // successfully authenticated user
            let imageName = NSUUID().uuidString //unique name
            let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).jpg") //.png
            
            guard let userUnwrapped = Auth.auth().currentUser else { print("NO User!"); return }
            guard let profileImage = self?.profileImageView.image else { print("NO Image!"); return }
            
            if let uploadData = UIImageJPEGRepresentation(profileImage, 0.1) {
                //UIImagePNGRepresentation
                
                storageRef.putData(uploadData, metadata: nil, completion: { [weak self] (metadata, error) in
                    
                    if error != nil { print("error!", error!); return }
                    
                    
                    // Fetch the download URL
                    storageRef.downloadURL { [weak self] (url, error) in

                        if error != nil { print("Errrorr!")
                        } else {

                            let values = ["name": name, "email": email, "profileImageUrl": (url?.absoluteString) ?? ""]
                            
                     //register after Database upload!
                            self?.regirterUserIntoDatabase(withUid: userUnwrapped.uid, values: values )
                        }
                    }
                })
            }
        }
    }
    
    private func regirterUserIntoDatabase(withUid uid: String, values: [String: Any]) {
        
        let ref = Database.database().reference()
            //.reference(fromURL: "https://gameofchats-18146.firebaseio.com/")
        let usersReference = ref.child("users").child(uid)
        
        usersReference.updateChildValues(values, withCompletionBlock: { (error, ref) in
            
            if error != nil { print(error!); return }
            
//            guard let name = values["name"], let email = values["email"], let profileImageUrl = values["profileImageUrl"] else {
//                print("name?, email?, ProfileImage?"); return }
            
            //let user = User(name: name, email: email, profileImageUrl: profileImageUrl, id: nil)
            
            let user = User()
            
            user.setValuesForKeys(values)
            
            self.messagesController?.setupNavBarWithUser(user: user)
            
            self.dismiss(animated: true, completion: nil)
            print("Saved user successfully into Firebase!")
        })
    }
}
