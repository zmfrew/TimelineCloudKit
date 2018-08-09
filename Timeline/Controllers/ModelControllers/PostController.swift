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
    
    // MARK: - CloudKit Properties
    let publicDB = CKContainer.default().publicCloudDatabase
    
    // MARK: - Methods
    func createPostWith(image: UIImage, andCaption text: String, completion: @escaping (Post?) -> Void) {
        guard let imageData = UIImageJPEGRepresentation(image, 1) else { return }
        
        let post = Post(photoData: imageData)
        let postRecord = post.cloudKitRecord
        
        CloudKitManager.shared.saveRecord(postRecord, database: publicDB) { (record, error) in
            if let error = error {
                print("Error occurred saving post: \(error.localizedDescription).")
                completion(nil)
                return
            }
            
            guard let record = record else { completion(nil) ; return }
            
            post.cloudKitRecordID = record.recordID
            completion(post)
        }
        
        let comment = Comment(text: text, post: post)
        let commentRecord = comment.cloudKitRecord
        
        CloudKitManager.shared.saveRecord(commentRecord, database: publicDB) { (record, error) in
            if let error = error {
                print("Error occurred saving comment to post: \(error.localizedDescription).")
                completion(nil)
                return
            }
            
            guard let record = record else { completion(nil) ; return }
            
            comment.cloudKitRecordID = record.recordID
            completion(post)
        }
        
        posts.append(post)
        completion(post)
    }
 
    func addComment(toPost post: Post, withText text: String, completion: @escaping (Comment?) -> Void) {
        let comment = Comment(text: text, post: post)
        let commentRecord = comment.cloudKitRecord
        
        CloudKitManager.shared.saveRecord(commentRecord, database: publicDB) { (record, error) in
            if let error = error {
                print("Error occurred saving comment: \(error.localizedDescription).")
                completion(nil)
                return
            }
            
            comment.cloudKitRecordID = record?.recordID
            post.comments.append(comment)
            completion(comment)
        }
    }
    
    
}

