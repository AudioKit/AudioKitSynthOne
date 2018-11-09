//
//  ABLLinkManager.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors.
//  Copyright © 2017 AudioKit. All rights reserved.
//

/// Engine-related data that can be changed from the main thread.
public struct ABLEngineData {
    /// Hardware output latency in HostTime
    public var outputLatency: UInt32
    public var resetToBeatTime: Float64
    public var proposeBpm: Float64
    public var quantum: Float64
    public var requestStart: Bool
    public var requestStop: Bool

    public init(
        outputLatency: UInt32 = 0,
        resetToBeatTime: Float64 = 0,
        proposeBpm: Float64 = 120,
        quantum: Float64 = 4,
        requestStart: Bool = false,
        requestStop: Bool = false) {
        self.outputLatency = outputLatency
        self.resetToBeatTime = resetToBeatTime
        self.proposeBpm = proposeBpm
        self.quantum = quantum
        self.requestStart = requestStart
        self.requestStop = requestStop
    }
}


/// Structure that stores all data needed by the audio callback.
public struct ABLLinkData {
    #if ABLETON_ENABLED_1
    public var linkRef: ABLLinkRef
    /// Shared between threads. Only write when engine not running.
    public var sampleRate: Float64
    /// Shared between threads. Only write when engine not running.
    public var secondsToHostTime: Float64
    /// Shared between threads. Written by the main thread and only read by the audio thread when doing so will not block.
    public var sharedEngineData: ABLEngineData
    /// Copy of sharedEngineData Aowned by audio thread.
    public var localEngineData: ABLEngineData
    /// Owned by audio thread
    public var timeAtLastClick: UInt64
    /// Owned by audio thread
    public var isPlaying: Bool

    public init(
        linkRef: ABLLinkRef,
        sampleRate: Float64,
        secondsToHostTime: Float64,
        sharedEngineData: ABLEngineData,
        localEngineData: ABLEngineData,
        timeAtLastClick: UInt64,
        isPlaying: Bool) {
        self.linkRef = linkRef
        self.sampleRate = sampleRate
        self.secondsToHostTime = secondsToHostTime
        self.sharedEngineData = sharedEngineData
        self.localEngineData = localEngineData
        self.timeAtLastClick = timeAtLastClick
        self.isPlaying = isPlaying
    }
    #endif
}

public typealias ABLLinkManagerTempoCallback = (_ bpm: Double, _ quantum: Double) -> Void
public typealias ABLLinkManagerActivationCallback = (_ isEnabled: Bool) -> Void
public typealias ABLLinkManagerConnectionCallback = (_ isConnected: Bool) -> Void

public enum ABLLinkManagerListenerType {
    case tempo(ABLLinkManagerTempoCallback)
    case activation(ABLLinkManagerActivationCallback)
    case connection(ABLLinkManagerConnectionCallback)
}

public struct ABLLinkManagerListener: Equatable {
    public private(set) var id: String
    public private(set) var type: ABLLinkManagerListenerType

    public init(type: ABLLinkManagerListenerType) {
        self.id = UUID().uuidString
        self.type = type
    }

    // MARK: Equatable

    public static func ==(lhs: ABLLinkManagerListener, rhs: ABLLinkManagerListener) -> Bool {
        return lhs.id == rhs.id
    }
}

public class ABLLinkManager: NSObject {

    public static let shared = ABLLinkManager()
#if ABLETON_ENABLED_1
    //swiftlint:disable identifier_name
    // Constants
    public static let INVALID_BEAT_TIME: Double = Double.leastNormalMagnitude
    public static let INVALID_BPM: Double = Double.leastNormalMagnitude
    public static let QUANTUM_DEFAULT: Float64 = 4

    // Variables
    // var lock = os_unfair_lock() //ios10
    private var lock = os_unfair_lock()
    private var linkData: ABLLinkData?

    // Debug
    public var isDebugging: Bool = false

    // Listeners
    private var listeners = [ABLLinkManagerListener]()

    // MARK: Init

    private override init() {
        super.init()
    }

    deinit {
        if let linkData = linkData {
            // Deletes Link (don't have multiples of this). Do this during app shutdown
            ABLLinkDelete(linkData.linkRef)
        }
    }

    // MARK: Public API

    /// Reference of Link itself.
    public var linkRef: ABLLinkRef? {
        return linkData?.linkRef
    }

    /// Detemines if Link is connected or not.
    public var isConnected: Bool {
        guard let ref = linkData?.linkRef else { return false }
        return ABLLinkIsConnected(ref)
    }

    /// Determines if Link is enabled or not.
    public var isEnabled: Bool {
        guard let linkRef = linkRef else { return false }
        return ABLLinkIsEnabled(linkRef)
    }

