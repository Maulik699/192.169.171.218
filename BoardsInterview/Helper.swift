//
//  Helper.swift
//  CPO
//
//  Created by Maulik Vekariya on 03/06/16.
//  Copyright © 2016 Maulik Vekariya. All rights reserved.
//

import UIKit

class Helper: NSObject {

    
    static func getValueFromPlist (plistName:String,key:String) -> String
    {
    
        let pathTitle = Bundle.main.path(forResource: plistName, ofType: "plist")
        let dictSetting = NSDictionary(contentsOfFile: pathTitle!)
        let ret_title = dictSetting?.object(forKey: key) as! String;
        
        return ret_title
    }
    
}
