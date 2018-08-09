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
    
    // MARK: - Constants
    static let TypeKey = "Comment"
    fileprivate static let TextKey = "text"
    static let TimestampKey = "timestamp"
    static let PostKey = "post"
    
    // MARK: - Properties
    let text: String
    let timestamp: Date
    let post: Post
    
    // MARK: - CloudKit Properties
    var cloudKitRecordID: CKRecordID?
    var cloudKitRecord: CKRecord {
        let postRecordID = post.cloudKitRecordID ?? post.cloudKitRecord.recordID
        let recordID = cloudKitRecordID ?? CKRecordID(recordName: UUID().uuidString)
        let record = CKRecord(recordType: Comment.TypeKey, recordID: recordID)
        record[Comment.TextKey] = text as CKRecordValue?
        record[Comment.TimestampKey] = timestamp as CKRecordValue?
        record[Comment.PostKey] = CKReference(recordID: postRecordID, action: .deleteSelf)
        return record
    }
    
    // MARK: - Initializers
    init(text: String, timestamp: Date = Date(), post: Post) {
        self.text = text
        self.timestamp = timestamp
        self.post = post
    }
    
    init?(ckRecord: CKRecord) {
        guard let text = ckRecord[Comment.TextKey] as? String,
            let timestamp = ckRecord[Comment.TimestampKey] as? Date,
            let post = ckRecord[Comment.PostKey] as? Post else { return nil }
        
        self.text = text
        self.timestamp = timestamp
        self.post = post
        cloudKitRecordID = ckRecord.recordID
    }
    
}

extension Comment: SearchableRecord {
    
    func matches(searchTerm: String) -> Bool {
        return text.lowercased().contains(searchTerm)
    }
    
}
