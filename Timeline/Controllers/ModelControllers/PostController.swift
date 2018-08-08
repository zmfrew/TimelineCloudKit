//
//  PostController.swift
//  Timeline
//
//  Created by Zachary Frew on 8/7/18.
//  Copyright © 2018 Zachary Frew. All rights reserved.
//

import UIKit
import CloudKit

class PostController {
    
    // MARK: - Singleton
    static let shared = PostController()
    
    // MARK: - Properties
    var posts: [Post] = []
    
    // MARK: - Methods
    func addComment(toPost post: Post, withText text: String, completion: @escaping (Comment?) -> Void) {
        let comment = Comment(text: text, post: post)
        post.comments.append(comment)
        completion(comment)
    }
    
    func createPostWith(image: UIImage, andCaption text: String, completion: @escaping (Post?) -> Void) {
        guard let imageData = UIImageJPEGRepresentation(image, 1) else { return }
        let post = Post(photoData: imageData)
        addComment(toPost: post, withText: text) { (_) in
            
        }
        posts.append(post)
        completion(post)
    }
 
}

