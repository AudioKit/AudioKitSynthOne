//
//  PopUpAbout.swift
//  AudioKitSynthOne
//
//  Created by Matthew Fecher on 3/28/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import UIKit
//import MessageUI

class PopUpAbout: UIViewController {
    
    @IBOutlet weak var parentView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        parentView.layer.borderColor = #colorLiteral(red: 0.09411764706, green: 0.09411764706, blue: 0.09411764706, alpha: 1)
        parentView.layer.borderWidth = 4
        parentView.layer.cornerRadius = 6
    }
    
    @IBAction func closePressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func audioKitPressed(_ sender: UIButton) {
        if let url = URL(string: "http://audiokitpro.com/audiokit/") {
            UIApplication.shared.open(url)
        }
    }
    
/*
    @IBAction func emailPressed(_ sender: UIButton) {
        
        let receipients = ["matthew@audiokitpro.com"]
        let subject = "From AudioKit Synth One"
        let messageBody = ""
        
        let configuredMailComposeViewController = configureMailComposeViewController(recepients: receipients, subject: subject, messageBody: messageBody)
        
        if canSendMail() {
            self.present(configuredMailComposeViewController, animated: true, completion: nil)
        } else {
            showSendMailErrorAlert()
        }
    }
*/
    
    @IBAction func website(_ sender: UIButton) {
        if let url = URL(string: "http://audiokitpro.com") {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func reviewAppPressed(_ sender: UIButton) {
        requestReview()
    }
    
}

//*****************************************************************
// MARK: - MFMailComposeViewController Delegate
//*****************************************************************

/*
extension PopUpAbout: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func canSendMail() -> Bool {
        return MFMailComposeViewController.canSendMail()
    }
    
    func configureMailComposeViewController(recepients: [String], subject: String, messageBody: String) -> MFMailComposeViewController {
        
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setToRecipients(recepients)
        mailComposerVC.setSubject(subject)
        mailComposerVC.setMessageBody(messageBody, isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertController(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        
        sendMailErrorAlert.addAction(cancelAction)
        present(sendMailErrorAlert, animated: true, completion: nil)
    }
}
*/
