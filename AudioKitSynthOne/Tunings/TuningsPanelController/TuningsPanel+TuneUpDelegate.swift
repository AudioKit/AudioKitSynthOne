//
//  TuningsPanel+TuneUpDelegate.swift
//  AudioKitSynthOne
//
//  Created by Marcus W. Hobbs on 2/3/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

import Foundation

extension TuningsPanelController: TuneUpDelegate {

    var tuneUpBackButtonDefaultText: String {

        return tuningModel.tuneUpBackButtonDefaultText
    }

    func setTuneUpBackButtonLabel(text: String) {

        let isHidden = (text == tuningModel.tuneUpBackButtonDefaultText)
        tuneUpBackButtonButton.isHidden = isHidden
        tuneUpBackLabel.isHidden = isHidden
        tuneUpBackButtonButton.setTitle(text, for: .normal)
    }

    func setTuneUpBackButton(enabled: Bool) {
        
        tuneUpBackButtonButton.isEnabled = enabled
    }

}
