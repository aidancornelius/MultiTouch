//
//  ViewController.swift
//  MultiTouch
//
//  Created by Aidan Cornelius-Bell on 12/6/2023.
//

import Cocoa

class ViewController: NSViewController {
    
    // Setup the view stuff
    @IBOutlet weak var logView: NSScrollView!
    @IBOutlet var logField: NSTextView!
    @IBOutlet weak var cursorCapture: NSButtonCell!
    
    var curcap = 0
    
    // single 0 outputs
    @IBOutlet weak var absXField: NSTextField!
    @IBOutlet weak var absYField: NSTextField!
    @IBOutlet weak var absZField: NSTextField!
    
    // multi 0 outputs (may be the same as single 0?)
    @IBOutlet weak var xCMul0: NSTextField!
    @IBOutlet weak var yCMul0: NSTextField!
    @IBOutlet weak var zCMul0: NSTextField!
    
    
    // multi 1 outputs
    @IBOutlet weak var xCMul1: NSTextField!
    @IBOutlet weak var yCMul1: NSTextField!
    @IBOutlet weak var zCMul1: NSTextField!
    
    
    // multi 2 outputs
    @IBOutlet weak var xCMul2: NSTextField!
    @IBOutlet weak var yCMul2: NSTextField!
    @IBOutlet weak var zCMul2: NSTextField!
    
    // multi 3 outputs
    @IBOutlet weak var xCMul3: NSTextField!
    @IBOutlet weak var yCMul3: NSTextField!
    @IBOutlet weak var zCMul3: NSTextField!
    
    // multi 4 outputs
    @IBOutlet weak var xCMul4: NSTextField!
    @IBOutlet weak var yCMul4: NSTextField!
    @IBOutlet weak var zCMul4: NSTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Let's tell the view we want those touches, please:
        view.allowedTouchTypes = [NSTouch.TouchTypeMask.direct, NSTouch.TouchTypeMask.indirect];
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.zoom(self)
    }
    
    // A cheap and dirty way of capturing the cursor and screen to disable system touch events (expose etc)
    @IBAction func captureCursor(_ sender: Any) {
        if curcap == 0 {
            CGDisplayHideCursor(CGDirectDisplayID())
            // CGDisplayCaptureWithOptions(CGDirectDisplayID(), CGCaptureOptions.noFill)
            curcap = 1
        } else {
            CGDisplayShowCursor(CGDirectDisplayID())
            // CGDisplayRelease(CGDirectDisplayID())
            curcap = 0
        }
    }
    
    override func touchesMoved(with event: NSEvent) {
        // get the log running
        var logValue = logField.string
        let timeInterval = NSDate().timeIntervalSince1970
        
        // var for counter (this is very rudimentary and bad form)
        var counter = 0
        
        // vars for touches:
        var firstTouchX = 0 as CGFloat
        var firstTouchY = 0 as CGFloat
        var secondTouchX = 0 as CGFloat
        var secondTouchY = 0 as CGFloat
        var thirdTouchX = 0 as CGFloat
        var thirdTouchY = 0 as CGFloat
        var fourthTouchX = 0 as CGFloat
        var fourthTouchY = 0 as CGFloat
        var fifthTouchX = 0 as CGFloat
        var fifthTouchY = 0 as CGFloat
        
        // debugs
        var firstDebug = ""
        var secondDebug = ""
        var thirdDebug = ""
        var fourthDebug = ""
        var fifthDebug = ""
        
        // These are single touches (i.e. just the mouse cursor)
        absXField.stringValue = "\(event.locationInWindow.x)"
        absYField.stringValue = "\(event.locationInWindow.y)"
        absZField.stringValue = "\(event.type.hashValue)"
        
        // These are "all touches" (i.e. multitouch)
        var allTouches = event.allTouches()
        // Get the indices from whatever we've just received
        var touchIndices = [Set<NSTouch>.Index]()
        for index in allTouches.indices {
            touchIndices.append(index)
        }
        
        NSLog("THESE INDICES: \(touchIndices.count)")
        
        for index in touchIndices {
            switch(counter) {
                case 0:
                    firstTouchX = allTouches[index].normalizedPosition.x
                    firstTouchY = allTouches[index].normalizedPosition.y
                    // log the touch for debg
                    firstDebug = ("I: \(counter) X: \(firstTouchX) Y: \(firstTouchY)") + logValue
                    zCMul0.stringValue = firstDebug
                    counter = counter + 1
                case 1:
                    secondTouchX = allTouches[index].normalizedPosition.x
                    secondTouchY = allTouches[index].normalizedPosition.y
                    // log the touch for debg
                    secondDebug = ("I: \(counter) X: \(secondTouchX) Y: \(secondTouchY)") + logValue
                    zCMul1.stringValue = secondDebug
                    counter = counter + 1
                case 2:
                    thirdTouchX = allTouches[index].normalizedPosition.x
                    thirdTouchY = allTouches[index].normalizedPosition.y
                    // log the touch for debg
                    thirdDebug = ("I: \(counter) X: \(thirdTouchX) Y: \(thirdTouchY)") + logValue
                    zCMul2.stringValue = thirdDebug
                    counter = counter + 1
                case 3:
                    fourthTouchX = allTouches[index].normalizedPosition.x
                    fourthTouchY = allTouches[index].normalizedPosition.y
                    // log the touch for debg
                    fourthDebug = ("I: \(counter) X: \(fourthTouchX) Y: \(fourthTouchY)") + logValue
                    zCMul3.stringValue = fourthDebug
                    counter = counter + 1
                case 4:
                    fifthTouchX = allTouches[index].normalizedPosition.x
                    fifthTouchY = allTouches[index].normalizedPosition.y
                    // log the touch for debg
                    fifthDebug = ("I: \(counter) X: \(fifthTouchX) Y: \(fifthTouchY)") + logValue
                    zCMul4.stringValue = fifthDebug
                    counter = counter + 1
                default:
                    counter = counter + 1
            }

        }
  
        xCMul0.stringValue = "\(firstTouchX)"
        yCMul0.stringValue = "\(firstTouchY)"
        
        xCMul1.stringValue = "\(secondTouchX)"
        yCMul1.stringValue = "\(secondTouchY)"
        
        xCMul2.stringValue = "\(thirdTouchX)"
        yCMul2.stringValue = "\(thirdTouchY)"
        
        xCMul3.stringValue = "\(fourthTouchX)"
        yCMul3.stringValue = "\(fourthTouchY)"
        
        xCMul4.stringValue = "\(fifthTouchX)"
        yCMul4.stringValue = "\(fifthTouchY)"
        
        logValue = "[Update last touch @e\(timeInterval)] \(allTouches.first?.normalizedPosition.x)\n" + logValue
        logField.string = logValue
    }
    
    override func touchesBegan(with event: NSEvent) {
        // Now to the screen
        let timeInterval = NSDate().timeIntervalSince1970
        var logValue = logField.string
        logValue = "[New touch @e\(timeInterval)] \(event)\n" + logValue
        logField.string = logValue
    }


}

