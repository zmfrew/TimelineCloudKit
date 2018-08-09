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
    
    // MARK: - Constants
    static let PostsChangedNotification = Notification.Name("PostsChangedNotification")
    static let PostCommentsChangedNotification = Notification.Name("PostCommentsChangedNotification")
    
    // MARK: - Instance Properties
    var posts: [Post] = [] {
        didSet {
            DispatchQueue.main.async {
                let notification = NotificationCenter.default
                notification.post(name: PostController.PostsChangedNotification, object: self)
            }
        }
    }
    
    // MARK: - CloudKit Properties
    let publicDB = CKContainer.default().publicCloudDatabase
    
    // MARK: - Methods
    func createPostWith(image: UIImage, andCaption text: String, completion: @escaping (Post?) -> Void) {
        guard let imageData = UIImageJPEGRepresentation(image, 1) else { return }
        
        let post = Post(photoData: imageData)
        let postRecord = post.cloudKitRecord
        
        let comment = addComment(toPost: post, withText: text)
        
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
 
    func addComment(toPost post: Post, withText text: String, completion: @escaping (Comment?) -> Void = {_ in }) -> Comment {
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
        return comment
    }

    func fetchCommentsFor(post: Post, completion: @escaping (Bool) -> Void) {
        let postReference = CKReference(record: post.cloudKitRecord, action: .deleteSelf)
        let sortDescriptor = NSSortDescriptor(key: Comment.TimestampKey, ascending: false)
        let predicate = NSPredicate(format: "%K == %@", Comment.PostKey, postReference)
        
        CloudKitManager.shared.fetchRecordsOfType(Comment.TypeKey, predicate: predicate, database: publicDB, sortDescriptors: [sortDescriptor]) { (records, error) in
            if let error = error {
                print("Error occurred fetching comments: \(error.localizedDescription).")
                completion(false)
                return
            }
            
            guard let records = records else { completion(false) ; return }
            
            let comments = records.compactMap { Comment(ckRecord: $0) }
            post.comments = comments
            completion(true)
        }
    }
    
    func fetchPosts(completion: @escaping(Bool) -> Void = {_ in }) {
        let sortDescriptor = NSSortDescriptor(key: Post.TimestampKey, ascending: false)
        
        CloudKitManager.shared.fetchRecordsOfType(Post.TypeKey, database: publicDB, sortDescriptors: [sortDescriptor]) { (records, error) in
            if let error = error {
                print("Error occurred fetching posts: \(error.localizedDescription).")
                completion(false)
                return
            }
            
            guard let records = records else { completion(false) ; return }
            
            let posts = records.compactMap { Post(record: $0) }
            
            let dispatchGroup = DispatchGroup()
            
            for post in posts {
                dispatchGroup.enter()
                self.fetchCommentsFor(post: post, completion: { (_) in
                    dispatchGroup.leave()
                })
            }
            
            dispatchGroup.notify(queue: DispatchQueue.main, execute: {
                self.posts = posts
                completion(true)                
            })
        }
    }
    
}

