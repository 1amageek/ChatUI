//
//  ChatViewCell.swift
//  ChatUI
//
//  Created by 1amageek on 2016/04/09.
//  Copyright © 2016年 Stamp inc. All rights reserved.
//

import UIKit

enum Direction: Int {
    case Center
    case Left
    case Right
}


class ChatViewCell: UICollectionViewCell {
    
    let contentInset: UIEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    let balloonWidthMax: CGFloat = 240
    var balloonContentInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    let thumbnailView: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
    
    var direction: Direction!
    
    var balloonViewColor: UIColor = UIColor(red: 0.0, green: 0.1, blue: 1, alpha: 1) {
        didSet {
            balloonView.backgroundColor = balloonViewColor
            balloonView.setNeedsDisplay()
        }
    }
    
    var dateLabelHidden: Bool = true {
        didSet {
            dateLabel.hidden = dateLabelHidden
            self.contentView.setNeedsLayout()
        }
    }

    private(set) lazy var balloonView: UIView = {
        var balloonView = UIView(frame: .zero)
        balloonView.backgroundColor = self.balloonViewColor
        balloonView.layer.cornerRadius = 14
        return balloonView
    }()
    
    private(set) lazy var dateLabel: UILabel = {
        var dateLabel = UILabel(frame: .zero)
        dateLabel.numberOfLines = 0
        return dateLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        direction = .Left
        dateLabel.hidden = dateLabelHidden
        self.contentView.addSubview(thumbnailView)
        self.contentView.addSubview(balloonView)
        self.contentView.addSubview(dateLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        calculateSize()
    }
    
    func calculateSize() -> CGSize {
        return self.bounds.size
    }
    
}

class ChatTextViewCell: ChatViewCell {
    
    var message: String? {
        didSet {
            self.messageLabel.text = message
            self.setNeedsLayout()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        balloonContentInsets = UIEdgeInsets(top: 6, left: 8, bottom: 6, right: 8)
        balloonView.addSubview(messageLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var messageLabelTextColor: UIColor = UIColor.whiteColor() {
        didSet {
            self.messageLabel.textColor = messageLabelTextColor
            self.messageLabel.setNeedsDisplay()
        }
    }
    
    private(set) lazy var messageLabel: UILabel = {
        var messageLabel = UILabel(frame: .zero)
        messageLabel.numberOfLines = 0
        messageLabel.textColor = self.messageLabelTextColor
        return messageLabel
    }()
    
    override func calculateSize() -> CGSize {
        switch direction! {
        case .Center:
            let constraintSize: CGSize = CGSize(width: balloonWidthMax - balloonContentInsets.left - balloonContentInsets.right, height: CGFloat.max)
            let messageLabelSize: CGSize = messageLabel.sizeThatFits(constraintSize)
            messageLabel.frame = CGRect(x: balloonContentInsets.left, y: balloonContentInsets.top, width: messageLabelSize.width, height: messageLabelSize.height)
            balloonView.frame = CGRect(x: contentInset.left, y: contentInset.top, width: balloonContentInsets.left + messageLabelSize.width + balloonContentInsets.right, height: balloonContentInsets.top + messageLabelSize.height + balloonContentInsets.bottom)
            return CGSize(width: self.bounds.width, height: balloonView.bounds.height)
        case .Left:
            let constraintSize: CGSize = CGSize(width: balloonWidthMax - balloonContentInsets.left - balloonContentInsets.right, height: CGFloat.max)
            let messageLabelSize: CGSize = messageLabel.sizeThatFits(constraintSize)
            messageLabel.frame = CGRect(x: balloonContentInsets.left, y: balloonContentInsets.top, width: messageLabelSize.width, height: messageLabelSize.height)
            balloonView.frame = CGRect(x: contentInset.left, y: contentInset.top, width: balloonContentInsets.left + messageLabelSize.width + balloonContentInsets.right, height: balloonContentInsets.top + messageLabelSize.height + balloonContentInsets.bottom)
            return CGSize(width: self.bounds.width, height: balloonView.bounds.height)
        case .Right:
            let constraintSize: CGSize = CGSize(width: balloonWidthMax - balloonContentInsets.left - balloonContentInsets.right, height: CGFloat.max)
            let messageLabelSize: CGSize = messageLabel.sizeThatFits(constraintSize)
            messageLabel.frame = CGRect(x: balloonContentInsets.left, y: balloonContentInsets.top, width: messageLabelSize.width, height: messageLabelSize.height)
            let balloonViewSize = CGSize(width: balloonContentInsets.left + messageLabelSize.width + balloonContentInsets.right, height: balloonContentInsets.top + messageLabelSize.height + balloonContentInsets.bottom)
            balloonView.frame = CGRect(x: self.bounds.width - contentInset.right - balloonViewSize.width, y: contentInset.top, width: balloonViewSize.width, height: balloonViewSize.height)
            return CGSize(width: self.bounds.width, height: balloonView.bounds.height)
        }
    }
}
