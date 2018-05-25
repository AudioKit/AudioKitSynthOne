//
//  MailingList.swift
//  FMPlayer
//
//  Created by Matthew Fecher on 11/26/17.
//  Copyright © 2017 AudioKit Pro. All rights reserved.
//

import UIKit
import ChimpKit

protocol MailingListDelegate {
    func didSignMailingList(email: String)
}

class MailingListController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var moreView: UIView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!

    var delegate: MailingListDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        moreView.layer.borderColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
        moreView.layer.borderWidth = 2
        moreView.layer.cornerRadius = 6

        emailField.delegate = self

        // add notification for when keyboard appears
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWasShown(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)

        // MailChimp API Key
        ChimpKit.shared().apiKey = "***REMOVED***"
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        signUpAction()
        return false
    }

    @objc func keyboardWasShown(notification: NSNotification) {
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.topConstraint.constant = 100
        })
    }

    @IBAction func closePressed(_ sender: UIButton) {

        // Add pop up
        let alert = UIAlertController(title: "Important",
                                      message: "You will receive all the presets in this app for FREE after you enter your real email address.",
                                      preferredStyle: .alert)
        let submitAction = UIAlertAction(title: "WAIT! Take me back 👍🏼", style: .default) { (_) in

        }

        let cancelAction = UIAlertAction(title: "Later", style: .default) { (_) in
            self.dismiss(animated: true, completion: nil)
        }

        alert.addAction(submitAction)
        alert.addAction(cancelAction)

        self.present(alert, animated: true, completion: nil)

    }

    @IBAction func signUpPressed(_ sender: UIButton) {
        signUpAction()
    }

    func signUpAction() {
        guard let emailAddress = emailField.text else { return }

        guard emailAddress.isEmail else {
            displayAlertController("Oops!", message: "🎹 Please enter your real email address so that you can receive all the presets for free. Thank you.")
            return
        }

        // Add pop up
        let alert = UIAlertController(title: "Almost Done",
                                      message: "To receive your free presets,\n please confirm that \n\n'\(emailAddress)' \n\n is your correct email address?",
            preferredStyle: .alert)
        let submitAction = UIAlertAction(title: "Yes, that is correct 👍🏼", style: .default) { (_) in

            // Send to MailChimp
            let mailToSubscribe: [String: AnyObject] = ["email": emailAddress as AnyObject]
            let params: [String: AnyObject] = ["id": "***REMOVED***" as AnyObject, "email": mailToSubscribe as AnyObject, "double_optin": false as AnyObject]
            ChimpKit.shared().callApiMethod("lists/subscribe", withParams: params, andCompletionHandler: {(response, data, _) -> Void in
                if let httpResponse = response as? HTTPURLResponse {
                    NSLog("Reponse status code: %d", httpResponse.statusCode)
                    let datastring = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    print (datastring ?? "error with MailChimp response")
                }
            })
            self.delegate?.didSignMailingList(email: emailAddress)
            self.emailSubmitted()
        }

        let cancelAction = UIAlertAction(title: "Oops, Go back", style: .default) { (_) in
        }

        alert.addAction(submitAction)
        alert.addAction(cancelAction)

        self.present(alert, animated: true, completion: nil)
    }

    func emailSubmitted() {

        // Create and display alert box
        let alert = UIAlertController(title: "Congrats! 🎉", message: "All the presets have been unlocked. We are all volunteers who made this app for free. We hope you enjoy it & tell other musicians! 😎", preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Thanks!", style: .default) { _ in

            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(action)

        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func laterPressed(_ sender: UIButton) {
    }

    @IBAction func learnMorePressed(_ sender: Any) {

        if let url = URL(string: "https://audiokitpro.com/audiokit-synth-one/") {
            UIApplication.shared.open(url)
        }
    }

}

// MARK: String/Email validation extensions

extension String {

    //To check text field or String is blank or not
    var isBlank: Bool {
        get {
            let trimmed = trimmingCharacters(in: CharacterSet.whitespaces)
            return trimmed.isEmpty
        }
    }

    //Validate Email

    var isEmail: Bool {
        do {
            let regex = try NSRegularExpression(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}", options: .caseInsensitive)
            return regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSRange(location: 0, length: self.count)) != nil
        } catch {
            return false
        }
    }

    var isAlphanumeric: Bool {
        return !isEmpty && range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
    }

    //validate Password
    var isValidPassword: Bool {
        do {
            let regex = try NSRegularExpression(pattern: "^[a-zA-Z_0-9\\-_,;.:#+*?=!§$%&/()@]+$", options: .caseInsensitive)
            if(regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSRange(location: 0, length: self.count)) != nil) {

                if(self.count >= 6 && self.count <= 20) {
                    return true
                } else {
                    return false
                }
            } else {
                return false
            }
        } catch {
            return false
        }
    }
}
