//
//  Double+Extension.swift
//  Humanforce iOS Engineering Challenge
//
//  Created by Greg Delgado on 12/29/24.
//

import Foundation

extension Double {
    /// Rounds the Double value to the nearest integer.
    func roundedToInt() -> Int {
        return Int(self.rounded())
    }
}
