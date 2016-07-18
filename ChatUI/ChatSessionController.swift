//
//  ChatSessionController.swift
//  ChatUI
//
//  Created by 1amageek on 2016/04/12.
//  Copyright © 2016年 Stamp inc. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class ChatSessionController {

    let databaseRef: FIRDatabaseReference = FIRDatabase.database().reference()
    var roomRef: FIRDatabaseReference!
    var uuid: String!
    weak var delegate: ChatSessionControllerDelegate?

    init () {
        
        if NSUserDefaults.standardUserDefaults().stringForKey("UUID") == nil {
            let uuid: String = NSUUID().UUIDString
            NSUserDefaults.standardUserDefaults().setObject(uuid, forKey: "UUID")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
        self.uuid = NSUserDefaults.standardUserDefaults().stringForKey("UUID")!
        self.roomRef = databaseRef.child("room/messages")
        
        self.roomRef.observeEventType(.Value, withBlock: { (snapshot) in
            print(snapshot)
            }) { (error) in
                
        }
        
        self.roomRef.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            guard let id: String = snapshot.key else { return }
            guard let value: AnyObject = snapshot.value else { return }
            guard let from: String = value.valueForKey("from") as? String else { return }
            if from == self.uuid { return }
            
            let createdAt: NSTimeInterval = value.valueForKey("createdAt") as! NSTimeInterval
            let text: String = value.valueForKey("text") as! String
            let transcript = Transcript()
            transcript.id = id
            transcript.contentType = ContentType.Text.rawValue
            transcript.createdAt = NSDate(timeIntervalSince1970: createdAt)
            transcript.from = from
            transcript.text = text
            self.delegate?.controller(self, didReceiveContent: transcript)
            }) { (error) in
                
        }
    }
    
    func sendContent(transcript: Transcript) {
        guard let text = transcript.text else {
            return
        }
        
        let message: [String: AnyObject] = [
            "createdAt": transcript.createdAt.timeIntervalSince1970,
            "text": text,
            "from": self.uuid,
            "array": ["111", "2222"],
            "nest": [
                "sssss": 2,
                "wwwww": 3
            ]
        ]
        roomRef.childByAutoId().setValue(message)
    }
    
}

protocol ChatSessionControllerDelegate: class {
    func controller(controller: ChatSessionController, didReceiveContent transcript: Transcript)
}