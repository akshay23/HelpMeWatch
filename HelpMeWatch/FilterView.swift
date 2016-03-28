//
//  FilterView.swift
//  HelpMeWatch
//
//  Created by Akshay Bharath on 3/24/16.
//  Copyright © 2016 Akshay Bharath. All rights reserved.
//

import DropDown
import FlatUIKit
import UIKit

class FilterView: UIView {
  
  let nibName = "FilterView"
  var filters: [String: String]!
  var view: UIView!
  var delegate: FilterDelegate!
  var genreDropDown: DropDown!
  var genres: [String: String]!
  var currentGenreId: String!
  var selectedGenreId: String!
  
  @IBOutlet var dropDownView: UIView!
  @IBOutlet var changeGenreButton: FUIButton!
  @IBOutlet var yearReleasedLabel: UILabel!
  @IBOutlet var yearReleasedField: UITextField!
  @IBOutlet var applyButton: FUIButton!
  
  init(frame: CGRect, delegate: FilterDelegate) {
    super.init(frame: frame)
    self.delegate = delegate
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }
  
  override func canBecomeFirstResponder() -> Bool {
    return true
  }
  
  func loadViewFromNib() -> UIView {
    let bundle = NSBundle(forClass: self.dynamicType)
    let nib = UINib(nibName: nibName, bundle: bundle)
    return nib.instantiateWithOwner(self, options: nil)[0] as! UIView
  }
  
  func setup() {
    // Create view
    filters = [:]
    view = loadViewFromNib()
    view.frame = bounds
    view.backgroundColor = UIColor.cloudsColor()
    addSubview(view)
    
    // Setup apply button
    applyButton.shadowHeight = 4.0
    applyButton.cornerRadius = 2.0
    applyButton.buttonColor = UIColor.turquoiseColor()
    applyButton.shadowColor = UIColor.greenSeaColor()
    applyButton.setTitleColor(UIColor.cloudsColor(), forState: .Normal)
    applyButton.setTitleColor(UIColor.cloudsColor(), forState: .Highlighted)
    applyButton.setTitle("Apply Filters", forState: .Normal)
    applyButton.addTarget(self, action: "applyFilters", forControlEvents: .TouchUpInside)
    
    // Setup genre dd view button
    dropDownView.backgroundColor = UIColor.cloudsColor()
    changeGenreButton.buttonColor = UIColor.cloudsColor()
    changeGenreButton.cornerRadius = 2.0
    changeGenreButton.layer.borderWidth = 1.0
    
    // Hide keyboard on tap
    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
    view.addGestureRecognizer(tap)
    
    // Modify genres dropdown
    genreDropDown = DropDown()
    genreDropDown.anchorView = dropDownView
    genreDropDown.direction = .Bottom
    genreDropDown.dismissMode = .Automatic
    genreDropDown.selectionAction = { (index, item) in
      self.changeGenreButton.setTitle(item, forState: .Normal)
      if (item == "ALL") {
        self.selectedGenreId = "-1"
      } else {
        // Reverse lookup
        self.selectedGenreId = (self.genres as NSDictionary).allKeysForObject(item).first as! String
      }
    }
    
    // Delegates
    yearReleasedField.delegate = self
    
    // Update UI
    updateUI()
  }
  
  func dismissKeyboard() {
    yearReleasedField.resignFirstResponder()
  }
  
  func viewIsClosing() {
    if (currentGenreId == "-1") {
      genreDropDown.selectRowAtIndex(0)
      changeGenreButton.setTitle("ALL", forState: .Normal)
    } else {
      let btnText = genres[currentGenreId]
      changeGenreButton.setTitle(btnText, forState: .Normal)
      genreDropDown.selectRowAtIndex(genreDropDown.dataSource.indexOf(btnText!))
    }
  }
  
  func applyFilters() {
    currentGenreId = selectedGenreId
    
    if (delegate.isTypeSetToMovies()) {
      if (yearReleasedField.text! != "") {
        filters["year"] = yearReleasedField.text!
      } else {
        filters.removeValueForKey("year")
      }
      
      if (currentGenreId != "-1") {
        filters["genre"] = currentGenreId
      } else {
        filters.removeValueForKey("genre")
      }
    } else {
      
    }

    dismissKeyboard()
    delegate.applyFilters()
  }
  
  func updateUI() {
    // Get genres 
    Manager.sharedInstance.getGenres(delegate.isTypeSetToMovies()) {
      (genres: [String: String]) in
      
      var ddList: [String] = ["ALL"]
      var longest = 3
      for (_, value) in genres {
        if (value.characters.count > longest) {
          longest = value.characters.count
        }
        ddList.append(value)
      }
      self.genreDropDown.dataSource = ddList
      self.genreDropDown.width = CGFloat(longest * 10)
      self.genreDropDown.selectRowAtIndex(0)
      self.changeGenreButton.setTitle("ALL", forState: .Normal)
      self.currentGenreId = "-1"
      self.selectedGenreId = "-1"
      self.genres = genres
    }
    
    if (delegate.isTypeSetToMovies()) {
      print("Delegate's type is set to Movies")
      yearReleasedField.hidden = false
      yearReleasedLabel.hidden = false
    } else {
      print("Delegate's type is set to TV Shows")
      yearReleasedField.hidden = true
      yearReleasedLabel.hidden = true
    }
  }
}

extension FilterView {
  @IBAction func changeGenre(sender: AnyObject) {
    genreDropDown.show()
  }
}

extension FilterView: UITextFieldDelegate {
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    applyFilters()
    return true
  }
}
