//
//  AboutViewController.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 3/28/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import UIKit
import MessageUI

protocol AboutDelegate: AnyObject {
    func showDevView()
}

class AboutViewController: UIViewController {
    @IBOutlet weak var parentView: UIView!
    @IBOutlet weak var textContainer: UIView!
    @IBOutlet weak var videoButton: SynthButton!
    @IBOutlet weak var reviewButton: SynthButton!
    @IBOutlet weak var githubButton: SynthButton!
    @IBOutlet weak var mainTextView: UITextView!
    @IBOutlet weak var webButton: SynthButton!
    weak var delegate: AboutDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide popup at first
        parentView.alpha = 0
        textContainer.alpha = 0
        
        // Border of Popup
        textContainer.layer.borderColor = #colorLiteral(red: 0.09411764706, green: 0.09411764706, blue: 0.09411764706, alpha: 1)
        textContainer.layer.borderWidth = 2
        textContainer.layer.cornerRadius = 8

        // callbacks
        setupCallbacks()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // layout
        self.mainTextView.setContentOffset(.zero, animated: false)
        
        // Fade in About Box
        UIView.animate(withDuration: 1, animations: {
            self.parentView.alpha = 1.0
        })
        UIView.animate(withDuration: 1.5, animations: {
            self.textContainer.alpha = 1.0
        })
    }
    
    func setupCallbacks() {

        // github
        githubButton.setValueCallback = { _ in
            self.githubButton.value = 0
            if Conductor.sharedInstance.device == .phone {
                self.emailSend()
            } else {
                if let url = URL(string: "https://github.com/AudioKit/") {
                    UIApplication.shared.open(url)
                }
            }
        }

        // video
        videoButton.setValueCallback = { _ in
            self.videoButton.value = 1
            if let url = URL(string: "http://youtu.be/hwDNgCYowYs") {
                UIApplication.shared.open(url)
            }
        }

        // web
        webButton.setValueCallback = { _ in
            self.webButton.value = 0
            if let url = URL(string: "https://audiokitpro.com/synth") {
                UIApplication.shared.open(url)
            }
        }

        // reviews
        reviewButton.setValueCallback = { _ in
            self.reviewButton.value = 0
            self.requestReview()
            if let url = URL(string:
                "https://itunes.apple.com/us/app/audiokit-synth-one-synthesizer/id1371050497?ls=1&mt=8") {
                UIApplication.shared.open(url)
            }
        }
    }
    
    // MARK: - IB Actions
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func closePressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func devViewPressed(_ sender: UIButton) {
        delegate?.showDevView()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func emailPressed(_ sender: UIButton) {
        emailSend()
    }
    
    func emailSend() {
        let receipients = ["hello@audiokitpro.com"]
        let subject = "From AudioKit Synth App"
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

// MARK: - MFMailComposeViewController Delegate

extension AboutViewController: MFMailComposeViewControllerDelegate {
    
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
