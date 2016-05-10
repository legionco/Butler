//
//  Butler.swift
//  Butler
//
//  Created by Nick O'Neill on 12/9/15.
//  Copyright © 2015 922am Burrito. All rights reserved.
//

import Foundation

//import Butler
//
//// this is a workaround to bring the extensions from Butler into
//// the rest of the project without having to declare `import Butler` everywhere
//typealias HelloButler = Butler

public class Butler {
    // basic test for valid email string
    public class func emailValid(email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)

        return emailTest.evaluateWithObject(email)
    }

    // easy to use delays
    public class func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
}