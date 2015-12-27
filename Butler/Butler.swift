//
//  Butler.swift
//  Butler
//
//  Created by Nick O'Neill on 12/9/15.
//  Copyright © 2015 922am Burrito. All rights reserved.
//

import Foundation

class Butler {
    // basic test for valid email string
    class func emailValid(email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)

        return emailTest.evaluateWithObject(email)
    }
}