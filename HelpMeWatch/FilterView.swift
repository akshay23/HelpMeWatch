//
//  FilterView.swift
//  HelpMeWatch
//
//  Created by Akshay Bharath on 3/24/16.
//  Copyright © 2016 Akshay Bharath. All rights reserved.
//

import FlatUIKit
import UIKit

@IBDesignable class FilterView: UIView {
  
  let nibName = "FilterView"
  var view: UIView!
  var delegate: FilterDelegate!

  @IBOutlet var yearReleasedField: UITextField!
  @IBOutlet var applyButton: FUIButton!
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
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
    addSubview(view)
    
    // Setup button
    applyButton.shadowHeight = 4.0
    applyButton.cornerRadius = 2.0
    applyButton.buttonColor = UIColor.turquoiseColor()
    applyButton.shadowColor = UIColor.greenSeaColor()
    applyButton.setTitleColor(UIColor.cloudsColor(), forState: .Normal)
    applyButton.setTitleColor(UIColor.cloudsColor(), forState: .Highlighted)
    applyButton.setTitle("Apply Filters", forState: .Normal)
    applyButton.addTarget(self, action: "applyFilters", forControlEvents: .TouchUpInside)
  }
  
  func applyFilters() {
    delegate.applyFilters()
  }
}
