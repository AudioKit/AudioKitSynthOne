//
//  AKS1Tunings.swift
//  AudioKitSynthOne
//
//  Created by Marcus W. Hobbs on 5/12/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import UIKit
import AudioKit

@objc open class AKS1Tunings: NSObject, UITableViewDataSource, UITableViewDelegate {

    public var tuningsDelegate: TuningsPitchWheelViewTuningDidChange?

    public typealias AKS1TuningCallback = () -> (Void)

    private typealias Frequency = Double

    // 4 choose 2
    private class func hexany(_ masterSet: [Frequency]) -> [Frequency] {
        let A = masterSet[0]
        let B = masterSet[1]
        let C = masterSet[2]
        let D = masterSet[3]
        return [A * B, A * C, A * D, B * C, B * D, C * D]
    }

    // 5 choose 2
    private class func dekany(_ masterSet: [Frequency]) -> [Frequency] {
        let A = masterSet[0]
        let B = masterSet[1]
        let C = masterSet[2]
        let D = masterSet[3]
        let E = masterSet[4]
        return [A * B, A * C, A * D, A * E, B * C, B * D, B * E, C * D, C * E, D * E]
    }

    // 6 choose 2
    private class func pentadekany(_ masterSet: [Frequency]) -> [Frequency] {
        let A = masterSet[0]
        let B = masterSet[1]
        let C = masterSet[2]
        let D = masterSet[3]
        let E = masterSet[4]
        let F = masterSet[5]
        return [A * B, A * C, A * D, A * E, A * F, B * C, B * D, B * E, B * F, C * D, C * E, C * F, D * E, D * F, E * F]
    }

