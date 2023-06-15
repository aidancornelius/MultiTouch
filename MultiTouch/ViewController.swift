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
    @IBOutlet weak var frameCounterDisplay: NSTextField!
    
    // Do we want to bundle the sent messages?
    var bundleMessages = 0
    
    // frame counter
    var frameCount = 0
    
    // Do we want to verbosely log everything (the compositor has a fit if we do)
    var sendLogs = 1
    
    // OSC setup stuff
    let oscClient = OSCClient()
    // Are we...
    var sendingControl = false
    var sendingToOSC = false
    var sendingToTUIO = false
    var sendingToIP = "127.0.0.1"
    
    // Give an indication of what we're seeing
    @IBOutlet weak var numbTouches: NSTextField!
    
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
    
    // origin points for each touch xy (for velocity calcs)
    // TODO: better as an array but this whole project is already a mess
    var ptOneoX = 0 as CGFloat
    var ptOneoY = 0 as CGFloat
    var ptTwooX = 0 as CGFloat
    var ptTwooY = 0 as CGFloat
    var ptThreeoX = 0 as CGFloat
    var ptThreeoY = 0 as CGFloat
    var ptFouroX = 0 as CGFloat
    var ptFouroY = 0 as CGFloat
    var ptFiveoX = 0 as CGFloat
    var ptFiveoY = 0 as CGFloat
    var ptSixoX = 0 as CGFloat
    var ptSixoY = 0 as CGFloat
    var ptSevenoX = 0 as CGFloat
    var ptSevenoY = 0 as CGFloat

    
    
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
            if ipAddressField.stringValue != "" {
                sendingToIP = ipAddressField.stringValue
            }
            sendingControl = true
            sendingToOSC = true
            sendingToTUIO = false
            OSCButton.title = "OSC Client Running (UDP 8888)"
            
            let timeInterval = NSDate().timeIntervalSince1970
            var logValue = logField.string
            logValue = "[New client @e\(timeInterval)] Starting an OSC Client at \(sendingToIP):8888\n" + logValue
            logField.string = logValue
        } else {
            if ipAddressField.stringValue != "" {
                sendingToIP = ipAddressField.stringValue
            }
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
            if ipAddressField.stringValue != "" {
                sendingToIP = ipAddressField.stringValue
            }
            sendingControl = true
            sendingToOSC = false
            sendingToTUIO = true
            TUIOButton.title = "TUIO Client Running (UDP 3333)"
            
            let timeInterval = NSDate().timeIntervalSince1970
            var logValue = logField.string
            logValue = "[New client @e\(timeInterval)] Starting a TUIO Client at \(sendingToIP):3333\n" + logValue
            logField.string = logValue
        } else {
            if ipAddressField.stringValue != "" {
                sendingToIP = ipAddressField.stringValue
            }
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
        frameCount = frameCount + 1
        
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
        var sixthTouchX = 0 as CGFloat
        var sixthTouchY = 0 as CGFloat
        var seventhTouchX = 0 as CGFloat
        var seventhTouchY = 0 as CGFloat
        
        
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
        
        // This loop creates x/y for all the touches as VARS
        for index in touchIndices {
            switch(counter) {
                case 0:
                    firstTouchX = allTouches[index].normalizedPosition.x
                    firstTouchY = allTouches[index].normalizedPosition.y
                    counter = counter + 1
                case 1:
                    secondTouchX = allTouches[index].normalizedPosition.x
                    secondTouchY = allTouches[index].normalizedPosition.y
                    counter = counter + 1
                case 2:
                    thirdTouchX = allTouches[index].normalizedPosition.x
                    thirdTouchY = allTouches[index].normalizedPosition.y
                    counter = counter + 1
                case 3:
                    fourthTouchX = allTouches[index].normalizedPosition.x
                    fourthTouchY = allTouches[index].normalizedPosition.y
                    counter = counter + 1
                case 4:
                    fifthTouchX = allTouches[index].normalizedPosition.x
                    fifthTouchY = allTouches[index].normalizedPosition.y
                    counter = counter + 1
                case 5:
                    sixthTouchX = allTouches[index].normalizedPosition.x
                    sixthTouchY = allTouches[index].normalizedPosition.y
                    counter = counter + 1
                case 6:
                    seventhTouchX = allTouches[index].normalizedPosition.x
                    seventhTouchY = allTouches[index].normalizedPosition.y
                    counter = counter + 1
                default:
                    counter = counter + 1
            }

        }
        
        // use that counter to tell people how many touches there are
        numbTouches.stringValue = "\(counter) inputs detected"
        
        // convert these vars to float32s
        let firstTcX = Float32(firstTouchX)
        let firstTcY = Float32(firstTouchY)
        let secondTcX = Float32(secondTouchX)
        let secondTcY = Float32(secondTouchY)
        let thirdTcX = Float32(thirdTouchX)
        let thirdTcY = Float32(thirdTouchY)
        let fourthTcX = Float32(fourthTouchX)
        let fourthTcY = Float32(fourthTouchY)
        let fifthTcX = Float32(fifthTouchX)
        let fifthTcY = Float32(fifthTouchY)
        let sixthTcX = Float32(sixthTouchX)
        let sixthTcY = Float32(sixthTouchY)
        let seventhTcX = Float32(seventhTouchX)
        let seventhTcY = Float32(seventhTouchY)
        
        // rudimentary velocity calculation (this is not REAL velocity, its more imputed based on the idea that every touch is "1" seconds???)
        // for later the idea is v = (current point / origin point) / time
        let veloFirstTcX = Float32( (firstTcX - Float32(ptOneoX)) / 1 )
        let veloFirstTcY = Float32( (firstTcY - Float32(ptOneoY)) / 1 )
        
        let veloSecondTcX = Float32( (secondTcX - Float32(ptTwooX)) / 1 )
        let veloSecondTcY = Float32( (secondTcY - Float32(ptTwooY)) / 1 )
        
        let veloThirdTcX = Float32( (thirdTcX - Float32(ptThreeoX)) / 1 )
        let veloThirdTcY = Float32( (thirdTcY - Float32(ptThreeoY)) / 1 )
        
        let veloFourthTcX = Float32( (fourthTcX - Float32(ptFouroX)) / 1 )
        let veloFourthTcY = Float32( (fourthTcY - Float32(ptFouroY)) / 1 )

        let veloFifthTcX = Float32( (fifthTcX - Float32(ptFiveoX)) / 1 )
        let veloFifthTcY = Float32( (fifthTcY - Float32(ptFiveoY)) / 1 )
        
        let veloSixthTcX = Float32( (sixthTcX - Float32(ptSixoX)) / 1 )
        let veloSixthTcY = Float32( (sixthTcY - Float32(ptSixoY)) / 1 )
        
        let veloSeventhTcX = Float32( (seventhTcX - Float32(ptSevenoX)) / 1 )
        let veloSeventhTcY = Float32( (seventhTcY - Float32(ptSevenoY)) / 1 )
        
        //NSLog("\(veloFirstTcX) \(veloFirstTcY)")
        
        // TODO: Implement acceleration?
        let accelerationTc = Float32(0)
        
        
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
                    // nuanced messaging switch on 'counter'
                    // THIS IS MORE OSC STYLE
                    if counter >= 1 {
                        // first touch
                        
                        /*
                         -> Model:
                         /tuio/2Dcur source application@address
                         /tuio/2Dcur alive s_id0 ... s_idN
                         /tuio/2Dcur set s_id x_pos y_pos x_vel y_vel m_accel
                         /tuio/2Dcur fseq f_id
                         
                         "/tuio/2Dcur", values: ["set", 1, 0.27905, 0.56307566, -0.05301274, 0.0, 3.187613]
                         
                         TODO: Send the actual address of the server...
                         */
                        let firstBundle = OSCBundle([
                            .message("/tuio/2Dcur", values: ["source", "multiTouch@127.0.0.1"]),
                            .message("/tuio/2Dcur", values: ["alive", 1]),
                            .message("/tuio/2Dcur", values: ["set", 1, firstTcX, firstTcY, veloFirstTcX, veloFirstTcY, accelerationTc]),
                            .message("/tuio/2Dcur", values: ["fseq", frameCount])])
                        
                        // send
                        try oscClient.send(firstBundle, to: sendingToIP, port: msgPort)
                        frameCount = frameCount + 1
                    }
                    if counter >= 2 {
                        // second touch
                        let secondBundle = OSCBundle([
                            .message("/tuio/2Dcur", values: ["source", "multiTouch@127.0.0.1"]),
                            .message("/tuio/2Dcur", values: ["alive", 2]),
                            .message("/tuio/2Dcur", values: ["set", 2, secondTcX, secondTcY, veloSecondTcX, veloSecondTcY, accelerationTc]),
                            .message("/tuio/2Dcur", values: ["fseq", frameCount])])
                        
                        // send
                        try oscClient.send(secondBundle, to: sendingToIP, port: msgPort)
                        frameCount = frameCount + 1
                    }
                    
                    if counter >= 3 {
                        // third touch
                        let thirdBundle = OSCBundle([
                            .message("/tuio/2Dcur", values: ["source", "multiTouch@127.0.0.1"]),
                            .message("/tuio/2Dcur", values: ["alive", 3]),
                            .message("/tuio/2Dcur", values: ["set", 3, thirdTcX, thirdTcY, veloThirdTcX, veloThirdTcY, accelerationTc]),
                            .message("/tuio/2Dcur", values: ["fseq", frameCount])])
                        
                        // send
                        try oscClient.send(thirdBundle, to: sendingToIP, port: msgPort)
                        frameCount = frameCount + 1
                    }
                    
                    if counter >= 4 {
                        // fourth touch
                        let fourthBundle = OSCBundle([
                            .message("/tuio/2Dcur", values: ["source", "multiTouch@127.0.0.1"]),
                            .message("/tuio/2Dcur", values: ["alive", 4]),
                            .message("/tuio/2Dcur", values: ["set", 4, fourthTcX, fourthTcY, veloFourthTcX, veloFourthTcY, accelerationTc]),
                            .message("/tuio/2Dcur", values: ["fseq", frameCount])])
                        
                        // send
                        try oscClient.send(fourthBundle, to: sendingToIP, port: msgPort)
                        frameCount = frameCount + 1
                    }
                    
                    if counter >= 5 {
                        // fifth touch
                        let fifthBundle = OSCBundle([
                            .message("/tuio/2Dcur", values: ["source", "multiTouch@127.0.0.1"]),
                            .message("/tuio/2Dcur", values: ["alive", 5]),
                            .message("/tuio/2Dcur", values: ["set", 5, fifthTcX, fifthTcY, veloFifthTcX, veloFifthTcY, accelerationTc]),
                            .message("/tuio/2Dcur", values: ["fseq", frameCount])])
                        
                        // send
                        try oscClient.send(fifthBundle, to: sendingToIP, port: msgPort)
                        frameCount = frameCount + 1
                    }
                    
                    if counter >= 6 {
                        // sixth touch
                        let sixthBundle = OSCBundle([
                            .message("/tuio/2Dcur", values: ["source", "multiTouch@127.0.0.1"]),
                            .message("/tuio/2Dcur", values: ["alive", 6]),
                            .message("/tuio/2Dcur", values: ["set", 6, sixthTcX, sixthTcY, veloSixthTcX, veloSixthTcY, accelerationTc]),
                            .message("/tuio/2Dcur", values: ["fseq", frameCount])])
                        
                        // send
                        try oscClient.send(sixthBundle, to: sendingToIP, port: msgPort)
                        frameCount = frameCount + 1
                    }
                    
                    if counter >= 7 {
                        // seventh touch
                        let seventhBundle = OSCBundle([
                            .message("/tuio/2Dcur", values: ["source", "multiTouch@127.0.0.1"]),
                            .message("/tuio/2Dcur", values: ["alive", 7]),
                            .message("/tuio/2Dcur", values: ["set", 7, seventhTcX, seventhTcY, veloSeventhTcX, veloSeventhTcY, accelerationTc]),
                            .message("/tuio/2Dcur", values: ["fseq", frameCount])])
                        
                        // send
                        try oscClient.send(seventhBundle, to: sendingToIP, port: msgPort)
                        frameCount = frameCount + 1
                    }
                } catch {
                    // Just put the error everywhere we can
                    NSLog("There was a oscClient error: \(error)")
                    logValue = "[CLIENT ERROR @e\(timeInterval)] \(error)\n" + logValue
                    logField.string = logValue
                }
                
                // TODO: tidily handle more touch points
                
            }
        
        frameCounterDisplay.stringValue = "\(frameCount)"
        
        // Only send everything if logging is on
        if sendLogs == 1 {
            // This just updates the values of text boxes on the monitor
            xCMul0.stringValue = "\(firstTouchX)"
            yCMul0.stringValue = "\(firstTouchY)"
            zCMul0.stringValue = "vX \(veloFirstTcX) vY \(veloFirstTcY)"
            
            xCMul1.stringValue = "\(secondTouchX)"
            yCMul1.stringValue = "\(secondTouchY)"
            zCMul1.stringValue = "vX \(veloSecondTcX) vY \(veloSecondTcY)"
            
            xCMul2.stringValue = "\(thirdTouchX)"
            yCMul2.stringValue = "\(thirdTouchY)"
            zCMul2.stringValue = "vX \(veloThirdTcX) vY \(veloThirdTcY)"
            
            xCMul3.stringValue = "\(fourthTouchX)"
            yCMul3.stringValue = "\(fourthTouchY)"
            zCMul3.stringValue = "vX \(veloFourthTcX) vY \(veloFourthTcY)"
            
            xCMul4.stringValue = "\(fifthTouchX)"
            yCMul4.stringValue = "\(fifthTouchY)"
            zCMul4.stringValue = "vX \(veloFifthTcX) vY \(veloFifthTcY)"
        }
    }
    
    override func touchesBegan(with event: NSEvent) {
        var counter = 0
        
        // These are "all touches" (i.e. multitouch)
        var allTouches = event.allTouches()
        // Get the indices from whatever we've just received
        var touchIndices = [Set<NSTouch>.Index]()
        for index in allTouches.indices {
            touchIndices.append(index)
        }
        
        // This loop creates x/y for all the touches as VARS
        for index in touchIndices {
            switch(counter) {
                case 0:
                    ptOneoX = allTouches[index].normalizedPosition.x
                    ptOneoY = allTouches[index].normalizedPosition.y
                    counter = counter + 1
                case 1:
                    ptTwooX = allTouches[index].normalizedPosition.x
                    ptTwooY = allTouches[index].normalizedPosition.y
                    counter = counter + 1
                case 2:
                    ptThreeoX = allTouches[index].normalizedPosition.x
                    ptThreeoY = allTouches[index].normalizedPosition.y
                    counter = counter + 1
                case 3:
                    ptFouroX = allTouches[index].normalizedPosition.x
                    ptFouroY = allTouches[index].normalizedPosition.y
                    counter = counter + 1
                case 4:
                    ptFiveoX = allTouches[index].normalizedPosition.x
                    ptFiveoY = allTouches[index].normalizedPosition.y
                    counter = counter + 1
                case 5:
                    ptSixoX = allTouches[index].normalizedPosition.x
                    ptSixoY = allTouches[index].normalizedPosition.y
                    counter = counter + 1
                case 6:
                    ptSevenoX = allTouches[index].normalizedPosition.x
                    ptSevenoY = allTouches[index].normalizedPosition.y
                    counter = counter + 1
                default:
                    counter = counter + 1
            }

        }
        
        if sendLogs == 1 {
            // Now to the screen
            let timeInterval = NSDate().timeIntervalSince1970
            var logValue = logField.string
            logValue = "[New touch @e\(timeInterval)] \(event)\n" + logValue
            logField.string = logValue
        }
    }


}

