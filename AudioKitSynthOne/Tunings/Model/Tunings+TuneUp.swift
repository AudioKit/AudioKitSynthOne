//
//  Tunings+TuneUp.swift
//  AudioKitSynthOne
//
//  Created by Marcus W. Hobbs on 2/3/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

import Foundation

protocol TuneUpDelegate: AnyObject {

    var tuneUpBackButtonDefaultText: String { get }
    func setTuneUpBackButtonLabel(text: String)
    func setTuneUpBackButton(enabled: Bool)
}

extension Tunings {

    // MARK: TuneUp, BackButton

    public var tuneUpBackButtonDefaultText: String { return "TuneUp" }

    public func tuneUpBackButton() {

        // must have a host
        if let redirect = redirectHost {

            // open url
            let urlStr = "\(redirect)://tuneup?redirect=synth1&redirectFriendlyName=\"Synth One\""
            if let urlStr = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                if let url = URL(string: urlStr) {

                    // BackButton: Fast Switch to previous app
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        } else {
            // error: no host
            AKLog("Can't redirect because no previous host was given")
        }
    }

    public func openUrl(url: URL) -> Bool {

        // scala files
        if url.isFileURL {
            return openScala(atUrl: url)
        }

        // custom url
        let urlStr = url.absoluteString
        let host = URLComponents(string: urlStr)?.host

        // TuneUp
        if host == "tune" || host == "tuneup" {

            ///TuneUp implementation
            let queryItems = URLComponents(string: urlStr)?.queryItems
            if let fArray = queryItems?.filter({$0.name == "f"}).map({ Double($0.value ?? "1.0") ?? 1.0 }) {

                // only valid if non-zero length frequency array
                if fArray.count > 0 {

                    // set vc properties
                    let tuningName = queryItems?.filter({$0.name == "tuningName"}).first?.value ?? ""
                    _ = setTuning(name: tuningName, masterArray: fArray)

                    // set synth properties
                    if let frequencyMiddleCStr = queryItems?.filter({$0.name == "frequencyMiddleC"}).first?.value {
                        if let frequencyMiddleC = Double(frequencyMiddleCStr) {
                            if let s = conductor.synth {
                                let frequencyA4 = frequencyMiddleC * exp2((69-60)/12)
                                s.setSynthParameter(.frequencyA4, frequencyA4)
                            } else {
                                AKLog("TuneUp:can't set frequencyA4 because synth is not initialized")
                            }
                        }
                    }
                } else {

                    // if you want to alert the user that the tuning is invalid this is the place
                    AKLog("TuneUp: tuning is invalid")
                }

                // Store TuneUp BackButton properties even if there is an error
                if let redirect = queryItems?.filter({$0.name == "redirect"}).first?.value {
                    if redirect.count > 0 {

                        // store redirect url and friendly name...for when user wants to fast-switch back
                        redirectHost = redirect
                        if let redirectName = queryItems?.filter({$0.name == "redirectFriendlyName"}).first?.value {
                            if redirectName.count > 0 {
                                redirectFriendlyName = redirectName
                            } else {
                                redirectFriendlyName = self.tuneUpBackButtonDefaultText
                            }
                            tuneUpDelegate?.setTuneUpBackButtonLabel(text: redirectFriendlyName)
                            tuneUpDelegate?.setTuneUpBackButton(enabled: true)

                            //TODO: save redirect schemes in appsettings?

                        }
                    }
                }
            }
            return true
        } else if host == "open" {

            // simply Open
            return true
        } else {

            // can't handle this url scheme
            AKLog("unsupported custom url scheme: \(url)")
            return false
        }
    }

    private func openScala(atUrl url: URL) -> Bool {
        AKLog("opening scala file at full path:\(url.path)")

        let tt = AKTuningTable()
        guard tt.scalaFile(url.path) != nil else {
            AKLog("Scala file is invalid")
            return true // even if there is an error
        }

        let fArray = tt.masterSet
        if fArray.count > 0 {
            let tuningName = url.lastPathComponent
            let tuningsPanel = conductor.viewControllers.first(where: { $0 is TuningsPanelController })
                as? TuningsPanelController
            tuningsPanel?.setTuning(name: tuningName, masterArray: fArray)
            if let s = conductor.synth {
                let frequencyA4 = s.getDefault(.frequencyA4)
                s.setSynthParameter(.frequencyA4, frequencyA4)
            } else {
                AKLog("ERROR:can't set frequencyA4 because synth is not initialized")
            }
        } else {
            AKLog("Scala file is invalid: masterSet is zero-length")
        }

        return true
    }
}
