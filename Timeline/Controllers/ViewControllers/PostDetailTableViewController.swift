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
    @IBOutlet weak var followPostButton: UIButton!
    
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
        tableView.estimatedRowHeight = 40
        
        updateViews()

        let notification = NotificationCenter.default
        notification.addObserver(self, selector: #selector(fetchComments), name: PostController.PostCommentsChangedNotification, object: nil)
        
        guard let post = post else { return }
        PostController.shared.fetchCommentsFor(post: post)
    }

    // MARK: - Actions
    @IBAction func commentButtonTapped(_ sender: UIButton) {
        presentAlertController()
    }
    
    @IBAction func shareButtonTapped(_ sender: UIButton) {
    
    }
    
    @IBAction func followPostButtonTapped(_ sender: UIButton) {
        guard let post = post else { return }
        PostController.shared.toggleSubscriptionTo(commentsForPost: post) { (_, _, _) in
            self.updateViews()
        }
    }
    
    // MARK: - Instance Methods
    func updateViews() {
        guard let post = post else { return }
        
        DispatchQueue.main.async {
            self.postIV.image = post.photo
            self.tableView.reloadData()
        }
        
        PostController.shared.checkSubscriptionTo(commentsForPost: post) { (subscribed) in
            self.updatePostButton(with: subscribed)
        }
    }
    
    func updatePostButton(with status: Bool) {
        DispatchQueue.main.async {
            self.followPostButton.setTitle(status ? "Unfollow Post" : "Follow Post", for: .normal)
        }
    }
    
    @objc func fetchComments() {
        guard let post = post else { return }
        
        PostController.shared.fetchCommentsFor(post: post)
    }
    
    func presentAlertController() {
        let alertController = UIAlertController(title: "Add a comment!", message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter comment..."
        }
        
        let postAction = UIAlertAction(title: "Post", style: .default) { (_) in
            guard let post = self.post,
                let text = alertController.textFields?.first?.text,
                !text.isEmpty, text != " " else { return }
            
            PostController.shared.addComment(toPost: post, withText: text)
            DispatchQueue.main.async {
                self.resignFirstResponder()
                PostController.shared.fetchCommentsFor(post: post)
                self.tableView.reloadData()
            }
        }
        
        alertController.addAction(postAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func presentActivityViewController() {
        
        guard let photo = post?.photo,
            let comment = post?.comments.first else { return }
        
        let text = comment.text
        let activityViewController = UIActivityViewController(activityItems: [photo, text], applicationActivities: nil)
        
        present(activityViewController, animated: true, completion: nil)
    }
    
    // MARK: - TableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return post?.comments.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath)
        let comment = post?.comments[indexPath.row]
        cell.textLabel?.text = comment?.text
        cell.detailTextLabel?.text = comment?.timestamp.stringValue()
        return cell
    }


}
