//
//  ViewController.swift
//  GameOfChats
//
//  Created by Tarasenko Jurik on 22.06.2018.
//  Copyright © 2018 Tarasenko Jurik. All rights reserved.
//

import UIKit
import FirebaseDatabase


class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        

        let ref = Database.database().reference()

        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Loggout", style: .plain, target: self, action: #selector(handleLoggout))
        
    }
    
    @objc private func handleLoggout() {
        let loginController = LoginController()
        present(loginController, animated: true, completion: nil)
    }
    
}//end

