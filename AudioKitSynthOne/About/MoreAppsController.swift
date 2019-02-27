//
//  MoreAppsController.swift
//  AudioKit Synth One
//
//  Created by Matthew Fecher on 11/15/18.
//  Copyright © 2018 AudioKit Pro. All rights reserved.
//

import UIKit

class MoreAppsController: UIViewController {
    
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
    
    @IBAction func getDigitalD1(_ sender: Any) {
        if let url = URL(string: "https://itunes.apple.com/us/app/audiokit-digital-d1-synth/id1436905540?ls=1&mt=8") {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func learnMorePressed(_ sender: Any) {
        if let url = URL(string: "http://audiokitpro.com/digitald1/") {
            UIApplication.shared.open(url)
        }
    }
    
}
