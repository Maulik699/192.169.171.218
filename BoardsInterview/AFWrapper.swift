//
//  AFWrapper.swift
//  CPO
//
//  Created by Maulik Vekariya on 03/06/16.
//  Copyright © 2016 Maulik Vekariya. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class AFWrapper: NSObject
{
    
    class func requesting(methodRequest: HTTPMethod, URLString: URLConvertible, parameters: [String: AnyObject]? = nil,onSuccess: @escaping (AnyObject) -> (),onFailure: @escaping (NSError) -> ()) -> Void
    {
        let headerss = ["Content-Type": "application/x-www-form-urlencoded"]

        
        Alamofire.request(URLString, method: methodRequest, parameters: parameters, headers: headerss).responseJSON
        {
                (response:DataResponse<Any>) in
                
                switch(response.result)
                {
                case .success(_):
                    if let data = response.result.value
                    {
                        let response = data as! NSDictionary
                        debugPrint(response)
                        onSuccess (response)
                    }
                    break
                    
                case .failure(_):
                    print(response.result.error!)
                    let error = response.result.error! as NSError
                    onFailure (error);

                    break
                    
                }
        }
        
        
    }
    
    
}
