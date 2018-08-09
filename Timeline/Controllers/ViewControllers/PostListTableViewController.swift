//
//  PostListTableViewController.swift
//  Timeline
//
//  Created by Zachary Frew on 8/7/18.
//  Copyright © 2018 Zachary Frew. All rights reserved.
//

import UIKit

class PostListTableViewController: UITableViewController {
    
    // MARK: - Outlets
    
    // MARK: - Instance Properties
    var searchController: UISearchController?
    
    // MARK: - LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // MARK: - Actions
    
    // MARK: - TableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PostController.shared.posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as? PostTableViewCell else { return UITableViewCell() }
        let post = PostController.shared.posts[indexPath.row]
        cell.post = post
        return cell
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPostDetail" {
            guard let destinationVC = segue.destination as? PostDetailTableViewController, let indexPath = tableView.indexPathForSelectedRow else { return }
            let post = PostController.shared.posts[indexPath.row]
            destinationVC.post = post
        }
        
        if segue.identifier == "toPostDetailFromSearch" {
            guard let destinationVC = segue.destination as? PostDetailTableViewController,
                let sender = sender as? PostTableViewCell, let indexPath = (searchController?.searchResultsController as? SearchResultsTableViewController)?.tableView.indexPath(for: sender),
                let searchTerm = searchController?.searchBar.text, !searchTerm.isEmpty, searchTerm != " " else { return }
            
            let posts = PostController.shared.posts.filter { $0.matches(searchTerm: searchTerm) }
            let post = posts[indexPath.row]
            destinationVC.post = post
        }
        
    }
    
}

// MARK: - UISearchResultsUpdating Conformance
extension PostListTableViewController: UISearchResultsUpdating {
    
    // MARK: - Methods
    func setUpSearchController() {
        let resultsController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SearchResultsTableViewController")
        searchController = UISearchController(searchResultsController: resultsController)
        searchController?.searchResultsUpdater = self
        searchController?.searchBar.sizeToFit()
        searchController?.hidesNavigationBarDuringPresentation = true
        tableView.tableHeaderView = searchController?.searchBar
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let resultsViewController = searchController.searchResultsController as? SearchResultsTableViewController,
            let searchTerm = searchController.searchBar.text, !searchTerm.isEmpty, searchTerm != " " else { return }
        
        let posts = PostController.shared.posts
        let filteredPosts = posts.filter { $0.matches(searchTerm: searchTerm) }
        resultsViewController.resultsArray = filteredPosts
        resultsViewController.tableView.reloadData()
    }
    
    
}
