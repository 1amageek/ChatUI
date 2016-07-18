//
//  EchoServer.swift
//  ChatUI
//
//  Created by 1amageek on 2016/04/12.
//  Copyright © 2016年 Stamp inc. All rights reserved.
//

import Foundation

let EchoServerReceiveNotification: String = "EchoServerReceiveNotification"

class EchoServer {
    
    func post(message: String) {
        
        if !message.isEmpty {
            let delay = 1.0 * Double(NSEC_PER_SEC)
            let time  = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(time, dispatch_get_main_queue(), {
                
                let transcript = [
                    "from": "OTHER",
                    "text": message
                ]
                NSNotificationCenter.defaultCenter().postNotificationName(EchoServerReceiveNotification, object: nil, userInfo: transcript)
                
            })
        }
            
    }
    
}