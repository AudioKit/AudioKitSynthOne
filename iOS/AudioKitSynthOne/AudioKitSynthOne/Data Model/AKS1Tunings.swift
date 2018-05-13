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
    
    public var tuningsDelegate: TuningsPitchWheelViewTuningDidChange? = nil
    
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
    
    private let tunings: [(String, AKS1TuningCallback)] = [
        ("12 tone equal temperament (default)", {_ = AKPolyphonicNode.tuningTable.defaultTuning() } ),
        ("12 Pythagorean 12", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: [1,3,9,27,81,243,729,2187,6561,19683,59049,177147]) } ),
        //(" 5 (8,10,11,12,14) JI", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: [8,10,11,12,14])}), // stephen's wilson's garden theme tuning;
        // designed by Marcus Hobbs
        (" 6 hexany(1, 3, 5, 7) ", {_ = AKPolyphonicNode.tuningTable.hexany(1, 3, 5, 7)  } ),
        ("10 dekany(1, 3, 5, 7, 11)", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: AKS1Tunings.dekany([1,3,5,7,11])) } ),
        ("15 pentadekany(hexany(1,3,5,7))", {
            _ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: AKS1Tunings.pentadekany(AKS1Tunings.hexany([1, 3, 5, 7])))
        } ),
        
        (" 6 hexany(1, 3, 5, 45) ", {_ = AKPolyphonicNode.tuningTable.hexany(1, 3, 5, 45)  } ),// 071
        ("10 dekany(1, 3, 5, 45, 75) ",  {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: AKS1Tunings.dekany([1,3,5,45,75]) ) } ),
        ("15 pentadekany(hexany(1,3,5,45))", {
            _ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: AKS1Tunings.pentadekany(AKS1Tunings.hexany([1, 3, 5, 45])))
        } ),
        (" 6 hexany(1, 3, 5, 9)", {_ = AKPolyphonicNode.tuningTable.hexany(1, 3, 5, 9) } ),
        ("10 dekany(1, 3, 5, 9, 25)", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: AKS1Tunings.dekany([1, 3, 5, 9, 25] ) ) } ),
        ("15 pentadekany(hexany(1,3,5,9))", {
            _ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: AKS1Tunings.pentadekany(AKS1Tunings.hexany([1, 3, 5, 9])))
        } ),
        (" 6 hexany(1, 3, 5, 81)", {_ = AKPolyphonicNode.tuningTable.hexany(1, 3, 5, 81) } ),
        ("10 dekany(1, 3, 5, 9, 81)", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: AKS1Tunings.dekany([1, 3, 5, 9, 81] ) ) } ),
        ("15 pentadekany(hexany(1,3,5,81))", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: AKS1Tunings.pentadekany(AKS1Tunings.hexany([1, 3, 5, 81])))
        } ),
        (" 6 hexany(1, 3, 5, 121)", {_ = AKPolyphonicNode.tuningTable.hexany(1, 3, 5, 121) } ),
        ("10 dekany(1, 3, 5, 11, 121)", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: AKS1Tunings.dekany([1, 3, 5, 11, 121] ) ) } ),
        ("15 pentadekany(hexany(1, 3, 5, 121))",
         {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: AKS1Tunings.pentadekany(AKS1Tunings.hexany([1, 3, 5, 121])))}
        ),
        (" 6 hexany(1, 15, 45, 75)", {_ = AKPolyphonicNode.tuningTable.hexany(1, 15, 45, 75) } ),
        ("10 dekany(1, 15, 45, 75, 105)", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: AKS1Tunings.dekany([1,15,45,75,105]) ) } ),
        ("15 pentadekany(1, 15, 45, 75)", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: AKS1Tunings.pentadekany(AKS1Tunings.hexany([1, 15, 45, 75])))
        } ),
        (" 6 hexany(1, 17, 19, 23)", {_ = AKPolyphonicNode.tuningTable.hexany(1, 17, 19, 23) } ),
        (" 6 hexany(1, 45, 135, 225)", {_ = AKPolyphonicNode.tuningTable.hexany(1,45,135,225) } ),
        ("10 dekany(1, 45, 135, 225, 315)", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: AKS1Tunings.dekany([1,45,135,225, 315])) } ),
        (" 6 hexany(3, 2.111, 5.111, 8.111)", {_ = AKPolyphonicNode.tuningTable.hexany(3, 2.111, 5.111, 8.111) } ),
        (" 6 hexany(3, 5,  7,  9)", {_ = AKPolyphonicNode.tuningTable.hexany(3, 5, 7, 9) } ),
        (" 6 hexany(3, 5, 15, 19)", {_ = AKPolyphonicNode.tuningTable.hexany(3, 5, 15, 19) } ),
        (" 6 hexany(5, 7, 21, 35)", {_ = AKPolyphonicNode.tuningTable.hexany(5, 7, 21, 35) } ),
        ("15 pentadekany(5, 7, 21, 35)", {_ = AKPolyphonicNode.tuningTable.tuningTable(fromFrequencies: AKS1Tunings.pentadekany(AKS1Tunings.hexany([5, 7, 21, 35])))
        }  ),
        (" 7 Highland Bagpipes", {_ = AKPolyphonicNode.tuningTable.presetHighlandBagPipes() } ),
        (" 7 MOS G:0.2641", {_ = AKPolyphonicNode.tuningTable.momentOfSymmetry(generator: 0.2641, level: 5, murchana: 0)}),
        (" 7 MOS G:0.238186", {_ = AKPolyphonicNode.tuningTable.momentOfSymmetry(generator: 0.238186, level: 6, murchana: 0)}),
        (" 7 MOS G:0.292", {_ = AKPolyphonicNode.tuningTable.momentOfSymmetry(generator: 0.292, level: 6, murchana: 0)}),
        /// Designed by Erv Wilson.  See http://anaphoria.com/genus.pdf
        ("17 North Indian:17", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian00_17() } ),
        (" 7 North Indian:Kalyan", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian01Kalyan() } ),
        (" 7 North Indian:Bilawal", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian02Bilawal() } ),
        (" 7 North Indian:Khamaj", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian03Khamaj() } ),
        (" 7 North Indian:KafiOld", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian04KafiOld() } ),
        (" 7 North Indian:Kafi", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian05Kafi() } ),
        (" 7 North Indian:Asawari", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian06Asawari() } ),
        (" 7 North Indian:Bhairavi", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian07Bhairavi() } ),
        (" 7 North Indian:Bhairav", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian15Bhairav() } ),
        (" 7 North Indian:Marwa", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian08Marwa() } ),
        (" 7 North Indian:Purvi", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian09Purvi() } ),
        (" 7 North Indian:Lalit2", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian10Lalit2() } ),
        (" 7 North Indian:Todi", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian11Todi() } ),
        (" 7 North Indian:Lalit", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian12Lalit() } ),
        (" 7 North Indian:NoName", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian13NoName() } ),
        (" 7 North Indian:AnandBhairav", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian14AnandBhairav() } ),
        (" 7 North Indian:Bhairav", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian15Bhairav() } ),
        (" 7 North Indian:JogiyaTodi", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian16JogiyaTodi() } ),
        (" 7 North Indian:Madhubanti", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian17Madhubanti() } ),
        (" 7 North Indian:NatBhairav", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian18NatBhairav() } ),
        (" 7 North Indian:AhirBhairav", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian19AhirBhairav() } ),
        (" 7 North Indian:ChandraKanada", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian20ChandraKanada() } ),
        (" 7 North Indian:BasantMukhair", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian21BasantMukhari() } ),
        (" 7 North Indian:Champakali", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian22Champakali() } ),
        (" 7 North Indian:Patdeep", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian23Patdeep() } ),
        (" 7 North Indian:MohanKauns", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian24MohanKauns() } ),
        (" 7 North Indian:Parameswari", {_ = AKPolyphonicNode.tuningTable.presetPersian17NorthIndian25Parameswari() } )
    ]
    
    ///UITableViewDataSource
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
        let tuning = tunings[(indexPath as NSIndexPath).row]
        let title = tuning.0 // title
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
        cell.textLabel?.textColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
    }
    
    ///UITableViewDelegate
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tuning = tunings[(indexPath as NSIndexPath).row]
        tuning.1()
        tuningsDelegate?.tuningDidChange()
    }
}
