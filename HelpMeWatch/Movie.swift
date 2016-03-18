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
  let movieDetails: JSON!
  
  init(movieDetails: JSON) {
    self.movieDetails = movieDetails
  }
}

extension Movie: MovieDBEntity {
  func getName() -> String {
    if let name = movieDetails["original_title"].string {
      return name
    } else {
      return "(Unknown Title)"
    }
  }

  func getPosterImage() -> PhotoInfo? {
    if let posterPath = movieDetails["poster_path"].string {
      let posterImageURL = NSURL(string: "\(imagePrefix)\(posterPath)")
      print("Poster image is \(posterImageURL!.URLString)")
      return PhotoInfo(sourceImageURL: posterImageURL!)
    }
    
    return nil
  }
}
