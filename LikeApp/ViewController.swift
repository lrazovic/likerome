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

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
        downloadedPhoto.addGestureRecognizer(longPressRecognizer)
        setUI()
        cityPicker.dataSource = self
        cityPicker.delegate = self
        urlField.delegate = self
        if (pasteboard.string?.range(of: "instagram")) != nil {
            urlString = pasteboard.string!
            urlField.insertText(urlString)
        }
    }

    // MARK: Variables
    let pickerData = ["Torino", "Roma", "Milano", "Bologna", "Napoli"]
    let pasteboard = UIPasteboard.general
    var urlString: String = ""
    var pickedCity: String = ""
    var player: AVAudioPlayer?

    // MARK: Outlets
    @IBOutlet var buttonUi: UIButton!
    @IBOutlet var urlField: UITextField!
    @IBOutlet var cityPicker: UIPickerView!
    @IBOutlet var downloadedPhoto: UIImageView!
    @IBOutlet var locationText: UILabel!

    // MARK: Functions
    @IBAction func generateButton(_: UIButton) {
        buttonPressed()
    }

    func numberOfComponents(in _: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_: UIPickerView, numberOfRowsInComponent _: Int) -> Int {
        return pickerData.count
    }

    func pickerView(_: UIPickerView, titleForRow row: Int, forComponent _: Int) -> String? {
        pickedCity = pickerData[row]
        return pickerData[row] as String
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

    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
        }.resume()
    }

    func downloadImage(url: URL) {
        getDataFromUrl(url: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            DispatchQueue.main.async {
                self.downloadedPhoto.contentMode = .scaleAspectFill
                self.downloadedPhoto.frame = CGRect(x: 0, y: 0, width: 320, height: 320)
                self.downloadedPhoto.layer.cornerRadius = 24
                self.downloadedPhoto.clipsToBounds = true
                self.downloadedPhoto.isUserInteractionEnabled = true
                self.setShadow()
                self.downloadedPhoto.image = UIImage(data: data)
            }
        }
        playSound(name: "complete")
    }

    @objc func longPressed(sender _: UILongPressGestureRecognizer) {
        if downloadedPhoto.image != nil {
            let shareText = ""
            let vc = UIActivityViewController(activityItems: [shareText, self.downloadedPhoto.image!], applicationActivities: [])
            present(vc, animated: true, completion: nil) } else { return }
    }

    func generateDescription(swiftyJsonVar: JSON) {
        let ret: String = getRightDesc(pickedCity: pickedCity, username: getUsername(swiftyJsonVar: swiftyJsonVar))
        UIPasteboard.general.string = ret
    }

    func getRightDesc(pickedCity: String, username: String) -> String {
        switch pickedCity {
        case "Roma":
            return "📍 Roma\n📸 Foto di @\(username)\n-\nSeguici su ➡️ @likerome\n-\nTag:#️⃣ #likerome\n-\n\n#roma #igerslazio #igersroma #ig_rome #volgoroma #noidiroma #unlimitedrome #ilmegliodiroma #yallerslazio #visit_rome #igersitalia #ig_europe #igers_italia #total_italy #noidiroma #italiainunoscatto #likeitaly #TheGlobeWanderer"
        case "Torino":
            return "📍 Torino\n📸 Foto di @\(username)\n-\nSeguici su ➡️ @liketorino\n-\nTag: #liketorino 🔖 Selezionata da: @claudiostoduto\n-\n\n#ig_piemonte #liketorino #ig_piedmont #bestpiemontepics #instaitalia #igersitaly #italiainunoscatto #loves_madeinitaly #bellaitalia #visititalia #lavitainunoscatto #italy_photolovers #borghitalia #bestitaliapics #igers_italia #total_italy #torinoèlamiacittà #torino #cittàditorino"
        case "Milano":
            return "📍 Milano\n📸 Foto di @\(username)\n-\nSeguici su ➡️ @likemilano\n-\nTag:#️⃣ #likemilano\n-\n\n#torino #igerslazio #igersroma #ig_rome #volgoroma #noidiroma #unlimitedrome #ilmegliodiroma #yallerslazio #visit_rome #igersitalia #ig_europe #igers_italia #total_italy #noidiroma #italiainunoscatto #likeitaly #TheGlobeWanderer"
        case _:
            return "Altra Citta"
        }
    }

    func buttonPressed() {
        // Levo la tastiera
        hideKeyboardWhenTappedAround()

        if urlField.text!.contains("instagram") {
            let url = getUrl()
            Alamofire.request(url).validate().responseJSON { response in
                switch response.result {
                case .success:
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
                    self.playSound(name: "done")
                case .failure:
                    self.playSound(name: "error")
                    let alert = UIAlertController(title: "URL Instagram non valido!", message: "Inserisci un URL valido", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Riprova"), style: .default, handler: { _ in
                        NSLog("The \"OK\" alert occured.")
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
        guard let url = Bundle.main.url(forResource: name, withExtension: "m4a") else { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.m4a.rawValue)
            guard let player = player else { return }
            player.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }

    func setUI() {
        // Button
        buttonUi.layer.cornerRadius = 10
        buttonUi.center = view.center

        // Picker
        cityPicker.center = view.center

        // Image

        // Keyboard
        hideKeyboardWhenTappedAround()
    }

    func setShadow() {
        downloadedPhoto.layer.shadowOpacity = 0.45
        downloadedPhoto.layer.shadowRadius = 8
        downloadedPhoto.layer.shadowOffset = CGSize(width: 0, height: 2)
    }
}
