//
//  ViewController.swift
//  MultiTouch
//
//  Created by Aidan Cornelius-Bell on 12/6/2023.
//

import Cocoa
import OSCKit

class ViewController: NSViewController {
    
    // Setup the view stuff
    @IBOutlet weak var logView: NSScrollView!
    @IBOutlet var logField: NSTextView!
    @IBOutlet weak var cursorCapture: NSButtonCell!
    @IBOutlet weak var loggingButton: NSButton!
    
    // Have we got the cursor, Jim?
    var curcap = 0
    @IBOutlet weak var ipAddressField: NSTextField!
    @IBOutlet weak var TUIOButton: NSButton!
    @IBOutlet weak var OSCButton: NSButton!
    
    // Do we want to verbosely log everything (the compositor has a fit if we do)
    var sendLogs = 1
    
    // OSC setup stuff
    let oscClient = OSCClient()
    // Are we...
    var sendingControl = false
    var sendingToOSC = false
    var sendingToTUIO = false
    var sendingToIP = "127.0.0.1"
    
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
    
    // Switch for logging
    @IBAction func loggingButtonAction(_ sender: Any) {
        if sendLogs == 1 {
            sendLogs = 0
            loggingButton.title = "Enable logging (slows things down)"
        } else {
            sendLogs = 1
            loggingButton.title = "Disable logging (speeds things up)"
        }
    }
    
    // Start server as an OSC client (lol JK its just port selection)
    @IBAction func oscButtonAction(_ sender: Any) {
        if sendingControl == false {
            sendingToIP = ipAddressField.stringValue
            sendingControl = true
            sendingToOSC = true
            sendingToTUIO = false
            OSCButton.title = "OSC Client Running (UDP 8888)"
        } else {
            sendingToIP = ipAddressField.stringValue
            sendingControl = false
            sendingToOSC = false
            sendingToTUIO = false
            OSCButton.title = "Route to OSC (UDP 8888)"
            TUIOButton.title = "Route to TUIO (UDP 3333)"
        }
    }
    
    // or a TUIO client ... (again, just port selection)
    @IBAction func tuioButtonAction(_ sender: Any) {
        if sendingControl == false {
            sendingToIP = ipAddressField.stringValue
            sendingControl = true
            sendingToOSC = false
            sendingToTUIO = true
            TUIOButton.title = "TUIO Client Running (UDP 3333)"
        } else {
            sendingToIP = ipAddressField.stringValue
            sendingControl = false
            sendingToOSC = false
            sendingToTUIO = false
            OSCButton.title = "Route to OSC (UDP 8888)"
            TUIOButton.title = "Route to TUIO (UDP 3333)"
        }
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
        if sendLogs == 1 {
            absXField.stringValue = "\(event.locationInWindow.x)"
            absYField.stringValue = "\(event.locationInWindow.y)"
            absZField.stringValue = "\(event.type.hashValue)"
        }
        // These are "all touches" (i.e. multitouch)
        var allTouches = event.allTouches()
        // Get the indices from whatever we've just received
        var touchIndices = [Set<NSTouch>.Index]()
        for index in allTouches.indices {
            touchIndices.append(index)
        }
        
        NSLog("THESE INDICES: \(touchIndices.count)")
        
        // This loop creates x/y for all the touches as VARS
        for index in touchIndices {
            switch(counter) {
                case 0:
                    firstTouchX = allTouches[index].normalizedPosition.x
                    firstTouchY = allTouches[index].normalizedPosition.y
                    // log the touch for debg
                    if sendLogs == 1 {
                        firstDebug = ("I: \(counter) X: \(firstTouchX) Y: \(firstTouchY)") + logValue
                        zCMul0.stringValue = firstDebug
                    }
                    counter = counter + 1
                case 1:
                    secondTouchX = allTouches[index].normalizedPosition.x
                    secondTouchY = allTouches[index].normalizedPosition.y
                    // log the touch for debg
                    if sendLogs == 1 {
                        secondDebug = ("I: \(counter) X: \(secondTouchX) Y: \(secondTouchY)") + logValue
                        zCMul1.stringValue = secondDebug
                    }
                    counter = counter + 1
                case 2:
                    thirdTouchX = allTouches[index].normalizedPosition.x
                    thirdTouchY = allTouches[index].normalizedPosition.y
                    // log the touch for debg
                    if sendLogs == 1 {
                        thirdDebug = ("I: \(counter) X: \(thirdTouchX) Y: \(thirdTouchY)") + logValue
                        zCMul2.stringValue = thirdDebug
                    }
                    counter = counter + 1
                case 3:
                    fourthTouchX = allTouches[index].normalizedPosition.x
                    fourthTouchY = allTouches[index].normalizedPosition.y
                    // log the touch for debg
                    if sendLogs == 1 {
                        fourthDebug = ("I: \(counter) X: \(fourthTouchX) Y: \(fourthTouchY)") + logValue
                        zCMul3.stringValue = fourthDebug
                    }
                    counter = counter + 1
                case 4:
                    fifthTouchX = allTouches[index].normalizedPosition.x
                    fifthTouchY = allTouches[index].normalizedPosition.y
                    // log the touch for debg
                    if sendLogs == 1 {
                        fifthDebug = ("I: \(counter) X: \(fifthTouchX) Y: \(fifthTouchY)") + logValue
                        zCMul4.stringValue = fifthDebug
                    }
                    counter = counter + 1
                default:
                    counter = counter + 1
            }

        }
        
        // If we're sending to TUIO/OSC this is where that happens
        // First we determine if we want to do that:
        
        if sendingControl == true {
            var msgPort = UInt16(8888)
            
            // We'll send stuff as OSC (it's all tuio anyway)
            if sendingToOSC == true {
                msgPort = 8888
            }
            // We'll send stuff as TUIO
            if sendingToTUIO == true {
                msgPort = 3333
            }
            
            // Actually send the messages...
            do {
                // Bundle x/y for first touch
                let firstBundle = OSCBundle([
                    .message("/tuio/2D/cur/0/alive", values: [1]),
                    .message("/tuio/2D/cur/0", values: [firstTouchX, firstTouchY]),
                    .message("/tuio/2D/cur/1/alive", values: [1]),
                    .message("/tuio/2D/cur/1", values: [secondTouchX, secondTouchY]),
                    .message("/tuio/2D/cur/2/alive", values: [1]),
                    .message("/tuio/2D/cur/2", values: [thirdTouchX, thirdTouchY]),
                    .message("/tuio/2D/cur/3/alive", values: [1]),
                    .message("/tuio/2D/cur/3", values: [fourthTouchX, fourthTouchY]),
                    .message("/tuio/2D/cur/4/alive", values: [1]),
                    .message("/tuio/2D/cur/4", values: [fifthTouchX, fifthTouchY])
                    
                ])
                
                
                try oscClient.send(firstBundle, to: sendingToIP, port: msgPort)
                
            } catch {
                // Just put the error everywhere we can
                NSLog("There was a oscClient error: \(error)")
                logValue = "[CLIENT ERROR @e\(timeInterval)] \(error)\n" + logValue
                logField.string = logValue
            }
            
        }
        
        // Only send everything if logging is on
        if sendLogs == 1 {
            // This just updates the values of text boxes on the monitor
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
        }
    }
    
    override func touchesBegan(with event: NSEvent) {
        if sendLogs == 1 {
            // Now to the screen
            let timeInterval = NSDate().timeIntervalSince1970
            var logValue = logField.string
            logValue = "[New touch @e\(timeInterval)] \(event)\n" + logValue
            logField.string = logValue
        }
    }


}

