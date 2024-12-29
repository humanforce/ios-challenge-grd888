//
//  Dictionary+Extensions.swift
//  Humanforce iOS Engineering Challenge
//
//  Created by Greg Delgado on 12/25/24.
//

import Foundation

extension Dictionary where Key == String, Value == String {
    func asQueryItems() -> [URLQueryItem] {
        return self.map { URLQueryItem(name: $0.key, value: $0.value) }
    }
}
