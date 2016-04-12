//
//  ChatSessionController.swift
//  ChatUI
//
//  Created by 1amageek on 2016/04/12.
//  Copyright © 2016年 Stamp inc. All rights reserved.
//

import Foundation

let ChatSessionControllerReceiveNotification: String = "inc.stamp.chat.notification.receive"

class ChatSessionController {
    
    var delegate: ChatSessionControllerDelegate?

    init () {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatSessionController.receiveContent(_:)), name: ChatSessionControllerReceiveNotification, object: nil)
    }
    
    func sendContent(transcript: Transcript) {
        guard let text = transcript.text else {
            return
        }
        
        let server = EchoServer()
        server.post(text)
    }
    
    func getConents() {
        // TODO
    }
    
    @objc func receiveContent(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        
        let text = userInfo["text"] as! String
        let from = userInfo["from"] as! String
        let transcript = Transcript()
        transcript.contentType = ContentType.Text.rawValue
        transcript.from = from
        transcript.text = text
        self.delegate?.controller(self, didReceiveContent: transcript)
    }
    
}

protocol ChatSessionControllerDelegate {
    func controller(controller: ChatSessionController, didReceiveContent transcript: Transcript)
}