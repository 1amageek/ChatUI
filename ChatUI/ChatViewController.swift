//
//  ChatViewController.swift
//  ChatUI
//
//  Created by 1amageek on 2016/04/09.
//  Copyright © 2016年 Stamp inc. All rights reserved.
//

import UIKit
import RealmSwift

class ChatViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextViewDelegate, ChatSessionControllerDelegate {
    
    var sessionController: ChatSessionController? {
        didSet {
            sessionController?.delegate = self
        }
    }
    
    private(set) lazy var collectionView: ChatView = {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.scrollDirection = UICollectionViewScrollDirection.Vertical
        let collectionView = ChatView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.alwaysBounceVertical = true
        collectionView.allowsSelection = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.keyboardDismissMode = .OnDrag
        
        // Cell type
        collectionView.registerClass(ChatViewCell.self, forCellWithReuseIdentifier: "ChatViewCell")
        collectionView.registerClass(ChatTextViewCell.self, forCellWithReuseIdentifier: "ChatTextViewCell")
        
        var top: CGFloat = 0
        if !self.automaticallyAdjustsScrollViewInsets {
            top += UIApplication.sharedApplication().statusBarFrame.height
            if let navigationController = self.navigationController {
                top += navigationController.navigationBar.bounds.height
            }
        }
        collectionView.contentInset = UIEdgeInsets(top: top, left: 0, bottom: 0, right: 0)
        return collectionView
    }()
    
    private(set) lazy var inputToolbar: ChatToolbar = {
        var inputToolbar: ChatToolbar = ChatToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 0))
        inputToolbar.composeTextView.delegate = self
        inputToolbar.sizeToFit()
        return inputToolbar
    }()
    
    override func loadView() {
        super.loadView()
        self.view.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.collectionView)
        self.view.addSubview(self.inputToolbar)
