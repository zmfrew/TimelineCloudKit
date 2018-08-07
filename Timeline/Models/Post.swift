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
    
    // MARK: - Properties
    let photoData: Data?
    let timestamp: Date
    var comments: [Comment]
    var photo: UIImage {
        guard let data = photoData, let image = UIImage(data: data) else { return UIImage(named: "photo")! }
        return image
    }
    
    // MARK: - Initializers
    init(photoData: Data?, timestamp: Date = Date(), comments: [Comment] = []) {
        self.photoData = photoData
        self.timestamp = Date()
        self.comments = comments
    }
    
}
