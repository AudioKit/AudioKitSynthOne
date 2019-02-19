////
////  Tunings+LaunchD1.swift
////  AudioKitSynthOne
////
////  Created by Marcus W. Hobbs on 2/10/19.
////  Copyright © 2019 AudioKit. All rights reserved.
////
//
//import Foundation
//
//extension Tunings {
//
//    private func redirect(to host:String, appStoreUrl:String) {
//        let npo = self.masterSet.count
//        let tuneUpArgs = host + "://tune?"
//        var urlStr = "\(tuneUpArgs)tuningName=\(tuningName)&npo=\(npo)"
//        for f in masterSet {
//            urlStr += "&f=\(f)"
//        }
//        urlStr += Tunings.tuneUpBackButtonUrlArgs
//
//        if let urlStr = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
//            if let url = URL(string: urlStr) {
//
//                // is host installed on device?
//                if UIApplication.shared.canOpenURL(url) {
//                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
//                } else {
//
//                    // Redirect to app store
//                    if let appStoreURL = URL.init(string: appStoreUrl) {
//                        UIApplication.shared.open(appStoreURL, options: [:], completionHandler: nil)
//                    }
//                }
//            }
//        }
//    }
//
//    public func launchD1() {
//        redirect(to: "DigitalD1", appStoreUrl: "https://itunes.apple.com/us/app/audiokit-digital-d1-synth/id1436905540")
//    }
//
//    public func launchWilsonic() {
//        redirect(to: "wilsonic", appStoreUrl: "https://itunes.apple.com/us/app/wilsonic/id848852071?mt=8")
//    }
//
//}
