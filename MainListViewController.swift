//
//  MainListViewController.swift
//  RemotePlug
//
//  Created by Sidharth Agarwal on 18/12/15.
//  Copyright © 2015 Sidharth Agarwal. All rights reserved.
//

import Foundation
import UIKit

let cellID = "cell"
var curIndex = 0

class MainListViewController : UITableViewController {
    var selectedIndexPath : NSIndexPath?
    var dictMap : Dictionary<NSIndexPath, Int> = Dictionary()
    var saved : NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    @IBAction func handleCellTap(recognizer: UITapGestureRecognizer){
        NSLog("touched from 2")
    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //let saved = NSUserDefaults.standardUserDefaults()
        let dict:NSArray? = saved.arrayForKey("saved")
        var count:Int
        if dict == nil {
            count = 0
        }
        else {
            count = dict!.count
        }
        return count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath) as! MainCell;
        cell.setID(curIndex);
        dictMap[indexPath] = curIndex;
        /*
        switch curIndex {
        case 0 : cell.TitleLabel.text = "test"
                cell.popualteAsButton()
                break
        case 1: cell.TitleLabel.text = "test"
                cell.popualteAsButton()
                break
        default: break
        }*/
        curIndex++
        return cell
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //selectedIndexPath = indexPath
        NSLog("touched from %d", indexPath);
        
        //refresh the cells
        let previousIndexPath = selectedIndexPath
        if indexPath == selectedIndexPath {
            selectedIndexPath = nil
        } else {
            selectedIndexPath = indexPath
        }
        var indexPaths : Array<NSIndexPath> = []
        
        if let previous = previousIndexPath {
            indexPaths += [previous]
        }
        if let current = selectedIndexPath {
            indexPaths += [current]
        }
        
        if indexPaths.count > 0 {
            //tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Automatic)
            tableView.reloadData()
            /*var cell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath) as! MainCell;
            cell.refreshContents()
            cell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath) as! MainCell;
            cell.refreshContents()*/
        }
        NSLog("refreshing cells %d", indexPaths.count)
    }
    
    override func viewDidLoad() {
        let cells = tableView.visibleCells
        for cell in cells {
            //cell.populateAsButton;
        }
    }
    /*override func viewDidLoad() {
        tableView.tableFooterView = UIView()
    }*/ 
    override func viewWillAppear(animated: Bool) {
        tableView.tableFooterView = UIView()
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        //let saved = NSUserDefaults.standardUserDefaults()
        let dict:NSArray? = saved.arrayForKey("saved")
        if indexPath.row > dict!.count {
            return 0
        }
        else if indexPath == selectedIndexPath {
            //let cell = tableView.cellForRowAtIndexPath(indexPath) as! MainCell;
            NSLog("row number %d", indexPath.row);
            /*NSLog("getting info at index %d", dictMap[indexPath]!)
            if(dictMap[indexPath]! > dict!.count){
                return MainCell.expandedHeight
            }*/
            let buttonDict:NSDictionary = dict?.objectAtIndex(indexPath.row) as! NSDictionary
            let type:NSString = buttonDict.objectForKey("type") as! NSString
            if(type.lowercaseString == "rgb led"){
                return MainCell.expandedHeightLED
            }
            NSLog("type %@", type)
            return MainCell.expandedHeight
        } else {
            return MainCell.defaultHeight
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        (cell as! MainCell).watchFrameChanges()
    }
    
    override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        (cell as! MainCell).ignoreFrameChanges()
    }
}