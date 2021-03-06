//
//  InputCoordinator.swift
//  Butler
//
//  Created by Nick O'Neill on 5/10/16.
//  Copyright © 2016 922am Burrito. All rights reserved.
//

import UIKit

public class InputCoordinator: NSObject {
    static func configureText(textField: UITextField) {
        textField.keyboardType = .ASCIICapable
        textField.autocorrectionType = .Yes
        textField.autocapitalizationType = .None
    }

    static func configureEmail(textField: UITextField) {
        textField.keyboardType = .EmailAddress
        textField.autocorrectionType = .No
        textField.autocapitalizationType = .None
    }

    static func configurePhone(textField: UITextField) {
        textField.keyboardType = .PhonePad
        textField.autocorrectionType = .No
        textField.autocapitalizationType = .None
    }

    static func configurePassword(textField: UITextField) {
        textField.keyboardType = .ASCIICapable
        textField.autocorrectionType = .No
        textField.autocapitalizationType = .None
        textField.secureTextEntry = true
    }

    var fields: [UITextField] = []
    var finishedBlock: (() -> ())?

    public func createInputFlow(view: UIView, completion: (() -> ())? = nil) {
        fields = []
        finishedBlock = completion

        for subview in view.subviews {
            if let subview = subview as? UITextField {
                fields.append(subview)
                subview.delegate = self
                subview.returnKeyType = .Next
            }
        }

        if let last = fields.last {
            last.returnKeyType = .Done
        }
    }

    public func firstResponder() -> UITextField? {
        for field in fields {
            if field.isFirstResponder() {
                return field
            }
        }

        return nil
    }
}

extension InputCoordinator: UITextFieldDelegate {
    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        guard let last = fields.last else {
            return true
        }

        textField.resignFirstResponder()

        if textField == last {
            if let finishedBlock = finishedBlock {
                finishedBlock()
            }
        } else if fields.contains(textField) {
            if let index = fields.indexOf(textField) {
                fields[index+1].becomeFirstResponder()
            }
        } else {
            // field not in fields array?
        }
        
        return true
    }
}