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
  let showDetails: JSON!
  
  init(showDetails: JSON) {
    self.showDetails = showDetails
  }
}

extension TvShow: MovieDBEntity {
  func getName() -> String {
    if let name = showDetails["name"].string {
      return name
    } else {
      return "(Unknown Title)"
    }
  }
  
  func getPosterImage() -> PhotoInfo? {
    if let posterPath = showDetails["poster_path"].string {
      let posterImageURL = NSURL(string: "\(imagePrefix)\(posterPath)")
      print("Poster image is \(posterImageURL!.URLString)")
      return PhotoInfo(sourceImageURL: posterImageURL!)
    }

    return nil
  }
}
