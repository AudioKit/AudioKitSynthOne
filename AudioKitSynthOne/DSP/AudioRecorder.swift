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
    case Exporting = 2
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
  
    public func toggleRecord(value: Double) {
        let shouldRecord = value == 1
        guard let recorder = nodeRecorder else { return }
        if recorder.isRecording && !shouldRecord {
            recorder.stop()
            AKLog("File at: ", recorder.audioFile)
            guard let recordingFile = recorder.audioFile else { return }
            recordingFile.exportAsynchronously(
                name: createRecordFileName(),
                baseDir: .temp,
                exportFormat: .wav,
                callback: { exportedFile, error in
                    if error != nil { return }
                    guard let file = exportedFile else { return }
                    DispatchQueue.main.async {
                        self.fileDelegate?.didFinishRecording(file: file)
                        self.updateView()
                    }
            })
            viewTimer?.invalidate()
            viewDelegate?.updateRecorderView(state: .Exporting, time: 0)
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

    private func createRecordFileName() -> String {

        // default name
        var recordingFileBaseName: String = createDefaultRecordFileBaseName()

        // custom name
        if let manager = Conductor.sharedInstance.viewControllers.first(where: { $0 is Manager }) as? Manager {
            if manager.appSettings.useCustomRecordFileBasename {
                recordingFileBaseName = manager.tuningsPanel.tuningModel.tuningFileBaseName
            }
        }
        return recordingFileBaseName + ".wav"
    }

    private func createDefaultRecordFileBaseName() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        return dateFormatter.string(from:Date())
    }

    public func clearCache() {
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                let tmpDirURL = FileManager.default.temporaryDirectory
                let tmpDirectory = try FileManager.default.contentsOfDirectory(atPath: tmpDirURL.path)
                try tmpDirectory.forEach { file in
                    let fileUrl = tmpDirURL.appendingPathComponent(file)
                    try FileManager.default.removeItem(atPath: fileUrl.path)
                }
            } catch let error as NSError {
                AKLog("ERROR: error deleting recordings in tmp directory: \(error)")
            }
        }
    }
}
