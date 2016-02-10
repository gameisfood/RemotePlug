//
//  AddNewController.swift
//  RemotePlug
//
//  Created by Sidharth Agarwal on 1/24/16.
//  Copyright © 2016 Sidharth Agarwal. All rights reserved.
//

import Foundation
import UIKit

class AddNewController : UIViewController,UIPickerViewDataSource,UIPickerViewDelegate {
    @IBOutlet weak var typePicker: UIPickerView!
    @IBOutlet weak var ipField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    let pickerData = ["Button", "Switch", "RGB LED"]
    override func viewDidLoad() {
        super.viewDidLoad()
        typePicker.dataSource = self
        typePicker.delegate = self
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    func convertToTextFromIndex(row : Int) -> String? {
        return pickerData[row]
    }
    /*
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        myLabel.text = pickerData[row]
    }*/
    
    @IBAction func Cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {});
    }
    @IBAction func doneClicked(sender: AnyObject) {
        let saved = NSUserDefaults.standardUserDefaults()
        let dict:NSArray? = saved.arrayForKey("saved")
        var mutableDict:NSMutableArray = NSMutableArray()
        if dict == nil {
            
        }
        else {
            mutableDict = dict?.mutableCopy() as! NSMutableArray
        }/*
        if dict!.count == 0 {
            //mutableDict
        }
        else {
            mutableDict = dict as! NSMutableArray
        }*/
        let newElem:NSMutableDictionary = NSMutableDictionary()
        newElem["name"] = nameField.text
        newElem["ip"] = ipField.text
        newElem["type"] = pickerData[typePicker.selectedRowInComponent(0)]
        NSLog(pickerData[typePicker.selectedRowInComponent(0)])
        mutableDict.addObject(newElem)
        saved.setObject(mutableDict, forKey: "saved")
        self.dismissViewControllerAnimated(true, completion: {});
    }
}