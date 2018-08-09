//
//  Comment.swift
//  Timeline
//
//  Created by Zachary Frew on 8/7/18.
//  Copyright © 2018 Zachary Frew. All rights reserved.
//

import Foundation
import CloudKit

class Comment {
    
    // MARK: - Properties
    let text: String
    let timestamp: Date
    let post: Post
    
    // MARK: - Initializers
    init(text: String, timestamp: Date = Date(), post: Post) {
        self.text = text
        self.timestamp = timestamp
        self.post = post
    }
    
}

extension Comment: SearchableRecord {
    
    func matches(searchTerm: String) -> Bool {
        return text.lowercased().contains(searchTerm)
    }
    
}
