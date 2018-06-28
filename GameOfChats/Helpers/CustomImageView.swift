//
//  Extensions.swift
//  GameOfChats
//
//  Created by Tarasenko Jurik on 26.06.2018.
//  Copyright © 2018 Tarasenko Jurik. All rights reserved.
//

import UIKit


var imageCache = NSCache<AnyObject, UIImage>()

final class CustomImageView: UIImageView {
    // too many Memory in use, only for test!
    
   private var imageURL: URL?
    
   private let activityIndicator = UIActivityIndicatorView()
    
    func loadImageWithUrl(_ urlString: String) {
        
        guard let url = URL(string: urlString) else { return }
        
        // setup activityIndicator...
        activityIndicator.color = .blue
        
        addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        imageURL = url
        image = nil
        activityIndicator.startAnimating()
        
        // retrieves image if already available in cache
        if let imageFromCache = imageCache.object(forKey: urlString as AnyObject) {
            self.image = imageFromCache
            activityIndicator.stopAnimating()
            
        } else {
            
            // image does not available in cache.. so retrieving it from url...
            URLSession.shared.dataTask(with: url, completionHandler: { [weak self] (data, response, error) in
                
                if error != nil {
                    print(error as Any)
                    // self?.activityIndicator.stopAnimating()
                    return
                }
                
                DispatchQueue.main.async(execute: {
                    
                    if let unwrappedData = data, let imageToCache = UIImage(data: unwrappedData) {
                        
                        if self?.imageURL == url {
                            self?.image = imageToCache
                        }
                        imageCache.setObject(imageToCache, forKey: urlString as AnyObject)
                    }
                    self?.activityIndicator.stopAnimating()
                })
            }).resume()
        }
    }
}
