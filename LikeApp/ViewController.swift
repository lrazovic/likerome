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
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
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
        print()
        setupApp()
    }

    // MARK: Variables
    let pasteboard = UIPasteboard.general
    var urlString: String = ""
    var player: AVAudioPlayer?
    let impGenerator = UIImpactFeedbackGenerator()
    let selGenerator = UISelectionFeedbackGenerator()
    let hashtagsArray = ["#roma","#rome","#ig_roma", "#ig_rome","#igersroma","#igerslazio","#igersitalia","#igers_italia","#romanity","#vatican","#noidiroma","#yallerslazio","#visit_rome","#total_italy","#italiainunoscatto","#likeitaly" ,"#loves_roma","#wheninrome","#whatitalyis","#rome_rooftops","#WorldCaptures","#BeautifulDestinations","#PassionPassport","#bellaroma", "#instaitalia","#thediscoverer"]

    // MARK: Outlets
    @IBOutlet var buttonUi: UIButton!
    @IBOutlet var urlField: UITextField!
    @IBOutlet var downloadedPhoto: UIImageView!
    @IBOutlet var locationText: UILabel!
    @IBOutlet var usernameText: UILabel!

    // MARK: User Interface
    func setUI() {

        // Button
        buttonUi.layer.cornerRadius = 10
        buttonUi.frame.size = CGSize(width: 343, height: 45)

        // Keyboard
        hideKeyboardWhenTappedAround()
    }

    // MARK: Functions
    @IBAction func generateButton(_: UIButton) {
        impGenerator.impactOccurred()
        buttonPressed()
    }

    func randomSelectHashtags(hashtags: [String]) -> [String]{
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
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            if let data = data {
                _ = UIImage(data: data)
                DispatchQueue.main.async {
                    self.downloadedPhoto.contentMode = .scaleAspectFill
                    self.downloadedPhoto.clipsToBounds = true
                    self.downloadedPhoto.isUserInteractionEnabled = true
                    self.downloadedPhoto.image = UIImage(data: data)
                    self.playSound(name: "complete")
                }
            }
        }).resume()
    }

    func generateDescription(swiftyJsonVar: JSON, location: String) {
        let ret: String = getRightDesc(username: getUsername(swiftyJsonVar: swiftyJsonVar), location: location)
        UIPasteboard.general.string = ret
        print(ret)
    }

    func getRightDesc(username: String, location: String) -> String {
        return "\(location)\n📸 Foto di @\(username)\n-\nSeguici su ➡️ @likerome\n-\nTag:#️⃣ #likerome\n-\n\n" + Array(Set(randomSelectHashtags(hashtags: hashtagsArray))).joined(separator: " ")
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
                print(error)
            }
        }
    }

    func getLocation(swiftyJsonVar: JSON) -> String {
        let locationString = swiftyJsonVar["graphql"]["shortcode_media"]["location"]["name"].stringValue
        if locationString == "" { return "📍" + "Non Impostata" }
        else { return "📍" + locationString }
    }

    func playSound(name: String) {
        guard let sound = Bundle.main.url(forResource: name, withExtension: "m4a") else { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(contentsOf: sound, fileTypeHint: AVFileType.m4a.rawValue)
            guard let player = player else { return }
            player.play()
        } catch let error {
            print(error.localizedDescription)
        }
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
