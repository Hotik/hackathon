//
//  ViewController.swift
//  SwiftMQTTExample
//
//  Created by Ankit Aggarwal on 10/11/15.
//  Copyright © 2015 Ankit. All rights reserved.
//

import UIKit
import SwiftMQTT

class MQTTViewController: UIViewController, MQTTSessionDelegate {
    
    var mqttSession: MQTTSession!
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var channelTextField: UITextField!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        channelTextField.text = "iot-2/type/MQTTDevice/id/device_id_dreamteam/cmd/foo/fmt/json"
        messageTextField.text = "{“message“ : “hello device from swift”}"
        
        textView.text = nil
        establishConnection()
        
        NotificationCenter.default.addObserver(self, selector: #selector(MQTTViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MQTTViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(MQTTViewController.hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    func hideKeyboard() {
        view.endEditing(true)
    }
    
    func keyboardWillShow(_ notification: Notification) {
        let userInfo = (notification as NSNotification).userInfo! as NSDictionary
        let kbHeight = (userInfo.object(forKey: UIKeyboardFrameBeginUserInfoKey) as! NSValue).cgRectValue.size.height
        bottomConstraint.constant = kbHeight
    }
    
    func keyboardWillHide(_ notification: Notification) {
        bottomConstraint.constant = 0
    }
    
    func establishConnection() {
        let host = "ffzwfp.messaging.internetofthings.ibmcloud.com"
        let port: UInt16 = 1883
        let clientID = "a:ffzwfp:dreamteam"
        
        mqttSession = MQTTSession(host: host, port: port, clientID: clientID, cleanSession: true, keepAlive: 120, useSSL: false)
        mqttSession.username = "a-ffzwfp-lpdqybeklk"
        mqttSession.password = "2STAwQm@O?5k+cMdiH"
        
        mqttSession.delegate = self
        appendStringToTextView("Trying to connect to \(host) on port \(port) for clientID \(clientID)")

        mqttSession.connect {
            if !$0 {
                self.appendStringToTextView("Error Occurred During connection \($1)")
                return
            }
            self.appendStringToTextView("Connected.")
            self.subscribeToChannel()
        }
    }
    
    func subscribeToChannel() {
        let subChannel = "iot-2/type/MQTTDevice/id/device_id_dreamteam/evt/bar/fmt/json"
        self.appendStringToTextView("Subscribing to channel...")
        mqttSession.subscribe(to: subChannel, delivering: .atMostOnce) {
            if !$0 {
                self.appendStringToTextView("Error Occurred During subscription \($1)")
                return
            }
            self.appendStringToTextView("Subscribed to \(subChannel)")
        }
    }
    
    func appendStringToTextView(_ string: String) {
        textView.text = "\(textView.text ?? "")\n\(string)"
        let range = NSMakeRange(textView.text.characters.count - 1, 1)
        textView.scrollRangeToVisible(range)
    }
    
    // MARK: - MQTTSessionDelegates

    func mqttSession(session: MQTTSession, received message: Data, in topic: String) {
		let string = String(data: message, encoding: .utf8)!
        appendStringToTextView("data received on topic \(topic) message \(string)")
    }
    func mqttDidReceive(message data: Data, in topic: String, from session: MQTTSession) {
        let string = String(data: data, encoding: .utf8)!
        appendStringToTextView("data received on topic \(topic) message \(string)")
        print("received data from topic \(topic)");
    }

    
    func mqttSocketErrorOccurred(session: MQTTSession) {
        appendStringToTextView("Socket Error")
    }
    
    func mqttDidDisconnect(session: MQTTSession) {
        appendStringToTextView("Session Disconnected.")
    }
    
    // MARK: - IBActions
    
    @IBAction func resetButtonPressed(_ sender: AnyObject) {
        textView.text = nil
//        channelTextField.text = nil
//        messageTextField.text = nil
        establishConnection()
    }
    
    @IBAction func sendButtonPressed(_ sender: AnyObject) {
		
		guard let channel = channelTextField.text, let message = messageTextField.text,
			!channel.isEmpty && !message.isEmpty
			else { return }
		
		let data = message.data(using: .utf8)!
		mqttSession.publish(data, in: channel, delivering: .atMostOnce, retain: false) {
			if !$0 {
				self.appendStringToTextView("Error Occurred During Publish \($1)")
				return
			}
			self.appendStringToTextView("Published \(message) on channel \(channel)")
		}
	}
    
    // http://stackoverflow.com/questions/26845307/generate-random-alphanumeric-string-in-swift
    func randomStringWithLength(_ len: Int) -> String {
        let letters = Array("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".characters)

        var randomString = String()
        for _ in 0..<len {
            let length = UInt32(letters.count)
            let rand = arc4random_uniform(length)
			randomString += String(letters[Int(rand)])
        }
        return String(randomString)
    }
}
