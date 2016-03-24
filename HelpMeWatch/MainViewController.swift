//
//  MainViewController.swift
//  HelpMeWatch
//
//  Created by Akshay Bharath on 3/11/16.
//  Copyright © 2016 Akshay Bharath. All rights reserved.
//

import CoreData
import FastImageCache
import FlatUIKit
import LMDropdownView
import MBProgressHUD
import UIKit

class MainViewController: UIViewController {

  @IBOutlet var posterImage: UIImageView!
  @IBOutlet var showTitleLabel: UILabel!
  
  var types: [String] = ["TV Shows", "Movies"]
  var isCurrentTypeMovies = false
  var dropDownView: LMDropdownView?
  var table: UITableView?
  var coreDataStack: CoreDataStack!
  var userOpts: UserOptions!

  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Initialize core data stack
    coreDataStack = CoreDataStack.sharedInstance
    if let fetchRequest = coreDataStack.model.fetchRequestTemplateForName("OptionsFetchRequest") {
      let results = (try! coreDataStack.context.executeFetchRequest(fetchRequest)) as! [UserOptions]
      if let options = results.first {
        print("Loaded existing user options")
        userOpts = options
        isCurrentTypeMovies = options.isMovieType
      } else {
        ("Creating and saving new user options")
        userOpts = NSEntityDescription.insertNewObjectForEntityForName("UserOptions", inManagedObjectContext: self.coreDataStack.context) as! UserOptions
        userOpts.isMovieType = false
        coreDataStack.saveContext()
      }
    }
    
    // Set up poster image shadow effect
    posterImage.layer.shadowOpacity = 0.5
    posterImage.layer.shadowRadius = 5
    posterImage.layer.shadowOffset = CGSize(width: 10, height: 10)
    
    // Initialize types table
    initializeTypesTable()
    
    // Add left button navi
    let typeButton = UIBarButtonItem(image: UIImage(named: "ChangeIcon"), style: .Plain, target: self, action: "chooseType:")
    typeButton.configureFlatButtonWithColor(UIColor.midnightBlueColor(), highlightedColor: UIColor.wetAsphaltColor(), cornerRadius: 2.0)
    typeButton.tintColor = UIColor.cloudsColor()
    navigationItem.setLeftBarButtonItem(typeButton, animated: true)
    
    // Add right button
    let filterButton = UIBarButtonItem(image: UIImage(named: "FilterIcon"), style: .Plain, target: self, action: "changeFilters:")
    filterButton.configureFlatButtonWithColor(UIColor.midnightBlueColor(), highlightedColor: UIColor.wetAsphaltColor(), cornerRadius: 2.0)
    filterButton.tintColor = UIColor.cloudsColor()
    navigationItem.setRightBarButtonItem(filterButton, animated: true)
    
    // Add button to center of navi
    let hitMeButton = FUIButton()
    hitMeButton.frame = CGRectMake(0, 0, 150, 35)
    hitMeButton.shadowHeight = 4.0
    hitMeButton.cornerRadius = 2.0
    hitMeButton.titleLabel!.font = UIFont.boldSystemFontOfSize(18)
    hitMeButton.buttonColor = UIColor.wetAsphaltColor()
    hitMeButton.shadowColor = UIColor.midnightBlueColor()
    hitMeButton.setTitleColor(UIColor.cloudsColor(), forState: .Normal)
    hitMeButton.setTitleColor(UIColor.concreteColor(), forState: .Highlighted)
    hitMeButton.setTitle("Help Me Watch", forState: .Normal)
    hitMeButton.addTarget(self, action: "helpMeWatch", forControlEvents: .TouchUpInside)
    navigationItem.titleView = hitMeButton
    
    // Initialize dropdown
    dropDownView = LMDropdownView()
    dropDownView!.blackMaskAlpha = 0.6
    dropDownView!.animationBounceHeight = 0.0
    dropDownView!.closedScale = 1.0
    dropDownView!.animationDuration = 0.3
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    // For shake gesture
    becomeFirstResponder()
    
    // Get new show or movie
    helpMeWatch()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override func canBecomeFirstResponder() -> Bool {
    return true
  }
  
  override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
    if motion == .MotionShake {
      print("Shake detected")
      helpMeWatch()
    }
  }
  
  func helpMeWatch() {
    let sharedImageCache = FICImageCache.sharedImageCache()
    
    MBProgressHUD.showHUDAddedTo(self.view, animated: true)
    
    Manager.sharedInstance.getRandomMovieDBEntity(isCurrentTypeMovies) {
      (entity: MovieDBEntity) in
        
      if let posterImage = entity.getPosterImage()  {
        sharedImageCache.retrieveImageForEntity(posterImage, withFormatName: KMBigImageFormatName, completionBlock: {
          (photoInfo, _, image) -> Void in
            
          self.posterImage.image = image
          self.showTitleLabel.text = entity.getName()
          MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
        })
      } else {
        self.posterImage.image = UIImage(named: "NoImageFound")
        self.showTitleLabel.text = entity.getName()
        MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
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
  
  func chooseType(sender: UIBarButtonItem!) {
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
  
  func changeFilters(sender: UIBarButtonItem!) {
    
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
    
    // Add accessory as needed
    if (isCurrentTypeMovies && indexPath.row == 1) {
      cell.accessoryType = .Checkmark
      cell.selected = true
    } else if (!isCurrentTypeMovies && indexPath.row == 0) {
      cell.accessoryType = .Checkmark
      cell.selected = true
    } else {
      cell.accessoryType = .None
      cell.selected = false
    }
    
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
    
    userOpts.isMovieType = isCurrentTypeMovies
    coreDataStack.saveContext()
    table!.reloadData()
    dropDownView!.hide()
    helpMeWatch()
  }
}
