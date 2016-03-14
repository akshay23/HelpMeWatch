//
//  MainViewController.swift
//  HelpMeWatch
//
//  Created by Akshay Bharath on 3/11/16.
//  Copyright © 2016 Akshay Bharath. All rights reserved.
//

import UIKit
import FastImageCache
import FlatUIKit

class MainViewController: UIViewController {

  @IBOutlet var posterImage: UIImageView!
  @IBOutlet var hitMeButton: FUIButton!
  @IBOutlet var showTitleLabel: UILabel!

  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Set up poster image shadow effect
    posterImage.layer.shadowOpacity = 0.5
    posterImage.layer.shadowRadius = 5
    posterImage.layer.shadowOffset = CGSize(width: 10, height: 10)

    // Set up button
    hitMeButton.buttonColor = UIColor.turquoiseColor()
    hitMeButton.shadowColor = UIColor.greenSeaColor()
    hitMeButton.setTitleColor(UIColor.cloudsColor(), forState: .Normal)
    hitMeButton.setTitleColor(UIColor.cloudsColor(), forState: .Highlighted)
    hitMeButton.titleLabel?.font = UIFont.boldFlatFontOfSize(20)
    hitMeButton.shadowHeight = 5.0
    
    // Label
    showTitleLabel.text = ""
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    // Get new show
    hitMe()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func hitMe() {
    let sharedImageCache = FICImageCache.sharedImageCache()
    Manager.sharedInstance.getRandomTvShow() {
      (show: TvShow) in
      
      if let posterImage = show.posterImage {
        sharedImageCache.retrieveImageForEntity(posterImage, withFormatName: KMBigImageFormatName, completionBlock: {
          (photoInfo, _, image) -> Void in
          
          self.posterImage.image = image
          if let name = show.showName {
            self.showTitleLabel.text = name
          }
        })
      } else {
        self.posterImage.image = UIImage(named: "NoImageFound")
        if let name = show.showName {
          self.showTitleLabel.text = name
        }
      }
      
    }
  }
}

extension MainViewController {
  @IBAction func refresh(sender: AnyObject) {
    hitMe()
  }
}
