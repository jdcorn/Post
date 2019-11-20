//
//  PostController.swift
//  Post
//
//  Created by jdcorn on 11/19/19.
//  Copyright © 2019 DevMtnStudent. All rights reserved.
//

import Foundation

/// Creating the model controller class
class PostController {
    // MARK: - Default URL
    
    /// Add a constant base URL where we'll build other URL's off of
    let baseURL = URL(string: "https://devmtn-posts.firebaseio.com/posts")
    
    // MARK: - Properties
    /// Source of Truth
    var posts: [Post] = []
    
    // MARK: - URLRequest
    /// Fetch posts
    func fetchPosts(reset: Bool = true, completion: @escaping() -> Void) {
        
        /// Create an instance of URLSessionDataTask that will get the data at the endpoint URL.
        guard let unwrappedURL = baseURL else { completion(); return}
        
        let queryEndInterval = reset ? Date().timeIntervalSince1970 : posts.last?.timestamp ?? Date().timeIntervalSince1970
        
        /// Build a [String: String] Dictionary literal of the URL paramters you want to use
        let urlParameters = [
            /// Request posts be ordered by timestamp
            "orderBy" : "\"timestamp\"",
            /// end the list at the timestamp of the least recent post
            "endAt" : "\(queryEndInterval)",
            /// specify that you want thelast 15 posts
            "limitToLast" : "15",
        ]
        
        /// Create a constant called queryItems, We need to compactMap over the urlParamters, turning them into URLQueryItems.
        let queryItems = urlParameters.compactMap( {URLQueryItem(name: $0.key, value: $0.value )} )
        
        /// Creating a variable called urlComponents of type URLComponents
        var urlComponents = URLComponents(url: unwrappedURL, resolvingAgainstBaseURL: true)
        
        /// Set the urlComponents.queryItems to the queryItems we just created from the urlParamters
        urlComponents?.queryItems = queryItems
        
        /// Create a url constant. assign it the value returned from urlComponents
        guard let url = urlComponents?.url else { completion(); return }
        
        /// Create a constant which takes the unwrapped baseURL and appends a path extension of "json"
        /// Part 2, edit the getterEndpoint to append the extion url, not unwrappedURL
        let getterEndpoint = url.appendingPathExtension("json")
        print(getterEndpoint)
        
        /// Create an instance of URLRequest and give it the getterEndpoint
        var request = URLRequest(url: getterEndpoint)
        request.httpBody = nil
        request.httpMethod = "GET"
        
        /// Create an instance of URLSessionDataTask which will make the network call and call the completion closer with the 'Data?', 'URLResponse?', and 'Error?' results.
        let dataTask = URLSession.shared.dataTask(with: request) { (data, _, error) in
            
            /// First, check for an error, if there is an error then call completion, then return
            if let error = error {
                print(error.localizedDescription)
                completion()
                return
            }
            
            /// Unwrap data if there is any
            guard let data = data else { completion(); return }
            
            /// Create an instance of JSONDecoder
            let decoder = JSONDecoder()
            
            do {
                
                /// Call decode(from:) on the instance of the JSONDecoder. You will need to assign the return of the fucntion to a constant named postsDictionary.
                let postsDictionary = try decoder.decode([String:Post].self, from: data)
                
                /// Call compactMap on this dictionary, pulling out the Post from each key-value pair. assign the new array of posts to a variable named posts.
                var posts: [Post] = postsDictionary.compactMap({ $0.value })
                
                /// Sort the posts by timestamp in reverse chronological order (newest one first). Call sort on the posts array.
                posts.sort(by: {$0.timestamp > $1.timestamp })
                
                /// Now assign the array of sorted posts to self.posts and call completion ().
                if reset {
                    self.posts = posts
                } else {
                    self.posts.append(contentsOf: posts)
                }
                completion()
                
                /// Catch error, be sure to put in completion() like in the try block.
            } catch {
                print(error)
                completion()
                return
            }
        }
        dataTask.resume()
    }
    
    /// Add an addNewPostWith(username:text:completion:) function, make sure to add @escaping() -> Void as the "of type" of completion.
    func addNewPostWith(username: String, text: String, completion: @escaping() -> Void) {
        
        /// Initialize a Post object with the memberwise initializer
        let post = Post(username: username, text: text)
        
        /// Create a variable called postData of type Data, but don't give it a value.
        var postData: Data
        
        do {
            /// Create an instance of JSONEncoder
            let encoder = JSONEncoder()
            
            /// Call encode(value: Encodable) throws
            postData = try encoder.encode(post)
        } catch {
            print(error)
            completion()
            return
        }
        
        /// Unwrap the baseURL
        guard let unwrappedURL = baseURL else { completion(); return }
        
        /// Create a property 'postEndpoint' that will hold the unwrapped baseURL with a path extension appened to it
        let postEndpoint = unwrappedURL.appendingPathExtension("json")
        
        /// Create and instance of URLRequest and give it the postEndpoint.
        /// Dont forget to set the request's httpMethod -> "POST" and httpBody -> postData
        var urlRequest = URLRequest(url: postEndpoint)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = postData
        
        /// Create and run dataTask.resume() , a URLSession.shared.dataTask and handle the results
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, _, error) in
            if let error = error {
                completion()
                NSLog(error.localizedDescription)
                return
            }
            
            /// Unwrap the data returned from the dataTask and this time, also convert the data to a string
            guard let data = data,
                
                /// Using String(data: data, encoding: .utf8) to capture and print a readable representation of the returned data.
                let responseDataString = String(data: data, encoding: .utf8) else {
                    NSLog("Data is nil.")
                    completion()
                    return }
            
            NSLog(responseDataString)
            
            ///After posting to the API, call fetchPosts() to load the new posts objects from the server.
            self.fetchPosts {
                completion()
            }
        }
        dataTask.resume()
    }
} // Class end
