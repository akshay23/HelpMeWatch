//
//  Movie.swift
//  HelpMeWatch
//
//  Created by Akshay Bharath on 3/14/16.
//  Copyright © 2016 Akshay Bharath. All rights reserved.
//

import Foundation
import SwiftyJSON

class Movie: NSObject {
  
  let imagePrefix = "https://image.tmdb.org/t/p/w500"
  var posterImage: PhotoInfo?
  var movieName: String?
  
  init(movieDetails: JSON) {
    if let posterPath = movieDetails["poster_path"].string {
      let posterImageURL = NSURL(string: "\(imagePrefix)\(posterPath)")
      print("Poster image is \(posterImageURL?.URLString)")
      posterImage = PhotoInfo(sourceImageURL: posterImageURL!)
    }
    
    if let name = movieDetails["original_title"].string {
      movieName = name
    }
  }
}
