//
//  FilterView.swift
//  HelpMeWatch
//
//  Created by Akshay Bharath on 3/24/16.
//  Copyright © 2016 Akshay Bharath. All rights reserved.
//

import UIKit

@IBDesignable class FilterView: UIView {
  
  let nibName = "FilterView"
  var view: UIView!

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
    view = loadViewFromNib()
    view.frame = bounds
    addSubview(view)
  }
}
