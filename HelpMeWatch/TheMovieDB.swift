//
//  TheMovieDB.swift
//  HelpMeWatch
//
//  Created by Akshay Bharath on 3/11/16.
//  Copyright © 2016 Akshay Bharath. All rights reserved.
//

import Foundation
import Alamofire

struct TheMovieDB {
  enum Router: URLRequestConvertible {
    static let baseURLString = "https://api.themoviedb.org"
    static let apiKey = "f7b7d80cdbf9b068e0db896b05f27c74"

    case GetEntities(Bool)
    case GetEntitiesInPage(Int, Bool)
    case GetEntityWithId(Int, Bool)
    
    var URLRequest: NSMutableURLRequest {
      let (path, parameters): (String, [String: AnyObject]) = {
        switch self {
        case .GetEntities (let isMovie):
          let type = isMovie ? "movie" : "tv"
          let params = ["api_key": Router.apiKey]
          let pathString = "/3/discover/\(type)"
          return (pathString, params)
          
        case .GetEntitiesInPage (let page, let isMovie):
          let type = isMovie ? "movie" : "tv"
          let params = ["api_key": Router.apiKey, "page": page]
          let pathString = "/3/discover/\(type)"
          return (pathString, params as! [String : AnyObject])
        
        case .GetEntityWithId (let id, let isMovie):
          let type = isMovie ? "movie" : "tv"
          let params = ["api_key": Router.apiKey]
          let pathString = "/3/\(type)/\(id)"
          return (pathString, params)
      }
      }()
      
      let BaseURL = NSURL(string: Router.baseURLString)
      let URLRequest = NSURLRequest(URL: BaseURL!.URLByAppendingPathComponent(path))
      let encoding = Alamofire.ParameterEncoding.URL
      return encoding.encode(URLRequest, parameters: parameters).0
    }
  }
}