    /// Detemines if Link is playing or not.
    public private(set) var isPlaying: Bool {
        get {
            guard let linkRef = linkRef,
                let sessionState = ABLLinkCaptureAppSessionState(linkRef)
                else { return false }
            return ABLLinkIsPlaying(sessionState)
        } set {
            guard var linkData = linkData else { return }
            os_unfair_lock_lock(&lock)
            if newValue { // isPlaying
                linkData.sharedEngineData.requestStart = newValue
            } else {
                linkData.sharedEngineData.requestStop = newValue
            }
            self.linkData = linkData
            os_unfair_lock_unlock(&lock)
        }
    }

    /// Beats per minute.
    public var bpm: Float64 {
        get {
            guard let linkRef = linkRef else { return ABLLinkManager.INVALID_BPM }
            return ABLLinkGetTempo(ABLLinkCaptureAppSessionState(linkRef))
        } set {
            guard var linkData = linkData else {
                AKLog("ABL: LinkData invalid when trying to set BPM")
                return
            }

            AKLog("ABL: Set Bpm to", newValue)
            os_unfair_lock_lock(&lock)
            linkData.sharedEngineData.proposeBpm = newValue
            self.linkData = linkData
            os_unfair_lock_unlock(&lock)
        }
    }

    /// Current beat.
    public var beatTime: Float64 {
        guard let linkRef = linkRef else {
            AKLog("ABL: LinkData invalid when trying to get beat. Returning 0.")
            return 0
        }

        return ABLLinkBeatAtTime(
            ABLLinkCaptureAppSessionState(linkRef),
            mach_absolute_time(),
            quantum)
    }

    /// Current quantum.
    public var quantum: Float64 {
        get {
            guard let linkData = linkData else {
                AKLog("ABL: LinkData invalid when trying to get quantum. Returning default.")
                return ABLLinkManager.QUANTUM_DEFAULT
            }
            return linkData.sharedEngineData.quantum
        } set {
            guard var linkData = linkData else { return }
            os_unfair_lock_lock(&lock)
            linkData.sharedEngineData.quantum = newValue
            self.linkData = linkData
            os_unfair_lock_unlock(&lock)
        }
    }

    /// Returns Link settings view controller initilized with Link reference.
    public var settingsViewController: ABLLinkSettingsViewController? {
        guard let linkData = linkData else {
            AKLog("ABL: Error casting ABL vc as UIViewController")
            return nil
        }
        return ABLLinkSettingsViewController.instance(linkData.linkRef)
    }

    /// Initilizes Link with tempo and quantum.
    ///
    /// - Parameters:
    ///   - bpm: Tempo.
    ///   - quantum: Quantum.
    public func setup(bpm: Double, quantum: Float64) {
        AKLog("ABL: Init")

        var timeInfo = mach_timebase_info_data_t()
        mach_timebase_info(&timeInfo)

        // Create Link (don't have multiple instances)
        // Always initialized with a tempo, even if just a default
        // Use app tempo unless there is an existing tempo from the network
        let linkRef: ABLLinkRef = ABLLinkNew(bpm)
        let sharedEngineData = ABLEngineData()
        let localEngineData = ABLEngineData()

        linkData = ABLLinkData(
            linkRef: linkRef,
            sampleRate: AVAudioSession.sharedInstance().sampleRate,
            secondsToHostTime: (1.0e9 * Float64(timeInfo.denom)) / Float64(timeInfo.numer),
            sharedEngineData: sharedEngineData,
            localEngineData: localEngineData,
            timeAtLastClick: 0,
            isPlaying: false)

        addListeners()
    }

    // MARK: Listeners

    /// Add listeners to subscribe changes. Don't forget to keep a reference of your listener and remove it after you're done.
    ///
    /// - Parameter type: Listener type with callback.
    /// - Returns: Listener reference that you can unsubscribe later.
    @discardableResult public func add(listener type: ABLLinkManagerListenerType) -> ABLLinkManagerListener {
        let listener = ABLLinkManagerListener(type: type)
        listeners.append(listener)
        return listener
    }

    /// Unsubscribes your listener after you're done.
    ///
    /// - Parameter listener: Listener you want to remove.
    /// - Returns: Returns result of the operation.
    @discardableResult public func remove(listener: ABLLinkManagerListener) -> Bool {
        guard let index = listeners.index(of: listener) else { return false }
        listeners.remove(at: index)
        return true
    }

    /// Removes all listeners.
    public func removeAllListeners() {
        listeners = []
    }

    // MARK: Update

