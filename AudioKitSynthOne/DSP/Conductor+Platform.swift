//
//  Conductor+Platform.swift
//  AudioKitSynthOne
//
//  Created by Matthias Frick on 03/11/2019.
//  Copyright © 2019 AudioKit. All rights reserved.
//

import Foundation

#if !targetEnvironment(macCatalyst)
extension Conductor {
      @objc func checkIAAConnectionsEnterBackground() {

          if let audiobusClient = Audiobus.client {

              if !audiobusClient.isConnected && !audiobusClient.isConnectedToInput && !backgroundAudio {
                  deactivateSession()
                  AKLog("disconnected without timer")
              } else {
                  iaaTimer.invalidate()
                  iaaTimer = Timer.scheduledTimer(timeInterval: 20 * 60,
                                                  target: self,
                                                  selector: #selector(self.checkIAAConnectionsEnterBackground),
                                                  userInfo: nil, repeats: true)
              }
          }

      }

      func checkIAAConnectionsEnterForeground() {
          iaaTimer.invalidate()
          startEngine()
      }
}
#endif

// MacOS Cataylyst stubs
// We don't support IAA there so adding NOOPs
#if targetEnvironment(macCatalyst)
extension Conductor {
      @objc func checkIAAConnectionsEnterBackground() { }

      func checkIAAConnectionsEnterForeground() { }
}
#endif
