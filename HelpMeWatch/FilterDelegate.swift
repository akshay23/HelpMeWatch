//
//  FilterDelegate.swift
//  HelpMeWatch
//
//  Created by Akshay Bharath on 3/24/16.
//  Copyright © 2016 Akshay Bharath. All rights reserved.
//

import Foundation

protocol FilterDelegate {
  func isTypeSetToMovies() -> Bool
  func applyFilters()
}
