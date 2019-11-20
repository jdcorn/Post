//
//  PostListViewController.swift
//  Post
//
//  Created by jdcorn on 11/19/19.
//  Copyright © 2019 DevMtnStudent. All rights reserved.
//

import UIKit

class PostListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Properties
    /// Add postController property and set it to an instance of PostController ( set to to an instance of something usually means adding "()" after the controller name)
    let postController = PostController()
    
    /// Create variable called refreshControl and initialize it as UIRefreshControl
    var refreshControl = UIRefreshControl()

    // MARK: - Outlets
    @IBOutlet weak var postTableView: UITableView!
    
    // MARK: - View Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Assign this class as the table view's delegate and data source.
        postTableView.delegate = self
        postTableView.dataSource = self
        
        /// The length of each Post is variable. Support dynamic resizing cells so messages aren't truncated.
        postTableView.estimatedRowHeight = 45
        postTableView.rowHeight = UITableView.automaticDimension
        
        /// Setting up refresh control for tableView
        postTableView.refreshControl = refreshControl
        
        /// Add the @objc function from below, to the refresh control (view lifecycle)
        refreshControl.addTarget(self, action: #selector(refreshControlPulled), for: .valueChanged)
        
        /// Add fetchPosts function of the post controller to viewDidLoad
        postController.fetchPosts {
            self.reloadTableView()
        }
    }
    
    // MARK: - Action
    @IBAction func addPostButtonTapped(_ sender: UIBarButtonItem) {
        presentNewPostAlert()
    }
    
    // MARK: - Tableview data source
    /// Let the postController.posts.count determine how many rows will be displayed
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postController.posts.count
    }
    
    /// This will tell what is being displayed in the row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath)
        
        /// Defining post to be which ever row was selected by the user.
        let post = postController.posts[indexPath.row]
        
        /// Cell determines what will be placed inside the cell
        cell.textLabel?.text = post.text
        cell.detailTextLabel?.text = "\(post.username) - \(Date(timeIntervalSince1970: post.timestamp))"
        
        /// Returns cell
        return cell
    }
    
    // MARK: - Helper functions
    /// Create new function with @objc in front, nameded refreshControlPulled
    @objc func refreshControlPulled() {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        /// Make a call to the postController's fetchPost function
        postController.fetchPosts {
            self.reloadTableView()
            
            /// Tell UIRefreshControl to end refreshing when the fetchPosts is complete.
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    /// Write a presentNewPostAlert() function that initializes a UIAlertController
    func presentNewPostAlert() {
        let newPostAlertController = UIAlertController(title: "New Post", message: nil, preferredStyle: .alert)
        
        /// Add a usernameTextField and a messageTextField to the alert controller
        var usernameTextField = UITextField()
        newPostAlertController.addTextField { (usernameTF) in
            usernameTF.placeholder = "Enter username..."
            usernameTextField = usernameTF
        }
        
        /// Adding message textField
        var messageTextField = UITextField()
        newPostAlertController.addTextField { (messageTF) in
            messageTF.placeholder = "Enter message..."
            messageTextField = messageTF
        }
        
        /// Add a Post alert action that guards for username and message text
        /// Also uses the postController to add a post with the username and text
        let postAction = UIAlertAction(title: "Post", style: .default) { (postAction) in
            
            /// guarding against an empty name and message
            guard let username = usernameTextField.text, !username.isEmpty,
                let text = messageTextField.text, !text.isEmpty else {
                    return
            }
            self.postController.addNewPostWith(username: username, text: text, completion: {
                self.reloadTableView()
            })
        }
        
        /// Create a cancel alert action, add both alert actions to the alert controller, and then present the alert controller.
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        newPostAlertController.addAction(postAction)
        newPostAlertController.addAction(cancelAction)
        
        self.present(newPostAlertController, animated: true, completion: nil)
        }
    
    /// Present missing data error
    func presentErrorAlert() {
        let alertController = UIAlertController(title: "Missing info", message: "Make sure both text fields are filled out", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    /// func that we'll call in serveral places to reload the table view on the main thread after fetchPosts is called and the completion closure runs
    func reloadTableView() {
        
        /// Anything View related has to run on the main thread
        DispatchQueue.main.async {
        
            /// Adding networkActivityIndicator to the reloadView function
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.postTableView.reloadData()
        }
    }
    
} // Class end

/// Add an extension of PostListviewcontroller to the bottom of the file
extension PostListViewController {
    
    /// Add and implement the tableView(_:willDisplay:forRowAt:) function
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        /// Check if the indexPath.row of the cell parameter is greater than or equal to the number of posts currently loaded - 1 on the post controller
        if indexPath.row >= postController.posts.count - 1 {
            
            /// If so, call the fetch Posts function with reset set to false
            postController.fetchPosts(reset: false) {
                
                /// In the completion closure, reload the table view
                self.reloadTableView()
            }
        }
    }
}
