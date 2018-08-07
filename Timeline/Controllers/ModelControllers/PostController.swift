//
//  PostController.swift
//  Timeline
//
//  Created by Zachary Frew on 8/7/18.
//  Copyright © 2018 Zachary Frew. All rights reserved.
//

import Foundation
import CloudKit

class PostController {
    
    // MARK: - Singleton
    static let shared = PostController()
    
    // MARK: - Properties
    var posts: [Post] = []
    
    // MARK: - Methods
    func addComment(toPost: Post, withText text: String, completion: @escaping (_ success: Bool) -> Comment) {
        
    }
    
}
