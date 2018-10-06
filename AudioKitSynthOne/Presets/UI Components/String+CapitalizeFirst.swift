//
//  String+CapitalizeFirst.swift
//  AudioKitSynthOne
//
//  Created by Matthew Fecher on 10/6/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
