//
//  Manager.swift
//  HelpMeWatch
//
//  Created by Akshay Bharath on 3/11/16.
//  Copyright © 2016 Akshay Bharath. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import Darwin

class Manager: NSObject {

  // Singleton
  class var sharedInstance: Manager {
    struct Static {
      static let instance: Manager = Manager()
    }
    return Static.instance
  }
  
  func getRandomTvShow(requestCompletion: (show: TvShow) -> Void) {
    print("Getting random TV show now")
    getRandomPageNumber() {
      (page: Int) in
      
      print("Looking at page \(page)")
      self.getRandomIdFromPage(page) {
        (id: Int) in
        
        print("Got show id \(id)")
        self.getShowDetailsFor(id, completion: requestCompletion)
      }
    }
  }
  
  func getRandomPageNumber(completion: (page: Int) -> Void) {
    let requestURL = TheMovieDB.Router.GetTVShows
    print("Request URL is \(requestURL.URLRequest.URLString)")
    Alamofire.request(requestURL)
      .validate()
      .responseJSON() {
        (result) in
        
        if (result.result.isSuccess) {
          let json = JSON(result.result.value!)
          let totalPages = json["total_pages"].intValue
          print("Total number of pages is \(totalPages)")
          
          if (totalPages <= 1) {
            completion(page: 1)
          } else {
            let randNum = Int(arc4random_uniform(UInt32(totalPages)) + 1)
            completion(page: randNum)
          }
        } else {
          print(result.debugDescription)
        }
    }
  }
  
  func getRandomIdFromPage(page: Int, completion: (id: Int) -> Void) {
    let requestUrl = TheMovieDB.Router.GetTVShowsInPage(page)
    print("Request URL is \(requestUrl.URLRequest.URLString)")
    Alamofire.request(requestUrl)
      .validate()
      .responseJSON() {
        (result) in
        
        if (result.result.isSuccess) {
          let json = JSON(result.result.value!)
          let results = json["results"]
          if let resultsArray = results.array {
            let randomIndex = Int(arc4random_uniform(UInt32(resultsArray.count)) + 0)
            completion(id: resultsArray[randomIndex]["id"].intValue)
          } else {
            print("No results array present")
          }
        } else {
          print(result.debugDescription)
        }
    }
  }
  
  func getShowDetailsFor(showId: Int, completion: (show: TvShow) -> Void) {
    let requestUrl = TheMovieDB.Router.GetTVShow(showId)
    print("Request URL is \(requestUrl.URLRequest.URLString)")
    Alamofire.request(requestUrl)
      .validate()
      .responseJSON() {
        (result) in
        
        if (result.result.isSuccess) {
          let json = JSON(result.result.value!)
          completion(show: TvShow(showDetails: json))
        } else {
          print(result.debugDescription)
        }
    }
  }
}
