//
//  Tunings+UpgradePaths.swift
//  AudioKitSynthOne
//
//  Created by Marcus W. Hobbs on 12/28/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import Disk

extension Tunings {

    // for testing...resets file system state with bundled+user v0 tunings
    private func testUpgradeV1Path() {
        // copy test v0 file from bundle to documents
        if let pathStr = Bundle.main.path(forResource: "tunings_v0_upgrade_path_test", ofType: "json") {
            let fromUrl = URL(fileURLWithPath: pathStr)
            try? Disk.remove(tuningFilenameV0, from: .documents)
            let docUrl = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create:false)
            if let toUrl = docUrl?.appendingPathComponent(tuningFilenameV0) {
                try? FileManager.default.copyItem(at: fromUrl, to: toUrl)
            }
        }
        // remove v1 file
        try? Disk.remove(tuningFilenameV1, from: .documents)
    }

    // for testing...tests case new v1 user
    private func testFreshInstallV1Path() {
        try? Disk.remove(tuningFilenameV0, from: .documents)
        try? Disk.remove(tuningFilenameV1, from: .documents)
    }

    /// Upgrade path from Tunings v0 to v1
    internal func upgradeTuningsFromV0ToV1() {
        // create bundled bank, and an empty user bank
        loadTuningFactoryPresets()

        do {
            // read v0 file
            let retrievedTuningData = try Disk.retrieve(tuningFilenameV0, from: .documents, as: Data.self)
            let tuningsJSON = try? JSONSerialization.jsonObject(with: retrievedTuningData, options: [])
            guard let jsonArray = tuningsJSON as? [Any] else {
                AKLog("*** error parsing v0 tuning array from JSON while upgrading to v1")
                return
            }
            var tuningsV0 = [Tuning]()
            for tuningJSON in jsonArray {
                if let tuningDictionary = tuningJSON as? [String: Any] {
                    let retrievedTuning = Tuning(dictionary: tuningDictionary)
                    tuningsV0.append(retrievedTuning)
                }
            }

            // uniquify encodings of v0 tunings
            var v1BundledTuningEncodings = [String:String]()
            for t in Tunings.defaultTunings() {
                let tt = Tuning()
                tt.masterSet = t.1()
                let e = tt.encoding
                v1BundledTuningEncodings[e] = e
            }
            // filter 12ET
            let t = Tuning()
            v1BundledTuningEncodings[t.encoding] = t.encoding

            // compare v0 tuning encodings to bundled v1 tuning encodings
            for t in tuningsV0 {
                if v1BundledTuningEncodings[t.encoding] == nil {
                    // t is a v0 custom tuning not in v1 bundled tunings
                    tuningBanks[Tunings.userBankIndex].tunings.append(t)
                }
            }

            // remove v0 file so next launch will skip this upgrade path
            try? Disk.remove(tuningFilenameV0, from: .documents)
        } catch let error as NSError {
            AKLog("*** error upgrading from V0 to V1:\(error)")
        }
    }

}
