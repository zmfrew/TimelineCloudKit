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
    
    // MARK: - Initializers
    init() {
        subscribeToNewPosts { (success, error) in
            if success {
                print("Subscribed to new posts.")
            }
        }
    }
    
    // MARK: - Methods
    func createPostWith(image: UIImage, andCaption text: String, completion: @escaping (Post?) -> Void) {
        guard let imageData = UIImageJPEGRepresentation(image, 1) else { return }
        
        let post = Post(photoData: imageData)
        let postRecord = post.cloudKitRecord
        
        posts.insert(post, at: 0)
        
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
        
        completion(post)
    }
 
    func addComment(toPost post: Post, withText text: String, completion: @escaping (Comment?) -> Void = {_ in }) -> Comment {
        let comment = Comment(text: text, post: post)
        let commentRecord = comment.cloudKitRecord
        
        post.comments.insert(comment, at: 0)

        CloudKitManager.shared.saveRecord(commentRecord, database: publicDB) { (record, error) in
            if let error = error {
                print("Error occurred saving comment: \(error.localizedDescription).")
                completion(nil)
                return
            }
            
            comment.cloudKitRecordID = record?.recordID
            completion(comment)
        }
        return comment
    }

    func fetchCommentsFor(post: Post, completion: @escaping (() -> Void) = {}) {
        let postReference = CKReference(record: post.cloudKitRecord, action: .deleteSelf)
        let sortDescriptor = NSSortDescriptor(key: Comment.TimestampKey, ascending: false)
        let predicate = NSPredicate(format: "%K == %@", Comment.PostKey, postReference)
        
        CloudKitManager.shared.fetchRecordsOfType(Comment.TypeKey, predicate: predicate, database: publicDB, sortDescriptors: [sortDescriptor]) { (records, error) in
            if let error = error {
                print("Error occurred fetching comments: \(error.localizedDescription).")
                completion()
                return
            }
            
            guard let records = records else { completion() ; return }
            
            let comments = records.compactMap { Comment(ckRecord: $0) }
            post.comments = comments
            completion()
        }
    }
    
    func fetchPosts(completion: @escaping (Bool) -> Void = {_ in }) {
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
                self.fetchCommentsFor(post: post, completion: { 
                    dispatchGroup.leave()
                })
            }
            
            dispatchGroup.notify(queue: DispatchQueue.main, execute: {
                self.posts = posts
                completion(true)                
            })
        }
    }
    
    // MARK: - Subscriptions
    func subscribeToNewPosts(completion: @escaping (_ success: Bool, _ error: Error?)-> Void) {
        let predicate = NSPredicate(value: true)
        
        CloudKitManager.shared.subscribe(Post.TypeKey, predicate: predicate, database: publicDB, subscriptionID: "allPosts", contentAvailable: true, options: .firesOnRecordCreation) { (subscription, error) in
            if let error = error {
                print("Error occurred subscribing to new posts: \(error.localizedDescription).")
                completion(false, nil)
                return
            }
            
            let success = subscription != nil
            completion(success, error)
        }
    }
    
    func addSubscriptionTo(commentsForPost post: Post, alertBody: String, completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        guard let recordID = post.cloudKitRecordID else { completion(false,nil) ; return }
        
        let predicate = NSPredicate(format: "post == %@", recordID)
        
        CloudKitManager.shared.subscribe(Comment.TypeKey, predicate: predicate, database: publicDB, subscriptionID: recordID.recordName, contentAvailable: true, alertBody: alertBody, desiredKeys: [Comment.TextKey, Comment.PostKey], options: .firesOnRecordCreation) { (subscription, error) in
            if let error = error {
                print("Error occurred subscribing to comments on post: \(error.localizedDescription).")
                completion(false, nil)
                return
            }
            
            let success = subscription != nil
            completion(success, error)
        }
    }
    
    func removeSubscriptionTo(commentsForPost post: Post, completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        guard let subscriptionID = post.cloudKitRecordID?.recordName else { completion(true, nil) ; return }
        
        CloudKitManager.shared.unsubscribe(subscriptionID, database: publicDB) { (subscriptionID, error) in
            if let error = error {
                print("Error occurred unsubscribing from comments on post: \(error.localizedDescription).")
                completion(false, nil)
                return
            } else {
                let success = subscriptionID != nil
                completion(success, error)
            }
        }
    }
    
    func checkSubscriptionTo(commentsForPost post: Post, completion: @escaping ((_ subscribed: Bool) -> Void) = {_ in}) {
        guard let subscriptionID = post.cloudKitRecordID?.recordName else { completion(false) ; return }
        
        CloudKitManager.shared.fetchSubscription(subscriptionID, database: publicDB) { (subscription, error) in
            let subscriptionStatus = subscription != nil
            completion(subscriptionStatus)
        }
    }
    
    func toggleSubscriptionTo(commentsForPost post: Post,
                              completion: @escaping ((_ success: Bool, _ isSubscribed: Bool, _ error: Error?) -> Void) = { _,_,_ in }) {
        
        guard let subscriptionID = post.cloudKitRecordID?.recordName else {
            completion(false, false, nil)
            return
        }
        
        CloudKitManager.shared.fetchSubscription(subscriptionID, database: publicDB) { (subscription, error) in
            
            if subscription != nil {
                self.removeSubscriptionTo(commentsForPost: post) { (success, error) in
                    completion(success, false, error)
                }
            } else {
                self.addSubscriptionTo(commentsForPost: post, alertBody: "Someone commented on a post you follow! 👍") { (success, error) in
                    completion(success, true, error)
                }
            }
        }
    }

}

