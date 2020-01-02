//
//  ViewControllers.swift
//  Butler
//
//  Created by Nick O'Neill on 2/18/16.
//  Copyright © 2016 922am Burrito. All rights reserved.
//

import UIKit

extension UIViewController {
    public func showMessage(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
