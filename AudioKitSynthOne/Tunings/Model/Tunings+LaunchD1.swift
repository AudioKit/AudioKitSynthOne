//
//  Tunings+LaunchD1.swift
//  AudioKitSynthOne
//
//  Created by Marcus W. Hobbs on 2/10/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

import Foundation

extension Tunings {

    func launchD1() {
        let host = "digitald1://tune?"
        let npo = self.masterSet.count
        var urlStr = "\(host)tuningName=\(tuningName)&npo=\(npo)"
        for f in masterSet {
            urlStr += "&f=\(f)"
        }
        if let urlStr = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            if let url = URL(string: urlStr) {
                // is D1 installed on device?
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    // Redirect to app store
                    if let appStoreURL = URL.init(string: "https://itunes.apple.com/us/app/audiokit-digital-d1-synth/id1436905540") {
                        UIApplication.shared.open(appStoreURL, options: [:], completionHandler: nil)
                    }
                }
            }
        }
    }
}
