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
  
  func getRandomMovieDBEntity(isMovie: Bool, entityParams: [String: String]?, requestCompletion: (entity: MovieDBEntity?) -> Void) {
    print("Getting random \(isMovie ? "movie" : "TV show") now")
    getRandomPageNumber(isMovie, entityParams: entityParams) {
      (page: Int) in
      
      print("Looking at page \(page)")
      self.getRandomIdFromPage(isMovie, page: page, entityParams: entityParams) {
        (id: Int) in
        
        print("Got show id \(id)")
        if (id == -1) { // No results
          requestCompletion(entity: nil)
        } else {
          self.getEntityDetailsWithId(id, isMovie: isMovie, completion: requestCompletion)
        }
      }
    }
  }

  func getRandomPageNumber(isMovie: Bool, entityParams: [String: String]?, completion: (page: Int) -> Void) {
    let requestURL = TheMovieDB.Router.GetEntities(isMovie, entityParams)
    Alamofire.request(requestURL)
      .validate()
      .responseJSON() {
        (result) in
        
        print("Request URL is \(result.request!.URLRequest.URLString)")
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
  
  func getRandomIdFromPage(isMovie: Bool, page: Int, entityParams: [String: String]?, completion: (id: Int) -> Void) {
    let requestUrl = TheMovieDB.Router.GetEntitiesInPage(page, isMovie, entityParams)
    Alamofire.request(requestUrl)
      .validate()
      .responseJSON() {
        (result) in
        
        print("Request URL is \(result.request!.URLRequest.URLString)")
        if (result.result.isSuccess) {
          let json = JSON(result.result.value!)
          let results = json["results"]
          if let resultsArray = results.array {
            print("array count is \(resultsArray.count)")
            if resultsArray.count < 1 {
              completion(id: -1)
            } else {
              let randomIndex = Int(arc4random_uniform(UInt32(resultsArray.count)) + 0)
              completion(id: resultsArray[randomIndex]["id"].intValue)
            }
          } else {
            print("No results array present")
          }
        } else {
          print(result.debugDescription)
        }
    }
  }
  
  func getEntityDetailsWithId(id: Int, isMovie: Bool, completion: (entity: MovieDBEntity?) -> Void) {
    let requestUrl = TheMovieDB.Router.GetEntityWithId(id, isMovie)
    Alamofire.request(requestUrl)
      .validate()
      .responseJSON() {
        (result) in
        
        print("Request URL is \(result.request!.URLRequest.URLString)")
        if (result.result.isSuccess) {
          let json = JSON(result.result.value!)
          if (isMovie) {
            completion(entity: Movie(movieDetails: json))
          } else {
            completion(entity: TvShow(showDetails: json))
          }
        } else {
          print(result.debugDescription)
        }
    }
  }
  
  func getGenres(isMovie: Bool, requestCompletion: (genres: [String: String]) -> Void) {
    let requestUrl = TheMovieDB.Router.GetGenres(isMovie)
    Alamofire.request(requestUrl)
      .validate()
      .responseJSON() {
        (result) in
        
        print("Request URL is \(result.request!.URLRequest.URLString)")
        var genreList: [String: String] = [:]
        if (result.result.isSuccess) {
          let json = JSON(result.result.value!)
          if let genres = json["genres"].array {
            for (genre) in genres {
              genreList[genre["id"].stringValue] = genre["name"].stringValue
            }
          }
        } else {
          print("Coudn't get genres")
          print(result.debugDescription)
        }
  
        requestCompletion(genres: genreList)
    }
  }
}