    // Metronome loop sub function
    private func updatedEngineData() -> ABLEngineData? {
        guard var linkData = linkData else { return nil }

        //create new engine object with generic values
        var output = ABLEngineData()

        // Always reset the signaling members to their default state
        output.resetToBeatTime = ABLLinkManager.INVALID_BEAT_TIME
        output.proposeBpm = ABLLinkManager.INVALID_BPM
        output.requestStart = false
        output.requestStop = false

        // Attempt to grab the lock guarding the shared engine data but
        // don't block if we can't get it.
        if os_unfair_lock_trylock(&lock) {
            // Copy non-signaling members to the local thread cache
            linkData.localEngineData.outputLatency = linkData.sharedEngineData.outputLatency
            linkData.localEngineData.quantum = linkData.sharedEngineData.quantum

            // Copy signaling members directly to the output and reset
            output.resetToBeatTime = linkData.sharedEngineData.resetToBeatTime
            linkData.sharedEngineData.resetToBeatTime = ABLLinkManager.INVALID_BEAT_TIME

            output.requestStart = linkData.sharedEngineData.requestStart
            linkData.sharedEngineData.requestStart = false

            output.requestStop = linkData.sharedEngineData.requestStop
            linkData.sharedEngineData.requestStop = false

            output.proposeBpm = linkData.sharedEngineData.proposeBpm
            linkData.sharedEngineData.proposeBpm = ABLLinkManager.INVALID_BPM

            self.linkData = linkData
            os_unfair_lock_unlock(&lock)
        }

        // Copy from the thread local copy to the output. This happens
        // whether or not we were able to grab the lock.
        output.outputLatency = linkData.localEngineData.outputLatency
        output.quantum = linkData.localEngineData.quantum

        if output.proposeBpm != ABLLinkManager.INVALID_BEAT_TIME {
            AKLog("ABL: output propose bpm = ", output.proposeBpm)
        }

        return output
    }

    public func update() {
        guard var linkData = linkData,
            let sessionState = ABLLinkCaptureAudioSessionState(linkData.linkRef),
            let engineData = updatedEngineData() // update engine data
            else { return }

        // The mHostTime member of the timestamp represents the time at
        // which the buffer is delivered to the audio hardware. The output
        // latency is the time from when the buffer is delivered to the
        // audio hardware to when the beginning of the buffer starts
        // reaching the output. We add those values to get the host time
        // at which the first sample of this buffer will reach the output.
        let hostTimeAtBufferBegin: UInt64 = mach_absolute_time() + UInt64(engineData.outputLatency)

        if engineData.requestStart && !ABLLinkIsPlaying(sessionState) {
            // Request starting playback at the beginning of this buffer.
            ABLLinkSetIsPlaying(sessionState, true, hostTimeAtBufferBegin)
            print("start requested")
        }

        if engineData.requestStop && ABLLinkIsPlaying(sessionState) {
            // Request stopping playback at the beginning of this buffer.
            ABLLinkSetIsPlaying(sessionState, false, hostTimeAtBufferBegin)
            print("stop requested")
        }

        if !linkData.isPlaying && ABLLinkIsPlaying(sessionState) {
            // Reset the session state's beat timeline so that the requested
            // beat time corresponds to the time the transport will start playing.
            // The returned beat time is the actual beat time mapped to the time
            // playback will start, which therefore may be less than the requested
            // beat time by up to a quantum.
            ABLLinkRequestBeatAtStartPlayingTime(sessionState, 0, engineData.quantum)
            linkData.isPlaying = true
        } else if linkData.isPlaying && !ABLLinkIsPlaying(sessionState) {
            linkData.isPlaying = false
        }

        // Handle a tempo proposal
        if engineData.proposeBpm != ABLLinkManager.INVALID_BPM {
            // Propose that the new tempo takes effect at the beginning of this buffer.
            ABLLinkSetTempo(sessionState, engineData.proposeBpm, hostTimeAtBufferBegin)
            AKLog("ABL: Proposed BPM = ", engineData.proposeBpm)
        }

        //post the current position after doing the updates
        ABLLinkCommitAudioSessionState(linkData.linkRef, sessionState)
        self.linkData = linkData
        AKLog("ABL: Current beat = ", beatTime)
    }

    // MARK: Listeners

