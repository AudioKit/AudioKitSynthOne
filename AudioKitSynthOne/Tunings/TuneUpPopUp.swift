//
//  TuneUpPopUp.swift
//  AudioKitSynthOne
//
//  Created by Matthew Fecher on 2/14/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//


import UIKit

protocol TuneUpPopUpDelegate: AnyObject {
    func wilsonicPressed()
    func d1Pressed()
}

class TuneUpPopUp: UIViewController {
    
    @IBOutlet weak var moreView: UIView!
    @IBOutlet weak var d1Button: UIButton!
    @IBOutlet weak var wilsonicButton: UIButton!
    
    var delegate: TuneUpPopUpDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        moreView.layer.borderColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
        moreView.layer.borderWidth = 2
        moreView.layer.cornerRadius = 6
        
    }
    
    @IBAction func closePressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func wilsonicPressed(_ sender: Any) {
        dismiss(animated: true) {
            self.delegate?.wilsonicPressed()
        }
    }
    
    @IBAction func d1Pressed(_ sender: Any) {
        dismiss(animated: true) {
            self.delegate?.d1Pressed()
        }
    }
    
}
