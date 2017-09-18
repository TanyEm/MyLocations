//
//  String + AddText.swift
//  MyLocations
//
//  Created by Tanya Tomchuk on 18/09/2017.
//  Copyright © 2017 Tanya Tomchuk. All rights reserved.
//

import Foundation

extension String {
    mutating func add(text: String?, separatedBy separator: String = "") {
        if let text = text {
            if !isEmpty {
                self += separator
            }
            self += text
        }
    }
}