    private func addListeners() {
        // Route change
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRouteChange),
            name: AVAudioSession.routeChangeNotification,
            object: AVAudioSession.sharedInstance())

        guard let ref = linkData?.linkRef else {
            AKLog("ABL: Error getting linkRef when adding listeners")
            return
        }

        // Void pointer to self for C callbacks below
        // http://stackoverflow.com/questions/33260808/swift-proper-use-of-cfnotificationcenteraddobserver-w-callback
        let selfAsURP = UnsafeRawPointer(Unmanaged.passUnretained(self).toOpaque())
        let selfAsUMRP = UnsafeMutableRawPointer(mutating: selfAsURP)

        // Add listerner to detect tempo changes from other devices

        ABLLinkSetSessionTempoCallback(ref, { sessionTempo, context in
            if let context = context {
                let localSelf = Unmanaged<ABLLinkManager>.fromOpaque(context).takeUnretainedValue()
                let localSelfAsUMRP = UnsafeMutableRawPointer(mutating: context)
                localSelf.onSessionTempoChanged(bpm: sessionTempo, context: localSelfAsUMRP)
            }
        }, selfAsUMRP)

        ABLLinkSetIsEnabledCallback(ref, { isEnabled, context in
            if let context = context {
                let localSelf = Unmanaged<ABLLinkManager>.fromOpaque(context).takeUnretainedValue()
                let localSelfAsUMRP = UnsafeMutableRawPointer(mutating: context)
                localSelf.onLinkEnabled(isEnabled: isEnabled, context: localSelfAsUMRP)
            }
        }, selfAsUMRP)

        ABLLinkSetIsConnectedCallback(ref, { isConnected, context in
            if let context = context {
                let localSelf = Unmanaged<ABLLinkManager>.fromOpaque(context).takeUnretainedValue()
                let localSelfAsUMRP = UnsafeMutableRawPointer(mutating: context)
                localSelf.onConnectionStatusChanged(isConnected: isConnected, context: localSelfAsUMRP)
            }
        }, selfAsUMRP)
    }

    // Route change
    @objc internal func handleRouteChange() {
        guard var linkData = linkData else {
            AKLog("ABL: Error accesing LinkData during route change")
            return
        }

        let outputLatency: UInt32 = UInt32(linkData.secondsToHostTime * AVAudioSession.sharedInstance().outputLatency)
        os_unfair_lock_lock(&lock)
        linkData.sharedEngineData.outputLatency = outputLatency
        self.linkData = linkData
        os_unfair_lock_unlock(&lock)
        AKLog("ABL: Route change")
    }

    // Tempo changes from other Link devices
    private func onSessionTempoChanged(bpm: Double, context: Optional<UnsafeMutableRawPointer>) {
        AKLog("ABL: onSessionTempoChanged")
        //update local var
        self.bpm = bpm
        AKLog("ABL: curr bpm", bpm)

        // Inform listeners
        for listener in listeners {
            if case .tempo(let callback) = listener.type {
                callback(bpm, quantum)
            }
        }
    }

    // On Link enabled
    private func onLinkEnabled(isEnabled: Bool, context: Optional<UnsafeMutableRawPointer>) {
        AKLog("ABL: Link is", isEnabled)

        // Inform listeners
        for listener in listeners {
            if case .activation(let callback) = listener.type {
                callback(isEnabled)
            }
        }
    }

    // Connection Status from ther devices changed
    private func onConnectionStatusChanged(isConnected: Bool, context: Optional<UnsafeMutableRawPointer>) -> () {
        AKLog("ABL: onConnectionStatusChanged: isConnected = ", isConnected)

        // Inform listeners
        for listener in listeners {
            if case .connection(let callback) = listener.type {
                callback(isConnected)
            }
        }
    }
    #endif
}

class AKLinkButton: SynthButton {

    #if ABLETON_ENABLED_1
    private var realSuperView: UIView?
    private var controller: UIViewController?
    private var linkViewController: ABLLinkSettingsViewController?

    /// Use this when your button's superview is not the entire screen, or when you prefer
    /// the aesthetics of a centered popup window to one with an arrow pointing to your button
    public func centerPopupIn(view: UIView) {
        realSuperView = view
    }

    /// Handle touches
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        let linkViewController = ABLLinkSettingsViewController.instance(ABLLinkManager.shared.linkRef)
        let navController = UINavigationController(rootViewController: linkViewController!)

        navController.modalPresentationStyle = .popover

        let popC = navController.popoverPresentationController
        let centerPopup = realSuperView != nil
        let displayView = realSuperView ?? self.superview

        popC?.permittedArrowDirections = centerPopup ? [] : .any
        popC?.sourceRect = centerPopup ? CGRect(x: displayView!.bounds.midX,
                                                y: displayView!.bounds.midY,
                                                width: 0,
                                                height: 0) : self.frame

        controller = displayView!.next as? UIViewController
        controller?.present(navController, animated: true, completion: nil)

        popC?.sourceView = controller?.view
        linkViewController?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                                                target: self,
                                                                                action: #selector(doneAction))

    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Do nothing to avoid changing selected state
    }

    @objc public func doneAction() {
        controller?.dismiss(animated: true, completion: nil)
        value = ABLLinkManager.shared.isEnabled ? 1 : 0
    }
    #endif

}
