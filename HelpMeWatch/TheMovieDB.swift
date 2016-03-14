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

    case GetTVShows
    case GetTVShowsInPage(Int)
    case GetTVShow(Int)
    case GetMovies
    case GetMoviesInPage(Int)
    case GetMovie(Int)
    
    var URLRequest: NSMutableURLRequest {
      let (path, parameters): (String, [String: AnyObject]) = {
        switch self {
        case .GetTVShows:
          let params = ["api_key": Router.apiKey]
          let pathString = "/3/discover/tv"
          return (pathString, params)
          
        case .GetTVShowsInPage (let page):
          let params = ["api_key": Router.apiKey, "page": page]
          let pathString = "/3/discover/tv"
          return (pathString, params as! [String : AnyObject])
          
        case .GetTVShow (let showId):
          let params = ["api_key": Router.apiKey]
          let pathString = "/3/tv/\(showId)"
          return (pathString, params)
          
        case .GetMovies:
          let params = ["api_key": Router.apiKey]
          let pathString = "/3/discover/movie"
          return (pathString, params)
          
        case .GetMoviesInPage (let page):
          let params = ["api_key": Router.apiKey, "page": page]
          let pathString = "/3/discover/movie"
          return (pathString, params as! [String : AnyObject])
          
        case .GetMovie (let movieId):
          let params = ["api_key": Router.apiKey]
          let pathString = "/3/movie/\(movieId)"
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
