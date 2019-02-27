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

    // MARK: TuneUp D1 and Wilsonic
    public func launchD1() {
        redirect(to: "digitald1", appStoreUrl: "https://itunes.apple.com/us/app/audiokit-digital-d1-synth/id1436905540")
    }

    public func launchWilsonic() {
        redirect(to: "wilsonic", appStoreUrl: "https://itunes.apple.com/us/app/wilsonic/id848852071")
    }

    private func redirect(to host:String, appStoreUrl:String) {
        let npo = self.masterSet.count
        let tuneUpArgs = host + "://tune?"
        var urlStr = "\(tuneUpArgs)tuningName=\(tuningName)&npo=\(npo)"
        for f in masterSet {
            urlStr += "&f=\(f)"
        }
        urlStr += Tunings.tuneUpBackButtonUrlArgs

        if let urlStr = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            if let url = URL(string: urlStr) {

                // is host installed on device?
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {

                    // Redirect to app store
                    if let appStoreURL = URL.init(string: appStoreUrl) {
                        UIApplication.shared.open(appStoreURL, options: [:], completionHandler: nil)
                    }
                }
            }
        }
    }


    // MARK: TuneUp BackButton

    public var tuneUpBackButtonDefaultText: String { return "TuneUp" }

    public func tuneUpBackButton() {

        // must have a host
        if let redirect = redirectHost {

            // open url
            let urlStr = "\(redirect)://tuneup?redirect=synth1&redirectFriendlyName=Synth One"
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

    // can open file url's as Scala files, or scales via TuneUp
    public func openUrl(url: URL) -> Bool {

        // scala files
        if url.isFileURL {
            return openScala(atUrl: url)
        }

        let urlStr = url.absoluteString
        let host = URLComponents(string: urlStr)?.host
        let queryItems = URLComponents(string: urlStr)?.queryItems
        var urlIsTuneUpBackButton = false

        // TuneUp
        if host == "tune" || host == "tuneup" {

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
                        urlIsTuneUpBackButton = true
                    }
                }
            }

            ///TuneUp implementation
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
                    if !urlIsTuneUpBackButton {
                        // if you want to alert the user that the tuning is invalid this is the place
                        AKLog("TuneUp: tuning is invalid")
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
        guard tt.scalaFile2(url.path) != nil else {
            AKLog("Scala file is invalid")
            return false
        }

        let fArray = tt.masterSet
        if fArray.count > 0 {
            let tuningName = url.lastPathComponent
            if let tuningsPanel = conductor.viewControllers.first(where: { $0 is TuningsPanelController })
                as? TuningsPanelController {
                tuningsPanel.setTuning(name: tuningName, masterArray: fArray)
                if let s = conductor.synth {
                    let frequencyA4 = s.getDefault(.frequencyA4)
                    s.setSynthParameter(.frequencyA4, frequencyA4)
                } else {
                    AKLog("ERROR:can't set frequencyA4 because synth is not initialized")
                    return false
                }
            }
        } else {
            AKLog("Scala file is invalid: masterSet is zero-length")
            return false
        }

        return true
    }

}

//TODO: Below is duplicate version copied from AudioKit.  Why does AudioKit develop fail on scalaFile(filePath) ?
extension AKTuningTable {
    
    /// Use a Scala file to write the tuning table. Returns notes per octave or nil when file couldn't be read.
    public func scalaFile2(_ filePath: String) -> Int? {
        guard
            let contentData = FileManager.default.contents(atPath: filePath),
            let contentStr = String(data: contentData, encoding: .utf8) else {
                AKLog("can't read filePath: \(filePath)")
                return nil
        }

        if let scalaFrequencies = frequencies2(fromScalaString: contentStr) {
            let npo = tuningTable(fromFrequencies: scalaFrequencies)
            return npo
        }

        // error
        return nil
    }

    fileprivate func stringTrimmedForLeadingAndTrailingWhiteSpacesFromString2(_ inputString: String?) -> String? {
        guard let string = inputString else {
            return nil
        }

        let leadingTrailingWhiteSpacesPattern = "(?:^\\s+)|(?:\\s+$)"
        let regex: NSRegularExpression

        do {
            try regex = NSRegularExpression(pattern: leadingTrailingWhiteSpacesPattern,
                                            options: .caseInsensitive)
        } catch let error as NSError {
            AKLog("ERROR: create regex: \(error)")
            return nil
        }

        let stringRange = NSRange(location: 0, length: string.count)
        let trimmedString = regex.stringByReplacingMatches(in: string,
                                                           options: .reportProgress,
                                                           range: stringRange,
                                                           withTemplate: "$1")

        return trimmedString
    }

