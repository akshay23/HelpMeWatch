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
  var filters: [String: String]?
  var view: UIView!
  var delegate: FilterDelegate!
  var genreDropDown: DropDown!
  
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
    
    // Hide keyboard on tap
    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
    view.addGestureRecognizer(tap)
    
    // Load genres dropdown
    genreDropDown = DropDown()
    genreDropDown.anchorView = dropDownView
    genreDropDown.width = dropDownView.bounds.width
    genreDropDown.direction = .Bottom
    genreDropDown.dismissMode = .Automatic
    genreDropDown.dataSource = ["ALL", "Action", "Comedy"]  //TODO
    genreDropDown.selectionAction = { (index, item) in
      self.changeGenreButton.setTitle(item, forState: .Normal)
    }
    
    // Delegates
    yearReleasedField.delegate = self
  }
  
  func dismissKeyboard() {
    yearReleasedField.resignFirstResponder()
  }
  
  func applyFilters() {
    if (delegate.isTypeSetToMovies()) {
      if (yearReleasedField.text! != "") {
        filters = ["year": yearReleasedField.text!]
      } else {
        filters?.removeValueForKey("year")
      }
    } else {
      
    }

    dismissKeyboard()
    delegate.applyFilters()
  }
  
  func updateUI() {
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
