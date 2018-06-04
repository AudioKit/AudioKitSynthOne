//
//  InfoController.swift
//  FMPlayer
//
//  Created by AudioKit Contributors on 10/31/17.
//  Copyright © 2017 Matthew Fecher. All rights reserved.
//

import UIKit
import StoreKit

class InfoController: UIViewController {

    @IBOutlet weak var moreView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        moreView.layer.borderColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
        moreView.layer.borderWidth = 2
        moreView.layer.cornerRadius = 6

    }

    @IBAction func closePressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func videoPressed(_ sender: UIButton) {
       /*
        if let url = URL(string: "http://audiokitpro.com/audiokit/") {
            UIApplication.shared.open(url)
        }
       */
    }

    @IBAction func reviewAppPressed(_ sender: UIButton) {
       requestReview()
    }

    @IBAction func fmWebSite(_ sender: Any) {
        if let url = URL(string: "http://audiokitpro.com/fmplayer/") {
            UIApplication.shared.open(url)
        }
    }

    @IBAction func getFMPlayerPressed(_ sender: Any) {

         if let url = URL(string: "http://itunes.apple.com/us/app/fm-player-classic-dx-synths/id1307785646?ls=1&mt=8") {
            UIApplication.shared.open(url)
         }
    }

}
