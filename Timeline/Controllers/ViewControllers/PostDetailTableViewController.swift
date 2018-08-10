//
//  PostDetailTableViewController.swift
//  Timeline
//
//  Created by Zachary Frew on 8/7/18.
//  Copyright © 2018 Zachary Frew. All rights reserved.
//

import UIKit

class PostDetailTableViewController: UITableViewController {

    // MARK: - Outlets
    @IBOutlet weak var postIV: UIImageView!
    
    // MARK: - Instance Properties
    var post: Post? {
        didSet {
            updateViews()
        }
    }
    
    // MARK: - LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        
        let notification = NotificationCenter.default
        notification.addObserver(self, selector: #selector(fetchComments), name: PostController.PostCommentsChangedNotification, object: nil)
        tableView.tableHeaderView?.autoresizingMask = []
        
        guard let post = post else { return }
        PostController.shared.fetchCommentsFor(post: post) { (_) in }
    }

    // MARK: - Actions
    @IBAction func commentButtonTapped(_ sender: UIButton) {
        presentAlertController()
    }
    
    @IBAction func shareButtonTapped(_ sender: UIButton) {
    
    }
    
    @IBAction func followPostButtonTapped(_ sender: UIButton) {
    
    }
    
    // MARK: - Instance Methods
    func updateViews() {
        guard let post = post else { return }
        
        DispatchQueue.main.async {
            self.postIV.image = post.photo
            self.tableView.reloadData()
        }
    }
    
    @objc func fetchComments() {
        guard let post = post else { return }
        PostController.shared.fetchCommentsFor(post: post, completion: { _ in })
    }
    
    func presentAlertController() {
        var commentText: UITextField?
        let alertController = UIAlertController(title: nil, message: "Post a comment!", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter comment..."
            commentText = textField
        }
        
        let postAction = UIAlertAction(title: "Post", style: .default) { (_) in
            guard let post = self.post,
                let text = commentText?.text, !text.isEmpty, text != " " else { return }
            PostController.shared.addComment(toPost: post, withText: text) { _ in

            }
        }
        
        alertController.addAction(postAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - TableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return post?.comments.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath)
        let comment = post?.comments[indexPath.row]
        cell.textLabel?.text = comment?.text
        cell.detailTextLabel?.text = comment?.timestamp.stringValue()
        return cell
    }


}
