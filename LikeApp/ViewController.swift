//
//  ViewController.swift
//  LikeApp
//
//  Created by Leonardo Razovic on 18/10/17.
//  Copyright © 2017 Leonardo Razovic. All rights reserved.
//

import Alamofire
import AVFoundation
import SwiftyJSON

class ViewController: UIViewController, UITextFieldDelegate {

    fileprivate func setupApp() {
        setUI()
        definesPresentationContext = true
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
        downloadedPhoto.addGestureRecognizer(longPressRecognizer)
        urlField.delegate = self
        if (pasteboard.string?.range(of: "instagram")) != nil {
            urlString = pasteboard.string!
            urlField.insertText(String(urlString.prefix(40)))
        }
    }

    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupApp()
    }

    // MARK: Variables
    let pasteboard = UIPasteboard.general
    var urlString: String = ""
    let impGenerator = UIImpactFeedbackGenerator()
    let selGenerator = UISelectionFeedbackGenerator()
    let hashtagsArray = ["#roma", "#rome", "#ig_roma", "#ig_rome", "#igersroma", "#igerslazio", "#igersitalia", "#igers_italia", "#romanity", "#vatican", "#noidiroma", "#yallerslazio", "#visit_rome", "#total_italy", "#italiainunoscatto", "#likeitaly", "#loves_roma", "#wheninrome", "#whatitalyis", "#rome_rooftops", "#WorldCaptures", "#BeautifulDestinations", "#PassionPassport", "#bellaroma", "#instaitalia", "#thediscoverer", "#voyaged"]

    // MARK: Outlets
    @IBOutlet var buttonUi: UIButton!
    @IBOutlet var urlField: UITextField!
    @IBOutlet var downloadedPhoto: UIImageView!
    @IBOutlet var locationText: UILabel!
    @IBOutlet var usernameText: UILabel!

    // MARK: User Interface
    func setUI() {
        buttonUi.layer.cornerRadius = 10
        buttonUi.frame.size = CGSize(width: 343, height: 45)
        hideKeyboardWhenTappedAround()
    }

    // MARK: Functions
    @IBAction func generateButton(_: UIButton) {
        impGenerator.impactOccurred()
        buttonPressed()
    }

    func randomSelectHashtags(hashtags: [String]) -> [String] {
        var ret = [String]()
        for _ in 0...hashtags.count {
            ret.append(hashtags.randomElement()!)
        }
        return ret
    }

    func textFieldShouldReturn(_: UITextField) -> Bool {
        view.endEditing(true)
        buttonPressed()
        return true
    }

    func getPhoto(swiftyJsonVar: JSON) -> String {
        return swiftyJsonVar["graphql"]["shortcode_media"]["display_url"].stringValue
    }

    func getUrl() -> String {
        return urlField.text! + "?__a=1"
    }

    func getUsername(swiftyJsonVar: JSON) -> String {
        return swiftyJsonVar["graphql"]["shortcode_media"]["owner"]["username"].stringValue
    }

    func downloadImage(url: URL) {
        Alamofire.request(url).responseData { response in
            if let data = response.result.value {
                self.downloadedPhoto.image = UIImage(data: data)
                self.downloadedPhoto.layer.cornerRadius = 8.0
            }
        }
    }

    func generateDescription(swiftyJsonVar: JSON, location: String) {
        let ret: String = getRightDesc(username: getUsername(swiftyJsonVar: swiftyJsonVar), location: location)
        UIPasteboard.general.string = ret
    }

    func getRightDesc(username: String, location: String) -> String {
        return "\(location)\n📸 @\(username)\n—\nhashtag: #likerome\n—\n" + Array(Set(randomSelectHashtags(hashtags: hashtagsArray))).joined(separator: " ")
    }

    func buttonPressed() {
        hideKeyboardWhenTappedAround()
        if urlField.text!.contains("instagram") {
            let strURL = getUrl()
            JSONWrapper.requestGETURL(strURL, success: {
                (JSONResponse) -> Void in
                if let url = URL(string: self.getPhoto(swiftyJsonVar: JSONResponse)) {
                    self.downloadImage(url: url)
                }
                self.urlField.text = ""
                let location = self.getLocation(swiftyJsonVar: JSONResponse)
                self.locationText.text = location
                self.usernameText.text = "👤 @" + self.getUsername(swiftyJsonVar: JSONResponse)
                self.generateDescription(swiftyJsonVar: JSONResponse, location: location)
            }) {
                (error) -> Void in
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    func getLocation(swiftyJsonVar: JSON) -> String {
        let locationString = swiftyJsonVar["graphql"]["shortcode_media"]["location"]["name"].stringValue
        if locationString == "" { return "📍" + "Non Impostata" }
        else { return "📍" + locationString }
    }

    @objc func willEnterForeground() {
        if (pasteboard.string?.range(of: "instagram")) != nil {
            urlString = pasteboard.string!
            urlField.insertText(String(urlString.prefix(40)))
        }
    }

    @objc func longPressed(sender _: UILongPressGestureRecognizer) {
        if downloadedPhoto.image != nil {
            let vc = UIActivityViewController(activityItems: [self.downloadedPhoto.image!], applicationActivities: nil)
            present(vc, animated: true)
        }
    }
}

extension Collection where Index == Int {
    func randomElement() -> Iterator.Element? {
        return isEmpty ? nil : self[Int(arc4random_uniform(UInt32(endIndex)))]
    }
}
