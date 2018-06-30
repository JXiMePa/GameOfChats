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
    
   weak var messagesController: MessagesController?
    
    lazy var profileImageView: UIImageView = { //TODO: only for test not privat!
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 25
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.image = #imageLiteral(resourceName: "gameofthrones_splash")
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImage)))
        imageView.isUserInteractionEnabled = true
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
    
     let nameTextField: UITextField = { //TODO: only for test not privat!
        let textFild = UITextField()
        textFild.placeholder = "  Name"
        return textFild
    }()
    private let nameSeparatorView : UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        return view
    }()
    
     let emailTextField: UITextField = { //TODO: only for test not privat!
        let textFild = UITextField()
        textFild.placeholder = "  Email address"
        return textFild
    }()
    private let emailSeparatorView : UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        return view
    }()
    
     lazy var passwordTextField: UITextField = { //TODO: only for test not privat!
        let textFild = UITextField()
        textFild.delegate = self
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
        observeKeyboardNotifications()
    }
    
    //Key Board Observe
    private func observeKeyboardNotifications() { //Key Board Observer
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow), name: .UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: .UIKeyboardWillHide, object: nil)
    }
    
    @objc private func keyboardHide() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            
        }, completion: nil)
    }
    
    @objc private func keyboardShow() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.view.frame = CGRect(x: 0, y: -160, width: self.view.frame.width, height: self.view.frame.height)
            
        }, completion: nil)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        //TODO: maybe i will find better place later
         if UIDevice.current.orientation.isLandscape {
            profileImageView.contentMode = .scaleAspectFit
         } else {
            profileImageView.contentMode = .scaleAspectFill
        }
    }
    
    @objc private func handleLoginRegisterChange() {
        
        let title = loginRegisterSegmentControl.titleForSegment(at: loginRegisterSegmentControl.selectedSegmentIndex)
        
            loginRegisterButton.setTitle(title, for: .normal)
        //change hight inputContainerView
        
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
            print("Form is not Value")
            return }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (user, error) in
            if error != nil { print(error!)
                return }
            
            self?.messagesController?.fetchUserAndSetupNavBarTitle()
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
   private var inputsCounteinerViewHeight: NSLayoutConstraint?
   private var nameTextFieldHeightAnchor: NSLayoutConstraint?
    
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
extension LoginController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleLoginRegirter()
        return true
    }
}

struct ConstantsValue {
    
    static let backgroundBlueColor = #colorLiteral(red: 0.2586793801, green: 0.3642121077, blue: 0.5262333439, alpha: 1)
    static let loginHeight: CGFloat = 50
    static let messageRowsHight: CGFloat = 65
}
