//
//  serverViewController.swift
//  MultiTouch
//
//  Created by Aidan Cornelius-Bell on 15/6/2023.
//

import Cocoa
import OSCKit

class serverViewController: NSViewController {
    
    @IBOutlet var serverLog: NSTextView!
    
    var oscPort = UInt16()
    let oscServer = OSCServer(port: 8888) { message, _ in
        print("Received \(message)")
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
                
        do {
            try oscServer.start()
        } catch {
        }
        
        oscServer.setHandler { [weak self] oscMessage, timeTag in
            // Note: handler is called on the main thread
            // and is thread-safe in case it results in UI updates
            do {
                try self?.handle(received: oscMessage)
            } catch {
                print(error)
            }
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.level = .floating
    }
    
    @IBAction func clearLog(_ sender: Any) {
        serverLog.string = ""
    }
    
    
    private func handle(received oscMessage: OSCMessage) throws {
        // handle received messages here
        
        serverLog.string = "\(oscMessage) \n" + serverLog.string
    }

    
}
