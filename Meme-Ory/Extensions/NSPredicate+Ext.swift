//
//  Ext+NSPredicate.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 30.11.2020.
//

import Foundation

extension NSPredicate {
    static var all = NSPredicate(format: "TRUEPREDICATE")
    static var none = NSPredicate(format: "FALSEPREDICATE")
}
