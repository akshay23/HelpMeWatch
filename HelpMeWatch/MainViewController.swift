//
//  MainViewController.swift
//  HelpMeWatch
//
//  Created by Akshay Bharath on 3/11/16.
//  Copyright © 2016 Akshay Bharath. All rights reserved.
//

import UIKit
import FastImageCache

class MainViewController: UIViewController {

  @IBOutlet var posterImage: UIImageView!
  @IBOutlet var hitMeButton: UIButton!

  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Set up poster image shadow effect
    posterImage.layer.shadowOpacity = 0.5
    posterImage.layer.shadowRadius = 5
    posterImage.layer.shadowOffset = CGSize(width: 10, height: 10)
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
        })
      } else {
        self.showAlertWithMessage("Couldn't get poster", title: "Please Retry", button: "OK")
      }
    }
  }

  @IBAction func refresh(sender: AnyObject) {
    hitMe()
  }
}

