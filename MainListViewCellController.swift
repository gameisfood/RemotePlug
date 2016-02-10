//
//  MainListViewCellController.swift
//  RemotePlug
//
//  Created by Sidharth Agarwal on 18/12/15.
//  Copyright © 2015 Sidharth Agarwal. All rights reserved.
//

import Foundation
import UIKit

class MainCell : UITableViewCell {
    
    @IBOutlet weak var cellSwtich: UISwitch!
    @IBOutlet weak var cellButton: UIButton!
    //@IBOutlet weak var CellInternalView: UIView!
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var IPLabel: UILabel!
    @IBOutlet weak var rSlider: UISlider!
    @IBOutlet weak var gSlider: UISlider!
    @IBOutlet weak var bSlider: UISlider!
    @IBOutlet weak var rgbViewer: UIImageView!
    var isObserving = false;
    var mode : NSString = ""
    var selfInfo : NSDictionary = NSDictionary()
    class var expandedHeightLED: CGFloat { get { return 200 } }
    class var expandedHeight: CGFloat { get { return 80 } }
    class var defaultHeight: CGFloat  { get { return 44  } }
    var sliderTimer = NSTimer()
    var disableShitTimer = NSTimer()

    
    var expanded = false
    func MainCell() {
        //expanded = false;
    }
    func setID(id: Int) {
        let saved = NSUserDefaults.standardUserDefaults()
        let dict:NSArray? = saved.arrayForKey("saved")
        if dict == nil {
            NSLog("saved file couldnt be read")
        }
        else {
            if id<dict?.count {
                selfInfo = dict?.objectAtIndex(id) as! NSDictionary
                mode = selfInfo.objectForKey("type") as! String
                mode = mode.lowercaseString
                TitleLabel.text = selfInfo.objectForKey("name") as? String
                var iptext = "IP: "
                iptext += selfInfo.objectForKey("ip") as! String
                IPLabel.text = iptext
                NSLog("setting mode as %@", mode);
                refreshContents()
            }
            else {
                NSLog("id overflow")
            }
        }
    }
    func populateAsRGB() {
        cellButton.enabled = false
        cellButton.hidden = true
        mode = "rgb led"
        
        var urlString = "http://"
        urlString += selfInfo.objectForKey("ip") as! String
        urlString += "/ledstatus";
        
        let url = NSURL(string: urlString)
        let request = NSURLRequest(URL: url!)
        
        let session:NSURLSession = NSURLSession.sharedSession()
        let sessionConfig:NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        sessionConfig.timeoutIntervalForRequest = 2.0;
        sessionConfig.timeoutIntervalForResource = 2.0;
        
        
        var rechable:Bool = false
        let task = session.dataTaskWithRequest(request, completionHandler:{data,response,error in
            if error == nil {
                rechable = true
                self.disableShitTimer.invalidate()
                self.rSlider.enabled = true
                self.bSlider.enabled = true
                self.gSlider.enabled = true
                self.cellSwtich.enabled = true
                self.cellSwtich.setOn(true, animated: true)
                
                NSLog("loading rgb from esp")
                let str:NSString = NSString(data: data!, encoding: NSUTF8StringEncoding)!
                NSLog(str as String)
                let set:NSCharacterSet = NSCharacterSet(charactersInString: "=,\n")
                let parts = str.componentsSeparatedByCharactersInSet(set)
                NSLog("%d", Int(parts[1])!)
                NSLog(parts[3])
                NSLog(parts[5])
                //var flt:float = Int(parts[1]) / 1023
                self.rSlider.value = (float_t(parts[1])!/1023.0)
                self.gSlider.value = (float_t(parts[3])!/1023.0)
                self.bSlider.value = (float_t(parts[5])!/1023.0)
                let swiftColor = UIColor(red: CGFloat(self.rSlider.value), green: CGFloat(self.gSlider.value), blue: CGFloat(self.bSlider.value), alpha: 1)
                self.rgbViewer.backgroundColor = swiftColor
            }
            else {
            }
        })
        task.resume()
        if rechable == false{
            disableShitTimer.invalidate()
            disableShitTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "disableRGBShit", userInfo: nil, repeats: false)
        }
        
    }
    func disableRGBShit() {
        self.rSlider.enabled = false
        self.bSlider.enabled = false
        self.gSlider.enabled = false
        self.cellSwtich.enabled = false
        self.cellSwtich.setOn(false, animated: true)
    }
    func populateAsSwitch() {
        cellButton.enabled = false
        cellButton.alpha = 0
        mode = "switch"
        
        rSlider.hidden = true
        bSlider.hidden = true
        gSlider.hidden = true
    }
    func popualteAsButton() {
        cellSwtich.enabled = false
        //TitleLabel.text = "button"
        cellSwtich.hidden = true
        mode = "button"
        
        rSlider.hidden = true
        bSlider.hidden = true
        gSlider.hidden = true
        rgbViewer.hidden = true
    }
    @IBAction func likedThis(sender: UIButton) {
        NSLog("pressed");
        
        if mode == "button" {
            var urlString = "http://"
            urlString += selfInfo.objectForKey("ip") as! String
            urlString += "/LED=ON"
            let url = NSURL(string: urlString)
            let request = NSURLRequest(URL: url!)
            
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request, completionHandler:{_,_,_ in })
            task.resume()
            NSLog("request on %@", urlString)
            //task.resume()
        }
    }
    
    func refreshContents() {
        if mode == "switch" {
            self.populateAsSwitch();
        }
        else if mode == "button" {
            self.popualteAsButton()
        }
        else if mode == "rgb led" {
            self.populateAsRGB()
        }
        else {
            NSLog("Undefined mode")
        }
    }
    func updatedSlider() {
        let swiftColor = UIColor(red: CGFloat(rSlider.value), green: CGFloat(gSlider.value), blue: CGFloat(bSlider.value), alpha: 1)
        rgbViewer.backgroundColor = swiftColor
        rgbViewer.alpha = 1
        rgbViewer.hidden = false
        
        sliderTimer.invalidate()
        sliderTimer = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: "sendRGBRefresh", userInfo: nil, repeats: false)
    }
    func sendRGBRefresh() {
        if mode == "rgb led" {
            /*var urlString = "http://"
            urlString += selfInfo.objectForKey("ip") as! String
            urlString += "/led?r="
            urlString += String(Int(rSlider.value*1023))*/
            
            let redvalue = Int(rSlider.value*1023);
            let greenvalue = Int(gSlider.value*1023);
            let bluevalue = Int(bSlider.value*1023);
            
            var urlString = "http://"
            urlString += selfInfo.objectForKey("ip") as! String
            urlString += "/led?r=\(redvalue)&g=\(greenvalue)&b=\(bluevalue)";
            
            let url = NSURL(string: urlString)
            let request = NSURLRequest(URL: url!)
            
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request, completionHandler:{_,_,_ in })
            task.resume()
            NSLog("request on %@", urlString)
            //task.resume()
        }
    }
    @IBAction func updatedR(sender: AnyObject) {
        updatedSlider()
    }
    @IBAction func updatedG(sender: AnyObject) {
        updatedSlider()
    }
    @IBAction func updatedB(sender: AnyObject) {
        updatedSlider()
    }
    
    @IBAction func switchToggle(sender: AnyObject) {
        if cellSwtich.on {
            if mode == "rgb led" {
                rSlider.enabled = true
                gSlider.enabled = true
                bSlider.enabled = true
                sendRGBRefresh()
            }
        }
        else{
            if mode == "rgb led" {
                rSlider.enabled = false
                gSlider.enabled = false
                bSlider.enabled = false
                
                let redvalue = 0
                let greenvalue = 0
                let bluevalue = 0
                var urlString = "http://"
                urlString += selfInfo.objectForKey("ip") as! String
                urlString += "/led?r=\(redvalue)&g=\(greenvalue)&b=\(bluevalue)";
                
                let url = NSURL(string: urlString)
                let request = NSURLRequest(URL: url!)
                
                let session = NSURLSession.sharedSession()
                let task = session.dataTaskWithRequest(request, completionHandler:{_,_,_ in })
                task.resume()
                NSLog("request on %@", urlString)
            }
        }
    }
    override func reloadInputViews() {
        NSLog("reload input views")
        //refreshContents()
    }
    
    func watchFrameChanges() {
        NSLog("observing")
        if !isObserving {
            addObserver(self, forKeyPath: "frame", options: [NSKeyValueObservingOptions.New, NSKeyValueObservingOptions.Initial], context: nil)
            isObserving = true;
        }
    }
    
    func ignoreFrameChanges() {
        NSLog("un-observing")
        if isObserving {
            removeObserver(self, forKeyPath: "frame")
            isObserving = false;
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        //refreshContents()
        if keyPath == "frame" {
            refreshContents()
        }
    }
}