//        self.collectionView.addGestureRecognizer(self.panGestureRecognizer)
//        self.panGestureRecognizer.requireGestureRecognizerToFail(self.collectionView.panGestureRecognizer)
    }
    
    private(set) lazy var sendBarButtonItem: UIBarButtonItem = {
        var sendBarButtonItem: UIBarButtonItem = UIBarButtonItem(title: "Send", style: .Plain, target: self, action: #selector(ChatViewController.tappedSendButton(_:)))
        sendBarButtonItem.enabled = false
        return sendBarButtonItem
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.inputToolbar.setItems([self.sendBarButtonItem], animated: false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.collectionView.frame = self.view.bounds
        layoutInputToolbar()
        let bottom: CGFloat = inputToolbar.bounds.height + keyboardHeight
        collectionView.contentInset = UIEdgeInsets(top: collectionView.contentInset.top, left: 0, bottom: bottom, right: 0)
        scrollToBottom(false)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return transcripts.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let transcript = transcripts[indexPath.item]
        let direction: Direction = directionForTranscript(transcript)
        switch transcript.contentType {
        case ContentType.Text.rawValue:
            let cell: ChatTextViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("ChatTextViewCell", forIndexPath: indexPath) as! ChatTextViewCell
            cell.message = transcript.text
            cell.direction = direction
            cell.balloonViewColor = direction == .Right ? UIColor(red: 71/255, green: 139/255, blue: 242/255, alpha: 1) : UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
            cell.messageLabelTextColor = direction == .Right ? UIColor.whiteColor() : UIColor.blackColor()
            
            return cell
        default:
            let cell: ChatViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("ChatViewCell", forIndexPath: indexPath) as! ChatViewCell
            return cell
        }
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    
    // MARK: - UICollectionViewFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let transcript = transcripts[indexPath.item]
        let direction: Direction = directionForTranscript(transcript)
        switch transcript.contentType {
        case ContentType.Text.rawValue:
            let cell: ChatTextViewCell = ChatTextViewCell(frame: self.view.bounds)
            cell.message = transcript.text
            cell.direction = direction
            return cell.calculateSize()
        default:
            let cell: ChatViewCell = ChatViewCell(frame: self.view.bounds)
            return cell.calculateSize()
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 3
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0)
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        inputToolbar.composeTextView.resignFirstResponder()
    }
    
    // MARK: - Action
    
    func tappedSendButton(barButtonItem: UIBarButtonItem) {
        let text = inputToolbar.composeTextView.text
        inputToolbar.composeTextView.text = ""
        barButtonItem.enabled = false
        if !text.isEmpty {
            let transcript = Transcript()
            transcript.from = "FROM"
            //transcript.to = ["TO"]
            transcript.contentType = ContentType.Text.rawValue
            transcript.text = text
            try! realm.write({
                realm.add(transcript)
            })
            sessionController?.sendContent(transcript)
        }
    }
    
    // MARK: - UITextViewDelegate
    
    func textViewDidChange(textView: UITextView) {
        layoutInputToolbar()
        sendBarButtonItem.enabled = !textView.text.isEmpty
    }
    
    func textViewDidChangeSelection(textView: UITextView) {
        textView.scrollRangeToVisible(textView.selectedRange)
    }
    
    // MARK: - KeyboardNotification
    
    func keyboardWillShow(notification: NSNotification) {
        moveToolbar(true, notification: notification)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        moveToolbar(false, notification: notification)
    }
    
    var keyboardHeight: CGFloat = 0
    func moveToolbar(up: Bool, notification: NSNotification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        var animationDuration: NSTimeInterval?
        var animationCurve: UIViewAnimationCurve?
        if let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            keyboardHeight = up ? keyboardFrame.CGRectValue().height : 0
        }
        if let _animationCurve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber {
            animationCurve = UIViewAnimationCurve(rawValue: _animationCurve.integerValue)!
        }
        if let _animatinDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber {
            animationDuration = _animatinDuration.doubleValue
        }
        let inputToolbarOriginY = self.view.bounds.height - self.inputToolbar.bounds.height - keyboardHeight
        let bottom: CGFloat = inputToolbar.bounds.height + keyboardHeight
        let contentOffset = CGPoint(x: 0, y: self.collectionView.contentSize.height - self.collectionView.bounds.height + bottom)
    
        // Animation
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(animationDuration!)
        UIView.setAnimationCurve(animationCurve!)
        self.inputToolbar.frame = CGRect(x: self.inputToolbar.bounds.origin.x, y: inputToolbarOriginY, width: self.inputToolbar.bounds.width, height: self.inputToolbar.bounds.height)
        self.collectionView.contentInset = UIEdgeInsets(top: self.collectionView.contentInset.top, left: 0, bottom: bottom, right: 0)
        
        // TODO bug http://stackoverflow.com/questions/22389904/animating-uicollectionview-contentoffset-does-not-display-non-visible-cells
        if up {
            if shouldScrollToBottom() {
                self.collectionView.setContentOffset(contentOffset, animated: false)
            }
        }
        UIView.commitAnimations()
    }
    
    // MARK: - CollectionView offset control
    
    func shouldScrollToBottom() -> Bool {
        if collectionView.bounds.height > collectionView.contentSize.height {
            return false
        }
        let section: Int = self.numberOfSectionsInCollectionView(self.collectionView) - 1
        if section < 0 {
            return false
        }
        let item: Int = self.collectionView(self.collectionView, numberOfItemsInSection: section) - 1
        if item < 0 {
            return false
        }
        let indexPath: NSIndexPath = NSIndexPath(forItem: item, inSection: section)
        if let layoutAttributes: UICollectionViewLayoutAttributes = self.collectionView.collectionViewLayout.layoutAttributesForItemAtIndexPath(indexPath) {
            let visibleRect: CGRect = CGRect(x: 0, y: self.collectionView.contentOffset.y, width: collectionView.bounds.width, height: collectionView.bounds.height)
            if CGRectIntersectsRect(layoutAttributes.frame, visibleRect) {
                return true
            }
        }
        return false
    }
    
    func directionForTranscript(transcript: Transcript) -> Direction {
        if transcript.from == "FROM" {
            return .Right
        } else {
            return .Left
        }
    }
    
    func scrollToBottom(animated: Bool) {
        let bottom: CGFloat = inputToolbar.bounds.height + keyboardHeight
        let contentOffset = CGPoint(x: 0, y: self.collectionView.contentSize.height - self.collectionView.bounds.height + bottom)
        self.collectionView.setContentOffset(contentOffset, animated: animated)
    }
    
    func layoutInputToolbar() {
        inputToolbar.setNeedsLayout()
        let inputToolbarOriginY = self.view.bounds.height - self.inputToolbar.bounds.height - keyboardHeight
        inputToolbar.frame = CGRect(x: self.inputToolbar.bounds.origin.x, y: inputToolbarOriginY, width: self.inputToolbar.bounds.width, height: self.inputToolbar.bounds.height)
    }
    
    // MARK: - Realm
    
    private(set) var notificationToken: NotificationToken?
    
    private(set) lazy var realm: Realm = {
        var realm = try! Realm()
        self.notificationToken = realm.addNotificationBlock({ (notification, realm) in
            let section: Int = self.numberOfSectionsInCollectionView(self.collectionView) - 1
            let item: Int = self.collectionView(self.collectionView, numberOfItemsInSection: section) - 1
            let indexPath: NSIndexPath = NSIndexPath(forItem: item, inSection: section)
            self.collectionView.performBatchUpdates({
                self.collectionView.insertItemsAtIndexPaths([indexPath])
                }, completion: nil)
            
            let transcript = self.transcripts[indexPath.item]
            let layoutAttributes: UICollectionViewLayoutAttributes = self.collectionView.layoutAttributesForItemAtIndexPath(indexPath)!
            let contentInset: UIEdgeInsets = self.collectionView(self.collectionView, layout: self.collectionView.collectionViewLayout, insetForSectionAtIndex: section)
            let bottom: CGFloat = self.inputToolbar.bounds.height + self.keyboardHeight
            let contentOffset = CGPoint(x: 0, y: CGRectGetMaxY(layoutAttributes.frame) + contentInset.bottom - self.collectionView.bounds.height + bottom)
            
            // DirectionがRightの場合必ずスクロールする
            if self.directionForTranscript(transcript) == .Right {
                UIView.animateWithDuration(0.2) {
                    self.collectionView.contentOffset = contentOffset
                }
            }
            // DirectionがLeftの場合必ず領域内にある場合のみスクロールする
            else {
                if self.shouldScrollToBottom() {
                    UIView.animateWithDuration(0.2) {
                        self.collectionView.contentOffset = contentOffset
                    }
                }
            }
        })
        return realm
    }()
    
    private(set) lazy var transcripts: Results<Transcript> = {
        var transcripts = self.realm.objects(Transcript).sorted("createdAt")
        return transcripts
    }()
    
    // MARK: - Gesture control
    
    private(set) lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        var panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ChatViewController.panGesture(_:)))
        return panGestureRecognizer
    }()
    
    func panGesture(recognizer: UIPanGestureRecognizer) {
        print(recognizer)
    }
    
    // MARK: - ChatSessionControllerDelegate
    
    func controller(controller: ChatSessionController, didReceiveContent transcript: Transcript) {
        try! realm.write({
            realm.add(transcript)
        })
    }
    
    // MARK: -
    
    deinit {
        if let notificationToken = self.notificationToken {
            self.realm.removeNotification(notificationToken)
        }
    }
    
}
