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
import LMDropdownView

class MainViewController: UIViewController {

  @IBOutlet var posterImage: UIImageView!
  @IBOutlet var hitMeButton: FUIButton!
  @IBOutlet var showTitleLabel: UILabel!
  
  var types: [String] = ["TV Shows", "Movies"]
  var isCurrentTypeMovies = false
  var dropDownView: LMDropdownView?
  var table: UITableView?

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
    hitMeButton.titleLabel!.font = UIFont.boldSystemFontOfSize(20)
    hitMeButton.shadowHeight = 5.0
    
    // Initialize types table
    initializeTypesTable()
    
    // Add button to center of navi
    let typeButton = FUIButton()
    typeButton.buttonColor = UIColor.wetAsphaltColor()
    typeButton.shadowColor = UIColor.midnightBlueColor()
    typeButton.setTitleColor(UIColor.cloudsColor(), forState: .Normal)
    typeButton.setTitleColor(UIColor.cloudsColor(), forState: .Highlighted)
    typeButton.titleLabel!.font = UIFont.boldSystemFontOfSize(15)
    typeButton.shadowHeight = 4.0
    typeButton.cornerRadius = 2.0
    typeButton.frame = CGRectMake(0, 0, 150, 30)
    typeButton.setTitle("Change Type", forState: .Normal)
    typeButton.addTarget(self, action: "chooseType:", forControlEvents: .TouchUpInside)
    navigationItem.titleView = typeButton
    
    // Initialize dropdown
    dropDownView = LMDropdownView()
    dropDownView!.blackMaskAlpha = 0.5
    dropDownView!.animationBounceHeight = 0.0
    dropDownView!.closedScale = 1.0
    dropDownView!.animationDuration = 0.3
    
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
    
    if (isCurrentTypeMovies) {
      Manager.sharedInstance.getRandomMovie() {
        (movie: Movie) in
        
        if let posterImage = movie.posterImage {
          sharedImageCache.retrieveImageForEntity(posterImage, withFormatName: KMBigImageFormatName, completionBlock: {
            (photoInfo, _, image) -> Void in
            
            self.posterImage.image = image
            if let name = movie.movieName {
              self.showTitleLabel.text = name
            }
          })
        } else {
          self.posterImage.image = UIImage(named: "NoImageFound")
          if let name = movie.movieName {
            self.showTitleLabel.text = name
          }
        }
      }
    } else {
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
  
  func initializeTypesTable() {
    table = UITableView()
    table!.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    table!.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 88)
    table!.backgroundColor = UIColor(red: 250.0/255.0, green: 250.0/255.0, blue: 250.0/255.0, alpha: 1.0)
    table!.dataSource = self
    table!.delegate = self
  }
  
  func chooseType(sender: UIButton!) {
    if (dropDownView!.isOpen) {
      dropDownView!.hide()
    } else {
      if (isCurrentTypeMovies) {
        table!.selectRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0), animated: false, scrollPosition: .None)
      } else {
        table!.selectRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), animated: false, scrollPosition: .None)
      }
      
      dropDownView!.showInView(self.view!, withContentView: table!, atOrigin: CGPoint(x: 0, y: self.navigationController!.navigationBar.frame.size.height + UIApplication.sharedApplication().statusBarFrame.size.height))
    }
  }
}

extension MainViewController {
  @IBAction func refresh(sender: AnyObject) {
    hitMe()
  }
}

extension MainViewController: UITableViewDataSource {
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return types.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell!
    
    // Configure the look
    cell.configureFlatCellWithColor(UIColor.wetAsphaltColor(), selectedColor: UIColor.cloudsColor())
    cell.textLabel!.font = UIFont.boldFlatFontOfSize(16)
    cell.textLabel!.text = types[indexPath.row]
    
    return cell
  }
}

extension MainViewController: UITableViewDelegate {
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if (indexPath.row == 0) {
      print("TV Shows selected")
      isCurrentTypeMovies = false
    } else {
      print("Movies selected")
      isCurrentTypeMovies = true
    }
    
    dropDownView!.hide()
    hitMe()
  }
}
