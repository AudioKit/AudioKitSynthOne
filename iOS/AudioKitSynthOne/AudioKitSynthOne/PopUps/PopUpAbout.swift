//
//  PopUpAbout.swift
//  AudioKitSynthOne
//
//  Created by Matthew Fecher on 3/28/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import UIKit
import MessageUI

protocol AboutDelegate: AnyObject {
    func showDevPanel()
}

class PopUpAbout: UIViewController {

    @IBOutlet weak var parentView: UIView!
    @IBOutlet weak var textContainer: UIView!
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

        // background image
        // view.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Fade in About Box
        UIView.animate(withDuration: 2, animations: {
            self.parentView.alpha = 1.0
        })

        UIView.animate(withDuration: 4, animations: {
            self.textContainer.alpha = 1.0
        })
    }

    //*****************************************************************
    // MARK: - IB Actions
    //*****************************************************************

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        dismiss(animated: true, completion: nil)
    }

    @IBAction func closePressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func audioKitPressed(_ sender: UIButton) {
        if let url = URL(string: "http://audiokitpro.com/") {
            UIApplication.shared.open(url)
        }
    }

    @IBAction func githubPressed(_ sender: UIButton) {
        if let url = URL(string: "https://github.com/AudioKit/") {
            UIApplication.shared.open(url)
        }
    }

    @IBAction func reviewAppPressed(_ sender: UIButton) {
        requestReview()
    }

    @IBAction func devPanelPressed(_ sender: UIButton) {
        delegate?.showDevPanel()
        dismiss(animated: true, completion: nil)
    }

    @IBAction func videoPressed(_ sender: UIButton) {
        if let url = URL(string: "https://github.com/AudioKit/") {
            UIApplication.shared.open(url)
        }
    }

     @IBAction func emailPressed(_ sender: UIButton) {

     let receipients = ["team@audiokitpro.com"]
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

//*****************************************************************
// MARK: - MFMailComposeViewController Delegate
//*****************************************************************

extension PopUpAbout: MFMailComposeViewControllerDelegate {

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