    public func setTuning(withMasterArray master: [Double]) -> Int? {
        if master.count == 0 { return nil}
        _ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: master)
        tuningsDelegate?.tuningDidChange()
        return tunings.count - 1
    }

    public func resetTuning() -> Int {
        let i = 0
        let tuning = tunings[i]
        tuning.1()
        let f = Conductor.sharedInstance.synth!.getParameterDefault(.frequencyA4)
        Conductor.sharedInstance.synth!.setAK1Parameter(.frequencyA4, f)
        tuningsDelegate?.tuningDidChange()
        return i
    }

    public func randomTuning() -> Int {
        let ri = Int(arc4random() % UInt32(tunings.count))
        let tuning = tunings[ri]
        tuning.1()
        tuningsDelegate?.tuningDidChange()
        return ri
    }

    private let tunings: [(String, AKS1TuningCallback)] = [
        ("12 Tone Equal Temperament (default)", {_ = AKPolyphonicNode.tuningTable.defaultTuning() }),
        ("12 Chain of pure fifths", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: [1, 3, 9, 27, 81, 243, 729, 2187, 6561, 19683, 59049, 177147]) }),

        // scales designed by Marcus Hobbs using Wilsonic
        (" 6 Hexany(1, 3, 5, 7) ", {_ = AKPolyphonicNode.tuningTable.hexany(1, 3, 5, 7)  }),
        ("10 Dekany(1, 3, 5, 7, 11)", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: AKS1Tunings.dekany([1, 3, 5, 7, 11])) }),

        (" 6 Hexany(1, 3, 5, 45) ", {_ = AKPolyphonicNode.tuningTable.hexany(1, 3, 5, 45)  }),// 071
        ("10 Dekany(1, 3, 5, 45, 75) ", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: AKS1Tunings.dekany([1, 3, 5, 45, 75]) ) }),
        ("15 Pentadekany(Hexany(1,3,5,45))", {
            _ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: AKS1Tunings.pentadekany(AKS1Tunings.hexany([1, 3, 5, 45])))
        }),

        (" 6 Hexany(1, 3, 5, 9)", {_ = AKPolyphonicNode.tuningTable.hexany(1, 3, 5, 9) }),
        ("10 Dekany(1, 3, 5, 9, 25)", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: AKS1Tunings.dekany([1, 3, 5, 9, 25] ) ) }),
        ("15 Pentadekany(Hexany(1,3,5,9))", {
            _ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: AKS1Tunings.pentadekany(AKS1Tunings.hexany([1, 3, 5, 9])))
        }),

        (" 6 Hexany(1, 3, 5, 15)", {_ = AKPolyphonicNode.tuningTable.hexany(1, 3, 5, 15) }),
        ("10 Dekany(1, 3, 5, 9, 15)", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: AKS1Tunings.dekany([1, 3, 5, 9, 15] ) ) }),

        (" 6 Hexany(1, 3, 5, 81)", {_ = AKPolyphonicNode.tuningTable.hexany(1, 3, 5, 81) }),
        ("10 Dekany(1, 3, 5, 9, 81)", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: AKS1Tunings.dekany([1, 3, 5, 9, 81] ) ) }),
        ("15 Pentadekany(Hexany(1,3,5,81))", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: AKS1Tunings.pentadekany(AKS1Tunings.hexany([1, 3, 5, 81])))
        }),
        (" 6 Hexany(1, 3, 5, 121)", {_ = AKPolyphonicNode.tuningTable.hexany(1, 3, 5, 121) }),
        ("10 Dekany(1, 3, 5, 11, 121)", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: AKS1Tunings.dekany([1, 3, 5, 11, 121] ) ) }),
        ("15 Pentadekany(Hexany(1, 3, 5, 121))", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: AKS1Tunings.pentadekany(AKS1Tunings.hexany([1, 3, 5, 121])))}
        ),
        (" 6 Hexany(1, 15, 45, 75)", {_ = AKPolyphonicNode.tuningTable.hexany(1, 15, 45, 75) }),
        ("10 Dekany(1, 15, 45, 75, 105)", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: AKS1Tunings.dekany([1, 15, 45, 75, 105]) ) }),
        ("15 Pentadekany(1, 15, 45, 75)", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: AKS1Tunings.pentadekany(AKS1Tunings.hexany([1, 15, 45, 75])))
        }),
        (" 6 Hexany(1, 17, 19, 23)", {_ = AKPolyphonicNode.tuningTable.hexany(1, 17, 19, 23) }),
        (" 6 Hexany(1, 45, 135, 225)", {_ = AKPolyphonicNode.tuningTable.hexany(1, 45, 135, 225) }),
        ("10 Dekany(1, 45, 135, 225, 315)", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: AKS1Tunings.dekany([1, 45, 135, 225, 315])) }),
        (" 6 Hexany(3, 2.111, 5.111, 8.111)", {_ = AKPolyphonicNode.tuningTable.hexany(3, 2.111, 5.111, 8.111) }),
        (" 6 Hexany(3, 1.346, 4.346, 7.346)", {_ = AKPolyphonicNode.tuningTable.hexany(3, 1.346, 4.346, 7.346) }),
        (" 6 Hexany(3, 5, 7, 9)", {_ = AKPolyphonicNode.tuningTable.hexany(3, 5, 7, 9) }),
        (" 6 Hexany(3, 7, 9, 35)", {_ = AKPolyphonicNode.tuningTable.hexany(3, 7, 9, 35) }),
        (" 6 Hexany(3, 5, 15, 19)", {_ = AKPolyphonicNode.tuningTable.hexany(3, 5, 15, 19) }),
        (" 6 Hexany(5, 7, 21, 35)", {_ = AKPolyphonicNode.tuningTable.hexany(5, 7, 21, 35) }),
        ("15 Pentadekany(5, 7, 21, 35)", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: AKS1Tunings.pentadekany(AKS1Tunings.hexany([5, 7, 21, 35])))
        }),
        (" 6 Hexany(9, 25, 49, 81)", {_ = AKPolyphonicNode.tuningTable.hexany(9, 25, 49, 81) }),
        (" 5 Recurrence Relation", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: [1, 19, 5, 3, 15])}),
        (" 5 Recurrence Relation", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: [35, 20, 46, 26, 15])}),
        (" 5 Recurrence Relation", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: [1, 37, 21, 49, 28])}),
        (" 5 Recurrence Relation", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: [35, 74, 23, 51, 61])}),
        (" 6 Recurrence Relation", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: [74, 150, 85, 106, 120, 61])}),
        (" 6 Recurrence Relation", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: [1, 9, 5, 23, 48, 7])}),
        (" 6 Recurrence Relation", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: [1, 9, 21, 3, 25, 15])}),
        (" 6 Recurrence Relation", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: [1, 75, 19, 5, 3, 15])}),
        (" 7 Recurrence Relation", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: [1, 17, 10, 47, 3, 13, 7])}),
        (" 7 Recurrence Relation", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: [1, 9, 5, 21, 3, 27, 7])}),
        (" 7 Recurrence Relation", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: [1, 9, 21, 3, 25, 15, 31])}),
        (" 7 Recurrence Relation", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: [1, 75, 19, 5, 94, 3, 15])}),
        (" 7 Recurrence Relation", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: [9, 40, 21, 25, 52, 15, 31])}),
        (" 7 Recurrence Relation", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: [1, 18, 5, 21, 3, 25, 15])}),
        (" 8 Recurrence Relation", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: [1, 75, 19, 5, 94, 3, 118, 15])}),
        ("12 Recurrence Relation", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: [1, 65, 9, 37, 151, 21, 86, 12, 49, 200, 28, 114])}),

        /// scales designed by Erv Wilson.  See http://anaphoria.com/genus.pdf
        (" 7 Highland Bagpipes", {_ = AKPolyphonicNode.tuningTable.presetHighlandBagPipes() }),
        (" 7 MOS G:0.2641", {_ = AKPolyphonicNode.tuningTable.momentOfSymmetry(generator: 0.2641, level: 5, murchana: 0)}),
        (" 9 MOS G:0.238186", {_ = AKPolyphonicNode.tuningTable.momentOfSymmetry(generator: 0.238186, level: 6, murchana: 0)}),
        ("10 MOS G:0.292", {_ = AKPolyphonicNode.tuningTable.momentOfSymmetry(generator: 0.292, level: 6, murchana: 0)}),
        (" 7 MOS G:0.4057", {_ = AKPolyphonicNode.tuningTable.momentOfSymmetry(generator: 0.4057, level: 4, murchana: 0)}),
        (" 7 MOS G:0.415226", {_ = AKPolyphonicNode.tuningTable.momentOfSymmetry(generator: 0.415226, level: 4, murchana: 0)}),
        (" 7 MOS G:0.436385", {_ = AKPolyphonicNode.tuningTable.momentOfSymmetry(generator: 0.436385, level: 4, murchana: 0)}),
        ("31 Equal Temperament", {_ = AKPolyphonicNode.tuningTable.equalTemperament(notesPerOctave: 31)}),
        ("17 North Indian:17", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian00_17() }),
        (" 7 North Indian:Kalyan", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian01Kalyan() }),
        (" 7 North Indian:Bilawal", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian02Bilawal() }),
        (" 7 North Indian:Khamaj", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian03Khamaj() }),
        (" 7 North Indian:KafiOld", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian04KafiOld() }),
        (" 7 North Indian:Kafi", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian05Kafi() }),
        (" 7 North Indian:Asawari", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian06Asawari() }),
        (" 7 North Indian:Bhairavi", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian07Bhairavi() }),
        (" 7 North Indian:Bhairav", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian15Bhairav() }),
        (" 7 North Indian:Marwa", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian08Marwa() }),
        (" 7 North Indian:Purvi", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian09Purvi() }),
        (" 7 North Indian:Lalit2", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian10Lalit2() }),
        (" 7 North Indian:Todi", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian11Todi() }),
        (" 7 North Indian:Lalit", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian12Lalit() }),
        (" 7 North Indian:NoName", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian13NoName() }),
        (" 7 North Indian:AnandBhairav", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian14AnandBhairav() }),
        (" 7 North Indian:Bhairav", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian15Bhairav() }),
        (" 7 North Indian:JogiyaTodi", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian16JogiyaTodi() }),
        (" 7 North Indian:Madhubanti", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian17Madhubanti() }),
        (" 7 North Indian:NatBhairav", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian18NatBhairav() }),
        (" 7 North Indian:AhirBhairav", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian19AhirBhairav() }),
        (" 7 North Indian:ChandraKanada", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian20ChandraKanada() }),
        (" 7 North Indian:BasantMukhair", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian21BasantMukhari() }),
        (" 7 North Indian:Champakali", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian22Champakali() }),
        (" 7 North Indian:Patdeep", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian23Patdeep() }),
        (" 7 North Indian:MohanKauns", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian24MohanKauns() }),
        (" 7 North Indian:Parameswari", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian25Parameswari() }),
        (" - Tuning From Preset", {_ = 0})
    ]

    // MARK: UITableViewDataSource
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    @objc(tableView:heightForRowAtIndexPath:) public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tunings.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.separatorColor = #colorLiteral(red: 0.368627451, green: 0.368627451, blue: 0.3882352941, alpha: 1)
        let tuning = tunings[(indexPath as NSIndexPath).row]
        let title = tuning.0
        if let cell = tableView.dequeueReusableCell(withIdentifier: "TuningsViewController") as UITableViewCell? {
            configureCell(cell)
            cell.textLabel?.text = title
            return cell
        } else {
            let cell = UITableViewCell()
            configureCell(cell)
            cell.textLabel?.text = title
            return cell
        }
    }

    private func configureCell(_ cell: UITableViewCell) {
        cell.isOpaque = false
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.textColor = #colorLiteral(red: 0.694699347, green: 0.6895567775, blue: 0.6986362338, alpha: 1)
    }

    // MARK: UITableViewDelegate
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell.isSelected {
            cell.contentView.backgroundColor = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        }
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tuning = tunings[(indexPath as NSIndexPath).row]
        tuning.1()

        if let selectedCell = tableView.cellForRow(at: indexPath) {
            selectedCell.contentView.backgroundColor = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        }
        tuningsDelegate?.tuningDidChange()
    }
}
