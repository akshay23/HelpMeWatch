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
  
  let DropDownWaitTime = 0.5
  let types: [String] = ["TV Shows", "Movies"]
  var filters: [String: String]?
  var isCurrentTypeMovies = false
  var isFilterViewShowing = false
  var isTypeTableShowing = false

  var hitMeButton: FUIButton!
  var dropDownView: LMDropdownView!
  var typesTable: UITableView!
  var coreDataStack: CoreDataStack!
  var userOpts: UserOptions!
  var filterView: FilterView!

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
    
    // Initialize types table
    initializeTypesTable()
    
    // Initialize dropdown
    dropDownView = LMDropdownView()
    dropDownView!.blackMaskAlpha = 0.6
    dropDownView!.animationBounceHeight = 0.0
    dropDownView!.closedScale = 1.0
    dropDownView!.animationDuration = 0.2
    
    // Set up poster image shadow effect
    posterImage.layer.shadowOpacity = 0.5
    posterImage.layer.shadowRadius = 5
    posterImage.layer.shadowOffset = CGSize(width: 10, height: 10)
    
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
    hitMeButton = FUIButton()
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
    
    // Rough filter view
    let filterRect = CGRectMake(0, 0, view.bounds.width, 200)
    filterView = FilterView(frame: filterRect)
    filterView.delegate = self
    filterView.view.backgroundColor = UIColor.cloudsColor()
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
  
  func initializeTypesTable() {
    typesTable = UITableView()
    typesTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    typesTable.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 88)
    typesTable.dataSource = self
    typesTable.delegate = self
  }
  
  func helpMeWatch() {
    dropDownView.hide()
    
    checkReachabilityWithBlock() {
      MBProgressHUD.showHUDAddedTo(self.view, animated: true)
      self.hitMeButton.enabled = false
      self.navigationItem.leftBarButtonItem!.enabled = false
      self.navigationItem.rightBarButtonItem!.enabled = false
      
      let sharedImageCache = FICImageCache.sharedImageCache()
      Manager.sharedInstance.getRandomMovieDBEntity(self.isCurrentTypeMovies, entityParams: self.filters) {
        (entity: MovieDBEntity) in
          
        if let posterImage = entity.getPosterImage()  {
          sharedImageCache.retrieveImageForEntity(posterImage, withFormatName: KMBigImageFormatName, completionBlock: {
            (photoInfo, _, image) -> Void in
              
            self.posterImage.image = image
            self.showTitleLabel.text = entity.getName()
            self.hitMeButton.enabled = true
            self.navigationItem.leftBarButtonItem!.enabled = true
            self.navigationItem.rightBarButtonItem!.enabled = true
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
          })
        } else {
          self.posterImage.image = UIImage(named: "NoImageFound")
          self.showTitleLabel.text = entity.getName()
          self.hitMeButton.enabled = true
          self.navigationItem.leftBarButtonItem!.enabled = true
          self.navigationItem.rightBarButtonItem!.enabled = true
          MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
        }
      }
    }
  }
  
  func chooseType(sender: UIBarButtonItem!) {
    if (dropDownView.isOpen) {
      dropDownView.hide()
      if (isFilterViewShowing) {
        // Need to sleep for a little before showing table due the design of LMDropdownView
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
          NSThread.sleepForTimeInterval(self.DropDownWaitTime)
          dispatch_async(dispatch_get_main_queue()) {
            self.isFilterViewShowing = false
            self.selectRowAndShowTable()
          }
        }
      } else {
        isTypeTableShowing = false
      }
    } else {
      selectRowAndShowTable()
    }
  }
  
  func selectRowAndShowTable() {
    if (isCurrentTypeMovies) {
      typesTable.selectRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0), animated: false, scrollPosition: .None)
    } else {
      typesTable.selectRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), animated: false, scrollPosition: .None)
    }
    
    dropDownView.showInView(self.view, withContentView: typesTable, atOrigin: CGPoint(x: 0, y: navigationController!.navigationBar.frame.size.height + UIApplication.sharedApplication().statusBarFrame.size.height))
    isTypeTableShowing = true
  }
  
  func changeFilters(sender: UIBarButtonItem!) {
    if (dropDownView.isOpen) {
      dropDownView.hide()
      if (isTypeTableShowing) {
        // Need to sleep for a little before showing filter view due the design of LMDropdownView
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
          NSThread.sleepForTimeInterval(self.DropDownWaitTime)
          dispatch_async(dispatch_get_main_queue()) {
            self.isTypeTableShowing = false
            self.showFilterView()
          }
        }
      } else {
        isFilterViewShowing = false
      }
    } else {
      showFilterView()
    }
  }
  
  func showFilterView() {
    dropDownView.showInView(self.view, withContentView: filterView, atOrigin: CGPoint(x: 0, y: navigationController!.navigationBar.frame.size.height + UIApplication.sharedApplication().statusBarFrame.size.height))
    isFilterViewShowing = true
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
    typesTable.reloadData()
    dropDownView!.hide()
    helpMeWatch()
  }
}

extension MainViewController: FilterDelegate {
  func applyFilters() {
    dropDownView.hide()
    
    let yearRel = filterView.yearReleasedField.text!
    if (yearRel != "") {
      filters = ["year": yearRel]
    } else {
      filters = nil
    }
    
    helpMeWatch()
  }
}
