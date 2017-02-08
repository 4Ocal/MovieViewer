//
//  MoviesViewController.swift
//  MovieViewer
//
//  Created by Calvin Chu on 1/29/17.
//  Copyright © 2017 Calvin Chu. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UICollectionViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var networkErrorView: UIView!
    @IBOutlet weak var networkErrorText: UITextField!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var movies: [NSDictionary]?
    var filtered: [NSDictionary]?
    var endpoint: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        collectionView.dataSource = self
        searchBar.delegate = self

        
        // initialize a UIRefreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        // add refresh control to table view
        collectionView.insertSubview(refreshControl, at: 0)
        
        // network error
        networkErrorText.leftViewMode = UITextFieldViewMode.always
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        let image = UIImage(named: "Error")
        imageView.image = image
        networkErrorText.leftView = imageView
        
        request()
        
        
    }
    
    func request() {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(endpoint!)?api_key=\(apiKey)")
        //let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = URLRequest(url: url!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        
        // display HUD before request
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if error != nil {
                self.collectionView.isHidden = true
                self.networkErrorView.isHidden = false
            } else {
                self.collectionView.isHidden = false
                self.networkErrorView.isHidden = true
            }
            
            // hide HUD when responce is received
            MBProgressHUD.hide(for: self.view, animated: true)
            
            // remainder of response handling
            if let data = data {
                if let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    //print(dataDictionary)
                    
                    self.movies = (dataDictionary["results"] as! [NSDictionary])
                    self.filtered = self.movies
                    self.collectionView.reloadData()
                }
            }
        }
        task.resume()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let filtered = filtered {
            return filtered.count
        } else {
            return 0
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCell", for: indexPath) as! MovieCell
        let movie = filtered![indexPath.row]
        if let posterPath = movie["poster_path"] as? String {
            let baseUrl = "https://image.tmdb.org/t/p/"
            let size = "w342"
            let posterUrl = URL(string: baseUrl + size + posterPath)!
            let posterRequest = URLRequest(url: posterUrl)
 
            cell.posterView.setImageWith(
                posterRequest,
                placeholderImage: nil,
                success: { (posterRequest, posterResponse, poster) -> Void in
                    
                    // posterResponse will be nill if the image is cached
                    if posterResponse != nil {
                        print("Image was NOT cached, fade in image")
                        cell.posterView.alpha = 0.0
                        cell.posterView.image = poster
                        UIView.animate(withDuration: 0.3, animations: { () -> Void in
                            cell.posterView.alpha = 1.0
                        })
                    } else {
                        print("Image was cached so just update the image")
                        cell.posterView.image = poster
                    }
                },
                failure: { (posterRequest, posterResponse, poster) -> Void in
            })
            

        }

        //cell.selectionStyle = .None
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.lightGray
        cell.selectedBackgroundView = backgroundView
        
        //print("row \(indexPath.row)")
        return cell
    }
    
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        request()
        refreshControl.endRefreshing()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filtered = searchText.isEmpty ? movies : movies?.filter({(movie: NSDictionary) -> Bool in
            return (movie["title"] as! String).range(of: searchText, options: .caseInsensitive) != nil
        })
        collectionView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let cell = sender as! UICollectionViewCell
        let indexPath = collectionView.indexPath(for: cell)
        let movie = movies![indexPath!.row]
        
        let detailViewController = segue.destination as! DetailViewController
        detailViewController.movie = movie
        
        print("prepare for seque called")
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}

