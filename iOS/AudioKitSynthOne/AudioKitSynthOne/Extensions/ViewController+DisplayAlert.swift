//
//  UIViewController+DisplayAlertController.swift
//  RadioInformer
//
//  Created by Matthew Fecher on 5/1/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import UIKit

// *********************************************************
// MARK: - Display AlertViewController (Pop-up message)
// *********************************************************

extension UIViewController {
    
    func displayAlertController(_ title: String, message: String) {
        // Create and display alert box
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
}
