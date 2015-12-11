//
//  Operators.swift
//  Butler
//
//  Created by Nick O'Neill on 12/11/15.
//  Copyright © 2015 922am Burrito. All rights reserved.
//

import Foundation

infix operator ??= { associativity right precedence 90 assignment } // matches other assignment operators

/// If `lhs` is `nil`, assigns to it the value of `rhs`.
func ??=<T>(inout lhs: T?, @autoclosure rhs: () -> T) {
    lhs = lhs ?? rhs()
}