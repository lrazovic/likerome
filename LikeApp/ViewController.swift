//  ViewController.swift
//  LikeApp
//
//  Created by Leonardo Razovic on 18/10/17.
//  Copyright © 2017 Leonardo Razovic. All rights reserved.

import AlamofireImage
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, UITextFieldDelegate {

    fileprivate func setupApp() {
        buttonUi.layer.cornerRadius = 10
        buttonUi.frame.size = CGSize(width: 343, height: 45)
        hideKeyboardWhenTappedAround()
        definesPresentationContext = true
        urlField.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
        downloadedPhoto.addGestureRecognizer(longPressRecognizer)
    }

    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupApp()
        if (pasteboard.string?.range(of: "instagram")) != nil {
            urlString = pasteboard.string!
            urlField.insertText(String(urlString.prefix(40)))
        }
    }

    // MARK: Variables
    let pasteboard = UIPasteboard.general
    var urlString: String = ""
    let impGenerator = UIImpactFeedbackGenerator()
    let selGenerator = UISelectionFeedbackGenerator()


    // MARK: Outlets
    @IBOutlet var buttonUi: UIButton!
    @IBOutlet var urlField: UITextField!
    @IBOutlet var downloadedPhoto: UIImageView!
    @IBOutlet var locationText: UILabel!
    @IBOutlet var usernameText: UILabel!

    // MARK: Functions
    @IBAction func generateButton(_: UIButton) {
        impGenerator.impactOccurred()
        buttonPressed()
    }

    func textFieldShouldReturn(_: UITextField) -> Bool {
        view.endEditing(true)
        buttonPressed()
        return true
    }

    func buttonPressed() {
        hideKeyboardWhenTappedAround()
        if urlField.text!.contains("instagram") {
            let strURL = getUrl(url: urlField.text!)
            JSONWrapper.requestGETURL(strURL, success: {
                (JSONResponse) -> Void in
                if let url = URL(string: getPhoto(swiftyJsonVar: JSONResponse)) {
                    self.downloadedPhoto.af_setImage(withURL: url)
                }
                self.urlField.text = ""
                let location = getLocation(swiftyJsonVar: JSONResponse)
                self.locationText.text = location
                let username = getUsername(swiftyJsonVar: JSONResponse)
                self.usernameText.text = "👤 @" + username
                let finalDes = generateDescription(username: username, location: location)
                UIPasteboard.general.string = finalDes
            }) {
                (error) -> Void in
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
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
