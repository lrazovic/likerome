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
        Alamofire.request(strURL).validate().responseJSON { (responseObject) -> Void in

            if responseObject.result.isSuccess {
                let resJson = JSON(responseObject.result.value!)
                success(resJson)
            }
            if responseObject.result.isFailure {
                let error: Error = responseObject.result.error!
                failure(error)
            }
        }
    }

}
