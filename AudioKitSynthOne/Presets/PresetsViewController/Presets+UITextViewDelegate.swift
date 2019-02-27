//
//  Presets+UITextViewDelegate.swift
//  AudioKitSynthOne
//
//  Created by Aurelius Prochazka on 6/8/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

extension PresetsViewController: UITextViewDelegate {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }

    @IBAction func doneEditingPressed(_ sender: UIButton) {
        view.endEditing(true)
        presetsDelegate?.saveEditedPreset(name: currentPreset.name,
                                          category: currentPreset.category,
                                          bank: currentPreset.bank)
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        doneEditingButton.isHidden = true
        if conductor.device == .phone {
            newButton.isHidden = false
            importBankButton.isHidden = false
        }
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        doneEditingButton.isHidden = false
        if conductor.device == .phone {
           newButton.isHidden = true
           importBankButton.isHidden = true
        }
    }
}
