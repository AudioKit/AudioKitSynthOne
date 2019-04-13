//
//  MailingListViewController.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 11/26/17.
//  Copyright © 2017 AudioKit Pro. All rights reserved.
//

import UIKit
import ChimpKit
import MessageUI

protocol MailingListDelegate: AnyObject {
    func didSignMailingList(email: String)
}

class MailingListViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var moreView: UIView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!

    weak var delegate: MailingListDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Hide popup at first
        moreView.alpha = 0

        moreView.layer.borderColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
        moreView.layer.borderWidth = 2
        moreView.layer.cornerRadius = 6

        emailField.delegate = self

        // add notification for when keyboard appears
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWasShown(notification:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)

        // MailChimp API Key
        guard Private.MailChimpAPIKey != "***REMOVED***" else { return }
        ChimpKit.shared().apiKey = Private.MailChimpAPIKey
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Fade in About Box
        UIView.animate(withDuration: 1.5, animations: {
            self.moreView.alpha = 1.0
        })
    }
    
    // Hide home bar on newer iPhones/iPad
    override public var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        signUpAction()
        return false
    }

    @objc func keyboardWasShown(notification: NSNotification) {
        guard Conductor.sharedInstance.device == .pad else { return }
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.topConstraint.constant = 100
        })
    }
    
    @IBAction func videoPressed(_ sender: UIButton) {
        if let url = URL(string: "http://youtu.be/hwDNgCYowYs") {
            UIApplication.shared.open(url)
        }
        print("TOUCHED")
    }
    

    @IBAction func closePressed(_ sender: UIButton) {

        // Add pop up
        let alert = UIAlertController(title: "Important",
                                      message: "You will receive all the presets in this app " +
                                               "for FREE after you enter your real email address.",
                                      preferredStyle: .alert)
        let submitAction = UIAlertAction(title: "WAIT! Take me back 👍🏼", style: .default) { (_) in

        }

        let cancelAction = UIAlertAction(title: "Later", style: .default) { (_) in
            self.dismiss(animated: true, completion: nil)
        }

        alert.addAction(cancelAction)
        alert.addAction(submitAction)
    

        // Confirm they don't want to enter their email address
        // self.present(alert, animated: true, completion: nil)

        // Remove dismiss for the hard sell
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func startPlaying(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

    @IBAction func signUpPressed(_ sender: UIButton) {
        signUpAction()
    }
    
    @IBAction func sharePressed(_ sender: Any) {
       
        // set up activity view controller
        let items: [Any] = ["I love this app. AudioKit Synth One", URL(string: "https://audiokitpro.com/synth")!]
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop]
  
        if UIDevice.current.userInterfaceIdiom == .pad {
            activityViewController.popoverPresentationController?.sourceView = self.emailField
            activityViewController.popoverPresentationController?.permittedArrowDirections = .down
            activityViewController.popoverPresentationController?.sourceRect = self.emailField.bounds
        }
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    

    func signUpAction() {
        guard let emailAddress = emailField.text else { return }

        let title = NSLocalizedString("Oops!", comment: "Alert Title: Invalid Email Address")
        let message = NSLocalizedString("🎹 Please enter your real email address so that " +
            "you can receive all the presets for free. Thank you.", comment: "Alert Message: Invalid Email Address")
        guard emailAddress.isEmail else {
            displayAlertController(title, message: message)
            return
        }

        // Add pop up
        let alertTitle = NSLocalizedString("Almost done!", comment: "Alert Title: Confirm Email Address")
        let alertMessage = NSLocalizedString("Please confirm that " +
            " \n'\(emailAddress)' \n is your correct email address " +
            "and you consent to us emailing you?", comment: "Alert Message: Confirm Email Address")

        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        let submitAction = UIAlertAction(title: "Yes 👍🏼", style: .default) { (_) in

            // Send to MailChimp
            let mailToSubscribe: [String: AnyObject] = ["email": emailAddress as AnyObject]
            let params: [String: AnyObject] = ["id": Private.MailChimpID as AnyObject,
                                               "email": mailToSubscribe as AnyObject,
                                               "double_optin": false as AnyObject]
            
            // let userLanguage = NSLocale.current.languageCode
            
            ChimpKit.shared().callApiMethod("lists/subscribe", withParams: params) {(response, data, _) -> Void in
                if let httpResponse = response as? HTTPURLResponse {
                    NSLog("Reponse status code: %d", httpResponse.statusCode)
                    if let actualData = data {
                        let datastring = NSString(data: actualData, encoding: String.Encoding.utf8.rawValue)
                        AKLog(datastring ?? "error with MailChimp response")
                    }
                }
            }
            self.delegate?.didSignMailingList(email: emailAddress)
            self.emailSubmitted()
        }

        let cancelAction = UIAlertAction(title: "No", style: .default) { (_) in
        }

        alert.addAction(cancelAction)
        alert.addAction(submitAction)

        self.present(alert, animated: true, completion: nil)
    }

    func emailSubmitted() {

        // Create and display alert box
        let title = NSLocalizedString("Congratulations! 🎉", comment: "Alert Title: Presets Added")
        let message = NSLocalizedString("Bonus presets have been added to BankA. \n\n" +
            "We are all volunteers who made this app for free. " +
            "We hope you enjoy it & tell other musicians! 😎", comment: "Alert Message: Presets Added")
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: UIAlertController.Style.alert)
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
    
    @IBAction func emailPressed(_ sender: UIButton) {
        
        let receipients = ["matthew@audiokitpro.com"]
        let subject = "From AudioKit App"
        let messageBody = ""
        
        let configuredMailComposeViewController = configureMailComposeViewController(recepients: receipients,
                                                                                     subject: subject,
                                                                                     messageBody: messageBody)
        
        if canSendMail() {
            self.present(configuredMailComposeViewController, animated: true, completion: nil)
        } else {
            showSendMailErrorAlert()
        }
    }

}

// MARK: String/Email validation extensions

extension String {

    //To check text field or String is blank or not
    var isBlank: Bool {
        return trimmingCharacters(in: CharacterSet.whitespaces).isEmpty
    }

    //Validate Email

    var isEmail: Bool {
        do {
            let regex = try NSRegularExpression(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}",
                                                options: .caseInsensitive)
            return regex.firstMatch(in: self,
                                    options: NSRegularExpression.MatchingOptions(rawValue: 0),
                                    range: NSRange(location: 0, length: self.count)) != nil
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
            let regex = try NSRegularExpression(pattern: "^[a-zA-Z_0-9\\-_,;.:#+*?=!§$%&/()@]+$",
                                                options: .caseInsensitive)
            if regex.firstMatch(in: self,
                                options: NSRegularExpression.MatchingOptions(rawValue: 0),
                                range: NSRange(location: 0, length: self.count)) != nil {

                if self.count >= 6 && self.count <= 20 {
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

// MARK: - MFMailComposeViewController Delegate

extension MailingListViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func canSendMail() -> Bool {
        return MFMailComposeViewController.canSendMail()
    }
    
    func configureMailComposeViewController(recepients: [String],
                                            subject: String,
                                            messageBody: String) -> MFMailComposeViewController {
        
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setToRecipients(recepients)
        mailComposerVC.setSubject(subject)
        mailComposerVC.setMessageBody(messageBody, isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertController(title: "Could Not Send Email",
                                                   message: "Your device could not send e-mail.  " +
            "Please check e-mail configuration and try again.",
                                                   preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        
        sendMailErrorAlert.addAction(cancelAction)
        present(sendMailErrorAlert, animated: true, completion: nil)
    }
}
