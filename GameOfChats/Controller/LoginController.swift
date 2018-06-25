//
//  LoginController.swift
//  GameOfChats
//
//  Created by Tarasenko Jurik on 22.06.2018.
//  Copyright © 2018 Tarasenko Jurik. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

final class LoginController: UIViewController {
    
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 25
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.image = #imageLiteral(resourceName: "gameofthrones_splash")
        //imageView.layer.borderWidth = 1
        return imageView
    }()
    
    private let inputsContainerView: UIView = {
        let view = UIView()
        view .backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var loginRegisterButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = #colorLiteral(red: 0.4331629546, green: 0.6098792745, blue: 0.8811865482, alpha: 1)
        button.setTitle("Register", for: .normal)
        button.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 28)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(handleLoginRegirter), for: .touchUpInside)
        return button
    }()
    
    private let nameTextField: UITextField = {
        let textFild = UITextField()
        textFild.placeholder = "  Name"
        return textFild
    }()
    private let nameSeparatorView : UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        return view
    }()
    
    private let emailTextField: UITextField = {
        let textFild = UITextField()
        textFild.placeholder = "  Email address"
        return textFild
    }()
    private let emailSeparatorView : UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        return view
    }()
    
    private let passwordTextField: UITextField = {
        let textFild = UITextField()
        textFild.placeholder = "  Enter password"
        textFild.isSecureTextEntry = true
        return textFild
    }()
    private let passwordSeparatorView : UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        return view
    }()
    
    private lazy var loginRegisterSegmentControl: UISegmentedControl = {
       let sc = UISegmentedControl(items: ["Login", "Register"])
        sc.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        sc.selectedSegmentIndex = 1
        sc.addTarget(self, action: #selector(handleLoginRegisterChange), for: .valueChanged)
        return sc
    }()
    
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = ConstantsValue.backgroundBlueColor
        
        setupViews()
 
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
         if UIDevice.current.orientation.isLandscape {
            profileImageView.isHidden = true
         } else {
            profileImageView.isHidden = false
        }
    }
    
    @objc private func handleLoginRegisterChange() {
        
        let title = loginRegisterSegmentControl.titleForSegment(at: loginRegisterSegmentControl.selectedSegmentIndex)
        
        loginRegisterButton.setTitle(title, for: .normal)
        // change hight inputContainerView
        
        inputsCounteinerViewHeight?.constant = loginRegisterSegmentControl.selectedSegmentIndex == 0 ? ConstantsValue.loginHeight * 2 : ConstantsValue.loginHeight * 3
        
        //change height nameTextField
        nameTextFieldHeightAnchor?.isActive = false
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(
            equalTo: inputsContainerView.heightAnchor,
            multiplier: loginRegisterSegmentControl.selectedSegmentIndex == 0 ? 0 : 1/3)
        
        nameTextFieldHeightAnchor?.isActive = true
    }
    
    @objc private func handleLoginRegirter() {
        if loginRegisterSegmentControl.selectedSegmentIndex == 0 {
            handleLogin()
        } else {
           handleRegister()
        }
    }
    
    private func handleLogin() {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            print("Form is not Value"); return }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (user, error) in
            if error != nil { print(error!); return }
            
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func handleRegister() {
        print("Register!")
        
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else {
            print("Form is not Value"); return }
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] (user, error) in
            if error != nil { print(error!); return }
            
            // successfully authenticated user
            guard let userUnwrapped = Auth.auth().currentUser else { return }
            let uid = userUnwrapped.uid
            
            let ref = Database.database().reference(fromURL: "https://gameofchats-18146.firebaseio.com/")
            let usersReference = ref.child("users").child(uid)
            let values = ["name": name, "email": email]
            usersReference.updateChildValues(values, withCompletionBlock: { (error, ref) in
                
                if error != nil { print(error!); return }
                
                self?.dismiss(animated: true, completion: nil)
                print("Saved user successfully into Firebase db")
                
            })  
        }
    }
    
    var inputsCounteinerViewHeight: NSLayoutConstraint?
    var nameTextFieldHeightAnchor: NSLayoutConstraint?
    
    private func setupViews() {
        
        view.addSubview(inputsContainerView)
        _ = inputsContainerView.anchor(view.centerYAnchor, left: view.leftAnchor, right: view.rightAnchor, widthConstant: view.frame.width - 24)
        inputsCounteinerViewHeight = inputsContainerView.heightAnchor.constraint(equalToConstant: ConstantsValue.loginHeight * 3)
        inputsCounteinerViewHeight?.isActive = true
        
        view.addSubview(loginRegisterButton)
        _ = loginRegisterButton.anchor(inputsContainerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 10, leftConstant: 12, rightConstant: 12, widthConstant: ConstantsValue.loginHeight)
        
        inputsContainerView.addSubview(nameTextField)
        _ = nameTextField.anchor(inputsContainerView.topAnchor, left: inputsContainerView.leftAnchor, bottom: nil, right: inputsContainerView.rightAnchor, leftConstant: 12)
            nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalToConstant: ConstantsValue.loginHeight)
            nameTextFieldHeightAnchor?.isActive = true
        
        inputsContainerView.addSubview(nameSeparatorView)
        _ = nameSeparatorView.anchor(nameTextField.bottomAnchor, left: inputsContainerView.leftAnchor, bottom: nil, right: inputsContainerView.rightAnchor, heightConstant: 1)
        
        inputsContainerView.addSubview(emailTextField)
        _ = emailTextField.anchor(nameTextField.bottomAnchor, left: inputsContainerView.leftAnchor, bottom: nil, right: inputsContainerView.rightAnchor, topConstant: 1, leftConstant: 12, heightConstant: ConstantsValue.loginHeight)
        
        inputsContainerView.addSubview(emailSeparatorView)
        _ = emailSeparatorView.anchor(emailTextField.bottomAnchor, left: inputsContainerView.leftAnchor, bottom: nil, right: inputsContainerView.rightAnchor, heightConstant: 1)
        
        inputsContainerView.addSubview(passwordTextField)
        _ = passwordTextField.anchor(emailTextField.bottomAnchor, left: inputsContainerView.leftAnchor, bottom: nil, right: inputsContainerView.rightAnchor, topConstant: 1, leftConstant: 12, heightConstant: ConstantsValue.loginHeight)
        
        inputsContainerView.addSubview(passwordSeparatorView)
        _ = passwordSeparatorView.anchor(passwordTextField.bottomAnchor, left: inputsContainerView.leftAnchor, bottom: nil, right: inputsContainerView.rightAnchor, heightConstant: 1)
        
        view.addSubview(loginRegisterSegmentControl)
        _ = loginRegisterSegmentControl.anchor(nil, left: view.leftAnchor, bottom: inputsContainerView.topAnchor, right: view.rightAnchor, leftConstant: 12, bottomConstant: 10, rightConstant: 12, heightConstant: 30)
        
        view.addSubview(profileImageView)
        _ = profileImageView.anchor(view.topAnchor, left: view.leftAnchor, bottom: loginRegisterSegmentControl.topAnchor, right: view.rightAnchor, topConstant: 18, leftConstant: 50, bottomConstant: 8, rightConstant: 50)
        
    }
    
}

struct ConstantsValue {
    static let backgroundBlueColor = #colorLiteral(red: 0.2586793801, green: 0.3642121077, blue: 0.5262333439, alpha: 1)
    static let loginHeight: CGFloat = 50
}
