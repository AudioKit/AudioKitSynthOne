//
//  MIDIToggleButton.swift
//  AudioKitSynthOne
//
//  Created by Marcus W. Hobbs on 3/24/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

class MIDIRecordButton: MIDIToggleButton {

    var circleView = UIView()
    var circleAnimator: UIViewPropertyAnimator?

    // Styling for the Circle
    static var recordColor =  #colorLiteral(red: 0.1803921569, green: 0.1803921569, blue: 0.2, alpha: 1)
    static var recordingAltColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)


    override var isOn: Bool {
        didSet {
            setNeedsDisplay()
            accessibilityValue = isOn ? NSLocalizedString("On", comment: "On") : NSLocalizedString("Off", comment: "Off")
            animateCircle()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        addCircle(frame: frame)
    }


    func animateCircle(reversed: Bool = false) {
        if !isOn {
            circleView.backgroundColor = MIDIRecordButton.recordColor
            return
        }

        circleAnimator = UIViewPropertyAnimator(duration: 0.5, curve: .easeInOut, animations: {
            self.circleView.backgroundColor = reversed ? MIDIRecordButton.recordColor : MIDIRecordButton.recordingAltColor
        })
        circleAnimator?.addCompletion({ (_) in
            self.animateCircle(reversed: !reversed)
        })
        circleAnimator?.startAnimation()
    }

    func addCircle(frame: CGRect) {
        // Paintcode Draw Code has an offset to the right/bottom side of the frame.
        // This hack takes the offset into account as we scale the button
        // between iPad and iPhone
        let paintCodeWidthOffset = frame.size.width * 0.06
        let paintCodeHeightOffset = frame.size.height * 0.1
        let circleSize = CGSize(width: frame.width / 2.5, height: frame.width / 2.5)

        circleView = UIView(frame: CGRect(
            x: frame.width / 2 - circleSize.width / 2 - paintCodeWidthOffset,
            y: frame.height / 2 - circleSize.width / 2 - paintCodeHeightOffset,
            width: circleSize.width,
            height: circleSize.height)
        )

        circleView.layer.cornerRadius = circleView.frame.height / 2
        circleView.backgroundColor = MIDIRecordButton.recordColor
        circleView.clipsToBounds = true

        self.addSubview(circleView)
        self.bringSubviewToFront(circleView)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // NO OP
        // TODO: We should fix this in ToggleButton.swift:52 because
        // it will cause two callbacks (touchesBegan & touchesEnded)
        // firing after each other
    }
}
