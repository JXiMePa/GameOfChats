//
//  LoginController.swift
//  GameOfChats
//
//  Created by Tarasenko Jurik on 22.06.2018.
//  Copyright © 2018 Tarasenko Jurik. All rights reserved.
//

import UIKit

final class LoginController: UIViewController {
    
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 25
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.image = #imageLiteral(resourceName: "gameofthrones_splash")
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
    
    private let loginRegisterButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = #colorLiteral(red: 0.4331629546, green: 0.6098792745, blue: 0.8811865482, alpha: 1)
        button.setTitle("Register", for: .normal)
        button.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 28)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
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
        return textFild
    }()
    private let passwordSeparatorView : UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = ConstantsValue.backgroundBlueColor
        
        setupViews()
        
        
    }
    
    private func setupViews() {
        
        view.addSubview(inputsContainerView)
        inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputsContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1, constant: -24).isActive = true
        inputsContainerView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        view.addSubview(loginRegisterButton)
        _ = loginRegisterButton.anchor(inputsContainerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 10, leftConstant: 12, bottomConstant: 0, rightConstant: 12, widthConstant: ConstantsValue.loginRegisterButtonHeight, heightConstant: 0)
        
        inputsContainerView.addSubview(nameTextField)
       _ = nameTextField.anchor(inputsContainerView.topAnchor, left: inputsContainerView.leftAnchor, bottom: nil, right: inputsContainerView.rightAnchor, topConstant: 0, leftConstant: 12, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
           nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3).isActive = true
        
        inputsContainerView.addSubview(nameSeparatorView)
        _ = nameSeparatorView.anchor(nameTextField.bottomAnchor, left: inputsContainerView.leftAnchor, bottom: nil, right: inputsContainerView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 1)

        inputsContainerView.addSubview(emailTextField)
        _ = emailTextField.anchor(nameTextField.bottomAnchor, left: inputsContainerView.leftAnchor, bottom: nil, right: inputsContainerView.rightAnchor, topConstant: 1, leftConstant: 12, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3).isActive = true
        
        inputsContainerView.addSubview(emailSeparatorView)
        _ = emailSeparatorView.anchor(emailTextField.bottomAnchor, left: inputsContainerView.leftAnchor, bottom: nil, right: inputsContainerView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 1)

        inputsContainerView.addSubview(passwordTextField)
        _ = passwordTextField.anchor(emailTextField.bottomAnchor, left: inputsContainerView.leftAnchor, bottom: nil, right: inputsContainerView.rightAnchor, topConstant: 1, leftConstant: 12, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3).isActive = true
        
        inputsContainerView.addSubview(passwordSeparatorView)
        _ = passwordSeparatorView.anchor(passwordTextField.bottomAnchor, left: inputsContainerView.leftAnchor, bottom: nil, right: inputsContainerView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 1)
        
        view.addSubview(profileImageView)
        _ = profileImageView.anchor(view.topAnchor, left: view.leftAnchor, bottom: nameTextField.topAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 90, bottomConstant: -80, rightConstant: 10, widthConstant: 0, heightConstant: 0)

        
    }
}

struct ConstantsValue {
    static let backgroundBlueColor = #colorLiteral(red: 0.2586793801, green: 0.3642121077, blue: 0.5262333439, alpha: 1)
    static let loginRegisterButtonHeight: CGFloat = 70
}
