//
//  Post.swift
//  Timeline
//
//  Created by Zachary Frew on 8/7/18.
//  Copyright © 2018 Zachary Frew. All rights reserved.
//

import UIKit
import CloudKit

class Post {
    
    // MARK: - Constant Keys
    static let TypeKey = "Post"
    fileprivate static let PhotoDataKey = "photoData"
    static let TimestampKey = "timestamp"
    fileprivate static let CommentsKey = "comments"
    
    // MARK: - Properties
    let photoData: Data?
    let timestamp: Date
    var comments: [Comment] {
        didSet {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: PostController.PostCommentsChangedNotification, object: self)
            }
        }
    }
    
    var photo: UIImage {
        guard let data = photoData, let image = UIImage(data: data) else { return UIImage(named: "photo")! }
        return image
    }
    
    // MARK: - CloudKit Properties
    var recordType: String {
        return "Post"
    }
    
    fileprivate var temporaryPhotoURL: URL {
        // Must write to temporary directory to be able to pass image file path url to CKAsset
        let temporaryDirectory = NSTemporaryDirectory()
        let temporaryDirectoryURL = URL(fileURLWithPath: temporaryDirectory)
        let fileURL = temporaryDirectoryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
        try? photoData?.write(to: fileURL, options: [.atomic])
        return fileURL
    }
    
    var cloudKitRecordID: CKRecordID?
    
    var cloudKitRecord: CKRecord {
        let recordID = cloudKitRecordID ?? CKRecordID(recordName: UUID().uuidString)
        let record = CKRecord(recordType: recordType, recordID: recordID)
        record[Post.TimestampKey] = timestamp as CKRecordValue?
        record[Post.PhotoDataKey] = CKAsset(fileURL: temporaryPhotoURL)
        return record
    }
    
    // MARK: - Initializers
    init(photoData: Data?, timestamp: Date = Date(), comments: [Comment] = []) {
        self.photoData = photoData
        self.timestamp = Date()
        self.comments = comments
    }
    
    convenience required init?(record: CKRecord) {
        guard let photoDataAsset = record[Post.PhotoDataKey] as? CKAsset,
            let timestamp = record.creationDate else { return nil }
        
        let photoData = try? Data(contentsOf: photoDataAsset.fileURL)
        self.init(photoData: photoData, timestamp: timestamp)
        cloudKitRecordID = record.recordID
    }
    
}

extension Post: SearchableRecord {
    
    func matches(searchTerm: String) -> Bool {
        let commentMatches = comments.filter { $0.text.contains(searchTerm) }
        return !commentMatches.isEmpty
    }
    
}
