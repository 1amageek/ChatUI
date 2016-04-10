//
//  ChatToolbar.swift
//  ChatUI
//
//  Created by 1amageek on 2016/04/09.
//  Copyright © 2016年 Stamp inc. All rights reserved.
//

import UIKit

class ChatToolbar: UIView {
    
    let composeTextViewLimitHeight: CGFloat = 100
    let composeTextViewInset: UIEdgeInsets = UIEdgeInsets(top: 4, left: 0, bottom: 0, right: 0)
    let composeTextViewContainerInset: UIEdgeInsets = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)

    private(set) lazy var composeTextView: UITextView = {
        var composeTextView = UITextView(frame: self.bounds)
        composeTextView.scrollEnabled = false
        composeTextView.text = ""
        composeTextView.font = UIFont(name: "HelveticaNeue", size: 15)
        composeTextView.textContainerInset = self.composeTextViewContainerInset
        composeTextView.backgroundColor = UIColor.whiteColor()
        composeTextView.sizeToFit()
        return composeTextView
    }()
    
    let toolbarHeight: CGFloat = 40
    
    private(set) lazy var toolbar: _Toolbar = {
        var toolbar = _Toolbar(frame: .zero)
        toolbar.sizeToFit()
        return toolbar
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.composeTextView)
        self.addSubview(self.toolbar)
        self.backgroundColor = UIColor.whiteColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setItems(items: [UIBarButtonItem]?, animated: Bool) {
        toolbar.setItems(items, animated: animated)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let constraintSize: CGSize = CGSize(width: self.bounds.width - composeTextViewInset.left - composeTextViewInset.right, height: CGFloat.max)
        var messageSize: CGSize = self.composeTextView.sizeThatFits(constraintSize)
        if composeTextViewLimitHeight < messageSize.height {
            messageSize.height = composeTextViewLimitHeight
            composeTextView.scrollEnabled = true
        } else {
            composeTextView.scrollEnabled = false
        }
        composeTextView.frame = CGRect(x: composeTextViewInset.left, y: composeTextViewInset.top, width: constraintSize.width, height: messageSize.height)
        toolbar.frame = CGRect(x: 0, y: CGRectGetMaxY(composeTextView.frame) + composeTextViewInset.bottom, width: self.bounds.width, height: toolbarHeight)
        self.bounds = CGRect(x: 0, y: 0, width: self.bounds.width, height: CGRectGetMaxY(toolbar.frame))
    }
    
    override func drawRect(rect: CGRect) {
        let line = UIBezierPath()
        line.moveToPoint(rect.origin)
        line.addLineToPoint(CGPoint(x: rect.width, y: rect.origin.y))
        UIColor.lightGrayColor().setStroke()
        line.lineWidth = 1
        line.stroke()
    }
    
}

class _Toolbar: UIToolbar {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        self.opaque = false
        self.translucent = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect) {
        // Require
    }
    
}

