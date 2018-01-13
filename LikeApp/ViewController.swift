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
import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
        downloadedPhoto.addGestureRecognizer(longPressRecognizer)
        setUI()
        urlField.delegate = self
        if (pasteboard.string?.range(of: "instagram")) != nil {
            urlString = pasteboard.string!
            urlField.insertText(urlString)
        }
    }

    // MARK: Variables
    let pasteboard = UIPasteboard.general
    var urlString: String = ""
    var player: AVAudioPlayer?
    let impGenerator = UIImpactFeedbackGenerator()
    let selGenerator = UISelectionFeedbackGenerator();
    
    // MARK: Outlets
    @IBOutlet var buttonUi: UIButton!
    @IBOutlet var urlField: UITextField!
    @IBOutlet var downloadedPhoto: UIImageView!
    @IBOutlet var locationText: UILabel!
    @IBOutlet var usernameText: UILabel!
    
    // MARK: Functions
    @IBAction func generateButton(_: UIButton) {
        buttonPressed()
        impGenerator.impactOccurred()
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
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let data = data {
                _ = UIImage(data: data)
                DispatchQueue.main.async {
                    self?.downloadedPhoto.contentMode = .scaleAspectFill
                    self?.downloadedPhoto.clipsToBounds = true
                    self?.downloadedPhoto.isUserInteractionEnabled = true
                    self?.downloadedPhoto.image = UIImage(data: data)
                    self?.playSound(name: "complete")
                }
            }
        }.resume()
    }
    

    @objc func longPressed(sender _: UILongPressGestureRecognizer) {
        if downloadedPhoto.image != nil {
            let vc = UIActivityViewController(activityItems: [self.downloadedPhoto.image!], applicationActivities: nil)
            present(vc, animated: true)
        }
    }

    func generateDescription(swiftyJsonVar: JSON) {
        let ret: String = getRightDesc(username: getUsername(swiftyJsonVar: swiftyJsonVar))
        UIPasteboard.general.string = ret
    }

    func getRightDesc(username: String) -> String {
        return "📍 Roma\n📸 Foto di @\(username)\n-\nSeguici su ➡️ @likerome\n-\nTag:#️⃣ #likerome\n-\n\n#roma #rome" +
        "#ig_roma #ig_rome #igersroma #igerslazio #igersitalia #igers_italia #romanity #vatican #noidiroma #yallerslazio" +
        "#visit_rome #total_italy #italiainunoscatto #likeitaly #loves_roma #wheninrome #whatitalyis #sfs"
    }

    func buttonPressed() {
        // Levo la tastiera
        hideKeyboardWhenTappedAround()

        if urlField.text!.contains("instagram") {
            let url = getUrl()
            Alamofire.request(url).validate().responseJSON { response in
                switch response.result {
                case .success:

                    // Pulisco l'URL
                    self.urlField.text = ""

                    // Scarico JSON
                    let swiftyJsonVar = JSON(response.result.value!)

                    // Genero la Descrcizione
                    self.generateDescription(swiftyJsonVar: swiftyJsonVar)

                    // Scarico la Foto e la inserisco nella UI
                    if let url = URL(string: self.getPhoto(swiftyJsonVar: swiftyJsonVar)) {
                        self.downloadImage(url: url)
                    }

                    // Scrivo il Geotag
                    self.locationText.text = self.getLocation(swiftyJsonVar: swiftyJsonVar)
                    
                    // Scrivo l'Username
                    self.usernameText.text = "👤 @" + self.getUsername(swiftyJsonVar: swiftyJsonVar)
                    
                    self.playSound(name: "done")

                case .failure:
                    self.playSound(name: "error")
                    let alert = UIAlertController(title: "URL Instagram non valido!", message: "Inserisci un URL valido", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Riprova"), style: .default, handler: { _ in
                        //NSLog("The \"OK\" alert occured.")
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        } else {
            self.playSound(name: "error")
            let alert = UIAlertController(title: "URL non valido!", message: "Inserisci un URL valido", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Riprova"), style: .default, handler: { _ in
                NSLog("The \"OK\" alert occured.")
            }))
            present(alert, animated: true, completion: nil)
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

    func setUI() {

        // Button
        buttonUi.layer.cornerRadius = 10
        buttonUi.frame.size = CGSize(width: 343, height: 45)

        // Keyboard
        hideKeyboardWhenTappedAround()
    }

    func setShadow() {
        downloadedPhoto.layer.shadowOpacity = 0.45
        downloadedPhoto.layer.shadowRadius = 8
        downloadedPhoto.layer.shadowOffset = CGSize(width: 0, height: 2)
    }

    @objc func willEnterForeground() {
        if (pasteboard.string?.range(of: "instagram")) != nil {
            urlString = pasteboard.string!
            urlField.insertText(urlString)
        }
    }
}