    /// Get frequencies from a Scala string
    open func frequencies2(fromScalaString rawStr: String?) -> [Frequency]? {
        guard let inputStr = rawStr else {
            return nil
        }

        // default return value is [1.0]
        var scalaFrequencies = [Frequency(1)]
        var actualFrequencyCount = 1
        var frequencyCount = 1

        var parsedScala = true
        var parsedFirstCommentLine = false
        let values = inputStr.components(separatedBy: .newlines)
        var parsedFirstNonCommentLine = false
        var parsedAllFrequencies = false

        // REGEX match for a cents or ratio
        //              (RATIO      |CENTS                                  )
        //              (  a   /  b |-   a   .  b |-   .  b |-   a   .|-   a )
        let regexStr = "(\\d+\\/\\d+|-?\\d+\\.\\d+|-?\\.\\d+|-?\\d+\\.|-?\\d+)"
        let regex: NSRegularExpression
        do {
            regex = try NSRegularExpression(pattern: regexStr,
                                            options: .caseInsensitive)
        } catch let error as NSError {
            AKLog("ERROR: cannot parse scala file: \(error)")
            return nil
        }

        for rawLineStr in values {
            var lineStr = stringTrimmedForLeadingAndTrailingWhiteSpacesFromString2(rawLineStr) ?? rawLineStr

            if lineStr.isEmpty { continue }

            if lineStr.hasPrefix("!") {
                if ❗️parsedFirstCommentLine {
                    parsedFirstCommentLine = true
                    #if false
                    // currently not using the scala file name embedded in the file
                    let components = lineStr.components(separatedBy: "!")
                    if components.count > 1 {
                        proposedScalaFilename = components[1]
                    }
                    #endif
                }
                continue
            }

            if ❗️parsedFirstNonCommentLine {
                parsedFirstNonCommentLine = true
                #if false
                // currently not using the scala short description embedded in the file
                scalaShortDescription = lineStr
                #endif
                continue
            }

            if parsedFirstNonCommentLine && !parsedAllFrequencies {
                if let newFrequencyCount = Int(lineStr) {
                    frequencyCount = newFrequencyCount
                    if frequencyCount == 0 || frequencyCount > 127 {
                        //#warning SPEC SAYS 0 notes is okay because 1/1 is implicit
                        AKLog("ERROR: number of notes in scala file: \(frequencyCount)")
                        parsedScala = false
                        break
                    } else {
                        parsedAllFrequencies = true
                        continue
                    }
                }
            }

            if actualFrequencyCount > frequencyCount {
                AKLog("actual frequency cont: \(actualFrequencyCount) > frequency count: \(frequencyCount)")
            }

            /* The first note of 1/1 or 0.0 cents is implicit and not in the files.*/

            // REGEX defined above this loop
            let rangeOfFirstMatch = regex.rangeOfFirstMatch(
                in: lineStr,
                options: .anchored,
                range: NSRange(location: 0, length: lineStr.count))

            if ❗️NSEqualRanges(rangeOfFirstMatch, NSRange(location: NSNotFound, length: 0)) {
                let nsLineStr = lineStr as NSString?
                let substringForFirstMatch = nsLineStr?.substring(with: rangeOfFirstMatch) as NSString? ?? ""
                if substringForFirstMatch.range(of: ".").length != 0 {
                    if var scaleDegree = Frequency(lineStr) {
                        // ignore 0.0...same as 1.0, 2.0, etc.
                        if scaleDegree != 0 {
                            scaleDegree = fabs(scaleDegree)
                            // convert from cents to frequency
                            scaleDegree /= 1_200
                            scaleDegree = pow(2, scaleDegree)
                            scalaFrequencies.append(scaleDegree)
                            actualFrequencyCount += 1
                            continue
                        }
                    }
                } else {
                    if substringForFirstMatch.range(of: "/").length != 0 {
                        if substringForFirstMatch.range(of: "-").length != 0 {
                            AKLog("ERROR: invalid ratio: \(substringForFirstMatch)")
                            parsedScala = false
                            break
                        }
                        // Parse rational numerator/denominator
                        let slashPos = substringForFirstMatch.range(of: "/")
                        let numeratorStr = substringForFirstMatch.substring(to: slashPos.location)
                        let numerator = Int(numeratorStr) ?? 0
                        let denominatorStr = substringForFirstMatch.substring(from: slashPos.location + 1)
                        let denominator = Int(denominatorStr) ?? 0
                        if denominator == 0 {
                            AKLog("ERROR: invalid ratio: \(substringForFirstMatch)")
                            parsedScala = false
                            break
                        } else {
                            let mt = Frequency(numerator) / Frequency(denominator)
                            if mt == 1.0 || mt == 2.0 {
                                // skip 1/1, 2/1
                                continue
                            } else {
                                scalaFrequencies.append(mt)
                                actualFrequencyCount += 1
                                continue
                            }
                        }
                    } else {
                        // a whole number, treated as a rational with a denominator of 1
                        if let whole = Int(substringForFirstMatch as String) {
                            if whole <= 0 {
                                AKLog("ERROR: invalid ratio: \(substringForFirstMatch)")
                                parsedScala = false
                                break
                            } else if whole == 1 || whole == 2 {
                                // skip degrees of 1 or 2
                                continue
                            } else {
                                scalaFrequencies.append(Frequency(whole))
                                actualFrequencyCount += 1
                                continue
                            }
                        }
                    }
                }
            } else {
                AKLog("ERROR: error parsing: \(lineStr)")
                continue
            }
        }

        if ❗️parsedScala {
            AKLog("FATAL ERROR: cannot parse Scala file")
            return nil
        }

        AKLog("frequencies: \(scalaFrequencies)")
        return scalaFrequencies
    }

}
