//
//  JSONWrapper.swift
//  LikeApp
//
//  Created by Leonardo Razovic on 03/04/18.
//  Copyright © 2018 Leonardo Razovic. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class JSONWrapper: NSObject {
    class func requestGETURL(_ strURL: String, success: @escaping (JSON) -> Void, failure: @escaping (Error) -> Void) {
        AF.request(strURL).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let resJson = JSON(value)
                success(resJson)
            case .failure(let error):
                failure(error)
            }
        }
    }
    
}
