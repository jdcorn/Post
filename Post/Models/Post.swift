//
//  Post.swift
//  Post
//
//  Created by jdcorn on 11/19/19.
//  Copyright © 2019 DevMtnStudent. All rights reserved.
//

import Foundation

// Create the Post model
struct Post: Codable {
    
    // Create properties
    let text: String
    let timestamp: TimeInterval
    let username: String
    
    // Memberwise Initializer
    init(username: String, text: String, timestamp: TimeInterval = Date().timeIntervalSince1970) {
        self.username = username
        self.text = text
        self.timestamp = timestamp
    }
}
