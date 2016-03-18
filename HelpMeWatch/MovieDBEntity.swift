//
//  MovieDBEntity.swift
//  HelpMeWatch
//
//  Created by Akshay Bharath on 3/18/16.
//  Copyright © 2016 Akshay Bharath. All rights reserved.
//

import Foundation

protocol MovieDBEntity {
  func getName() -> String
  func getPosterImage() -> PhotoInfo?
}
