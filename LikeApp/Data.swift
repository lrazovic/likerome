//
//  Data.swift
//  Likerome
//
//  Created by Leonardo Razovic on 05/06/2019.
//  Copyright © 2019 Leonardo Razovic. All rights reserved.
//

import Foundation

let hashtagsArray = ["#roma", "#rome", "#ig_roma", "#ig_rome", "#igersroma", "#igersitalia", "#vatican", "#noidiroma", "#yallerslazio", "#visitrome", "#total_italy", "#italiainunoscatto", "#likeitaly", "#loves_roma", "#wheninrome", "#whatitalyis", "#WorldCaptures", "#BeautifulDestinations", "#PassionPassport", "#instaitalia", "#thediscoverer", "#voyaged", "#igerslazio", "#volgoroma", "#romanity", "#italia", "#italy", "#instagood", "#photooftheday", "#repost", "#vscocam", "#colosseo", "#traveling", "#architecture", "#history"]

func randomSelectHashtags(hashtagsToChoose: [String]) -> [String] {
    var seed = hashtagsToChoose
    var hashtags = [String]()
    for _ in 0...25 {
        let element = seed.randomElement()!
        hashtags.append(element)
        if let index = seed.firstIndex(of: element) {
            seed.remove(at: index)
        }
    }
    return hashtags
}

extension Collection where Index == Int {
    func randomElement() -> Iterator.Element? {
        return isEmpty ? nil : self[Int(arc4random_uniform(UInt32(endIndex)))]
    }
}
