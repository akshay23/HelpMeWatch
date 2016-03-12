//
//  TvShow.swift
//  HelpMeWatch
//
//  Created by Akshay Bharath on 3/11/16.
//  Copyright © 2016 Akshay Bharath. All rights reserved.
//

import Foundation
import SwiftyJSON

class TvShow: NSObject {
  
  let imagePrefix = "https://image.tmdb.org/t/p/w500"
  var posterImage: PhotoInfo?
  var showName: String?
  
  init(showDetails: JSON) {
    if let posterPath = showDetails["poster_path"].string {
      let posterImageURL = NSURL(string: "\(imagePrefix)\(posterPath)")
      print("Poster image is \(posterImageURL?.URLString)")
      posterImage = PhotoInfo(sourceImageURL: posterImageURL!)
    }
    
    if let name = showDetails["name"].string {
      showName = name
    }
  }
}
