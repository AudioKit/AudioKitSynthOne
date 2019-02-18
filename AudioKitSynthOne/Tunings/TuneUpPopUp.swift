//
//  TuneUpPopUp.swift
//  AudioKitSynthOne
//
//  Created by Matthew Fecher on 2/14/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//


import UIKit

class TuneUpPopUp: UIViewController {
    
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
    
    @IBAction func openURL(_ sender: Any) {
        if let url = URL(string: "https://itunes.apple.com/us/app/audiokit-digital-d1-synth/id1436905540?ls=1&mt=8") {
            UIApplication.shared.open(url)
        }
    }
    
    
}
