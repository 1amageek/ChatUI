//
//  Transcript.swift
//  ChatUI
//
//  Created by 1amageek on 2016/04/09.
//  Copyright © 2016年 Stamp inc. All rights reserved.
//

import Realm
import RealmSwift

enum ContentType: Int {
    case Text = 0
    case Image
    case Video
    case Audio
    case Location
    case Sticker
    
}

class Transcript: Object {
    
    dynamic var id: String!
    dynamic var createdAt: NSDate = NSDate()
    dynamic var contentType: Int = 0
    dynamic var from: String!
    //dynamic var to: [String]!
    
    dynamic var text: String?
    //dynamic var location: [Double]?

    override static func primaryKey() -> String? {
        return "id"
    }
    
}
