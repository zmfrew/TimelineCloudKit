//
//  PostTableViewCell.swift
//  Timeline
//
//  Created by Zachary Frew on 8/7/18.
//  Copyright © 2018 Zachary Frew. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var postIV: UIImageView!
    
    // MARK: - Instance Properties
    var post: Post? {
        didSet {
            updateViews()
        }
    }
    
    // MARK: - Methods
    func updateViews() {
        guard let post = post else { return }
        DispatchQueue.main.async {
            self.postIV.image = post.photo            
        }
    }
    
}
