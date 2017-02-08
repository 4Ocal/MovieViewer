//
//  DetailViewController.swift
//  MovieViewer
//
//  Created by Calvin Chu on 2/5/17.
//  Copyright © 2017 Calvin Chu. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var infoView: UIView!
    
    var movie: NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: infoView.frame.origin.y + infoView.frame.size.height)
        
        let title = movie["title"] as? String
        titleLabel.text = title
        
        let overview = movie["overview"]
        overviewLabel.text = overview as? String
        
        overviewLabel.sizeToFit()
        
        if let posterPath = movie["poster_path"] as? String {
            let baseUrl = "https://image.tmdb.org/t/p/"
            let lowRes = "w45"
            let highRes = "original"
            let lowResUrl = URL(string: baseUrl + lowRes + posterPath)!
            let highResUrl = URL(string: baseUrl + highRes + posterPath)!
            let lowResRequest = URLRequest(url: lowResUrl)
            let highResRequest = URLRequest(url: highResUrl)
            self.posterImageView.setImageWith(
                lowResRequest,
                placeholderImage: nil,
                success: { (lowResRequest, lowResResponse, lowResPoster) -> Void in
                    
                    self.posterImageView.alpha = 0.0
                    self.posterImageView.image = lowResPoster;
                    
                    UIView.animate(withDuration: 0.3, animations: { () -> Void in
                        
                        self.posterImageView.alpha = 1.0
                        
                    }, completion: { (sucess) -> Void in
                        
                        self.posterImageView.setImageWith(
                            highResRequest,
                            placeholderImage: nil,
                            success: { (highResRequest, highResResponse, highResPoster) -> Void in
                                
                                self.posterImageView.image = highResPoster;
                                
                        },
                            failure: { (request, response, error) -> Void in
                                
                        })
                    })
            },
                failure: { (request, response, error) -> Void in
                    
            })
            
        }
        
        print(movie)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
    }
    */

}
