//
//  ChatViewController.swift
//  ChatUI
//
//  Created by 1amageek on 2016/04/09.
//  Copyright © 2016年 Stamp inc. All rights reserved.
//

import UIKit
import RealmSwift

class ChatViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextViewDelegate {
    
    private(set) lazy var collectionView: UICollectionView = {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.scrollDirection = UICollectionViewScrollDirection.Vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.alwaysBounceVertical = true
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
    }
    
    private(set) lazy var sendBarButtonItem: UIBarButtonItem = {
        var sendBarButtonItem: UIBarButtonItem = UIBarButtonItem(title: "Send", style: .Plain, target: self, action: #selector(ChatViewController.tappedSendButton(_:)))
        sendBarButtonItem.enabled = false
        return sendBarButtonItem
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        realm = try! Realm()
        self.notificationToken = realm.addNotificationBlock({ (notification, realm) in
            self.collectionView.reloadData()
        })
        transcripts = realm.objects(Transcript).sorted("createdAt")
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
        switch transcript.contentType {
        case ContentType.Text.rawValue:
            let cell: ChatTextViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("ChatTextViewCell", forIndexPath: indexPath) as! ChatTextViewCell
            cell.message = transcript.text
            return cell
        default:
            let cell: ChatViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("ChatViewCell", forIndexPath: indexPath) as! ChatViewCell
            return cell
        }
    }
    
    // MARK: - UICollectionViewDelegate
    
    
    // MARK: - UICollectionViewFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let transcript = transcripts[indexPath.item]
        switch transcript.contentType {
        case ContentType.Text.rawValue:
            let cell: ChatTextViewCell = ChatTextViewCell(frame: self.view.bounds)
            cell.message = transcript.text
            return cell.calculateSize()
        default:
            let cell: ChatViewCell = ChatViewCell(frame: self.view.bounds)
            return cell.calculateSize()
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 6
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsZero
    }
    
    // MARK: - Action
    
    func tappedSendButton(barButtonItem: UIBarButtonItem) {
        let text = inputToolbar.composeTextView.text
        if !text.isEmpty {
            let transcript = Transcript()
            transcript.from = "FROM"
            //transcript.to = ["TO"]
            transcript.contentType = ContentType.Text.rawValue
            transcript.text = text
            try! realm.write({
                realm.add(transcript)
            })
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
        
        // Animation
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(animationDuration!)
        UIView.setAnimationCurve(animationCurve!)
        self.inputToolbar.frame = CGRect(x: self.inputToolbar.bounds.origin.x, y: inputToolbarOriginY, width: self.inputToolbar.bounds.width, height: self.inputToolbar.bounds.height)
        let bottom: CGFloat = inputToolbar.bounds.height + keyboardHeight
        self.collectionView.contentInset = UIEdgeInsets(top: self.collectionView.contentInset.top, left: 0, bottom: bottom, right: 0)
        UIView.commitAnimations()
    }
    
    func layoutInputToolbar() {
        inputToolbar.setNeedsLayout()
        let inputToolbarOriginY = self.view.bounds.height - self.inputToolbar.bounds.height - keyboardHeight
        inputToolbar.frame = CGRect(x: self.inputToolbar.bounds.origin.x, y: inputToolbarOriginY, width: self.inputToolbar.bounds.width, height: self.inputToolbar.bounds.height)
    }
    
    // MARK: - Realm
    var notificationToken: NotificationToken?
    var realm: Realm!
    var transcripts: Results<Transcript>!
    
    
}
