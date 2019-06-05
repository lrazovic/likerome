//
//  Model.swift
//  LikeApp
//
//  Created by Leonardo Razovic on 23/10/2017.
//  Copyright © 2017 Leonardo Razovic. All rights reserved.
//

import SwiftyJSON
import Alamofire

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

func getLocation(swiftyJsonVar: JSON) -> String {
    let locationString = swiftyJsonVar["graphql"]["shortcode_media"]["location"]["name"].stringValue
    if locationString == "" { return "📍" + "Non Impostata" }
    else { return "📍" + locationString }
}

func getPhoto(swiftyJsonVar: JSON) -> String {
    return swiftyJsonVar["graphql"]["shortcode_media"]["display_url"].stringValue
}

func getUrl(url: String) -> String {
    return url + "?__a=1"
    // return urlField.text! + "?__a=1"
}

func getUsername(swiftyJsonVar: JSON) -> String {
    return swiftyJsonVar["graphql"]["shortcode_media"]["owner"]["username"].stringValue
}

func getRightDesc(username: String, location: String) -> String {
    return "\(location)\n📸 @\(username)\n—\nhashtag: #likerome\n—\n" + Array(Set(randomSelectHashtags(hashtagsToChoose: hashtagsArray))).joined(separator: " ")
}

func generateDescription(username: String, location: String) -> String {
    return getRightDesc(username: username, location: location)

}
