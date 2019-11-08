//
//  AudioRecorder.swift
//  AudioKitSynthOne
//
//  Created by Matthias Frick on 08/11/2019.
//  Copyright © 2019 AudioKit. All rights reserved.
//

import Foundation
import AudioKit

enum RecorderState: Int {
    case Idle = 0
    case Recording = 1
}

protocol AudioRecorderFileDelegate {
    func didFinishRecording(file: AKAudioFile)
}

protocol AudioRecorderViewDelegate {
    func updateRecorderView(state: RecorderState, time: Double?)
}

class AudioRecorder {
    var node: AKNode? {
        didSet {
            do {
                try self.nodeRecorder = AKNodeRecorder(node: node)
            } catch let error as NSError {
                AKLog(error.description)
            }
        }
    }
    var nodeRecorder: AKNodeRecorder?
    var internalFile: AKAudioFile?
    var fileDelegate: AudioRecorderFileDelegate?
    var viewDelegate: AudioRecorderViewDelegate?
    var viewTimer: Timer? // Timer to update View on recording progress
    
    public init(node: AKNode? = AudioKit.output,
                file: AKAudioFile? = nil) {
        do {
            try self.nodeRecorder = AKNodeRecorder(node: node)
        } catch let error as NSError {
            AKLog(error.description)
        }
    }
  
    public func toggleRecord() {
        guard let recorder = nodeRecorder else { return }
        if recorder.isRecording {
            recorder.stop()
            AKLog("File at: ", recorder.audioFile)
            guard let recordingFile = recorder.audioFile else { return }
            fileDelegate?.didFinishRecording(file: recordingFile)
            viewTimer?.invalidate()
            updateView()
        } else {
            do {
                try recorder.reset()
                try recorder.record()
                viewTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { (_) in
                    self.updateView()
                })
            } catch let error as NSError {
                AKLog(error.description)
            }
        }
    }

    private func updateView() {
        guard let recorder = nodeRecorder else { return }
        let state: RecorderState = recorder.isRecording ? .Recording : .Idle
        viewDelegate?.updateRecorderView(state: state, time: recorder.recordedDuration)
    }
}
