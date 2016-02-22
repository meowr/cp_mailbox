//
//  MailboxViewController.swift
//  mailbox
//
//  Created by Tina Chen on 2/19/16.
//  Copyright © 2016 tinachen. All rights reserved.
//

import UIKit

class MailboxViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var listOptionsView: UIView!
    @IBOutlet weak var laterOptionsView: UIView!
    @IBOutlet weak var messageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var laterView: UIView!
    @IBOutlet weak var laterIconView: UIImageView!
    @IBOutlet weak var archiveIconView: UIImageView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var feedView: UIImageView!
    @IBOutlet var segmentedControl: [UISegmentedControl]!
    @IBOutlet weak var inboxView: UIView!
    
    var messageOriginalCenter: CGPoint!
    var laterIconOriginalCenter: CGPoint!
    var archiveIconOriginalCenter: CGPoint!
    var mainViewOriginalCenter: CGPoint!
    var feedViewOriginalCenter: CGPoint!
    var inboxOriginalCenter: CGPoint!
    var firstThreshold: CGFloat!
    var secondThreshold: CGFloat!
    var fullThreshold: CGFloat!
    var menuOpen: CGFloat!
    var isMenuOpen: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.contentSize = CGSize(width: 320, height: 1288)
        firstThreshold = 60
        secondThreshold = 260
        fullThreshold = 160
        menuOpen = 460
        laterIconView.alpha = 0
        laterOptionsView.alpha = 0
        listOptionsView.alpha = 0
        messageOriginalCenter = messageView.center
        laterIconOriginalCenter = laterIconView.center
        archiveIconOriginalCenter = archiveIconView.center
        mainViewOriginalCenter = mainView.center
        feedViewOriginalCenter = feedView.center
        inboxOriginalCenter = inboxView.center
        isMenuOpen = false

        var edgeGesture = UIScreenEdgePanGestureRecognizer(target: self, action: "onEdgePan:")
        var mainPanGesture = UIPanGestureRecognizer(target: self, action: "onMainViewPan:")
        mainView.userInteractionEnabled = true
        edgeGesture.edges = UIRectEdge.Left
        mainView.addGestureRecognizer(edgeGesture)
        mainView.addGestureRecognizer(mainPanGesture)
        mainPanGesture.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.becomeFirstResponder()
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake {
            undo()
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func didPanMessage(sender: UIPanGestureRecognizer) {
        let translation = sender.translationInView(view)
        if sender.state == UIGestureRecognizerState.Began {
            laterIconView.center = laterIconOriginalCenter
            archiveIconView.center = archiveIconOriginalCenter
        } else if sender.state == UIGestureRecognizerState.Changed {
            messageView.center = CGPoint(x:messageOriginalCenter.x + translation.x, y:messageOriginalCenter.y)
            laterIconView.alpha = convertValue(translation.x, r1Min:0, r1Max:-firstThreshold, r2Min: 0, r2Max: 1)
            archiveIconView.alpha = convertValue(translation.x, r1Min:0, r1Max:firstThreshold, r2Min: 0, r2Max: 1)
            laterView.backgroundColor = UIColorFromRGB(0xCCCCCC)
            
            if translation.x < -secondThreshold {
                laterView.backgroundColor = UIColorFromRGB(0xD9A771)
                laterIconView.image = UIImage (named: "list_icon")
                laterIconView.center.x = laterIconOriginalCenter.x + translation.x + firstThreshold
            } else if translation.x < -firstThreshold {
                laterView.backgroundColor = UIColorFromRGB(0xFCD40D)
                laterIconView.center.x = laterIconOriginalCenter.x + translation.x + firstThreshold
                laterIconView.image = UIImage (named: "later_icon")
            } else if translation.x > secondThreshold {
                laterView.backgroundColor = UIColorFromRGB(0xED5329)
                archiveIconView.center.x = archiveIconOriginalCenter.x + translation.x - firstThreshold
                archiveIconView.image = UIImage (named: "delete_icon")
            } else if translation.x > firstThreshold {
                laterView.backgroundColor = UIColorFromRGB(0x6CDB5B)
                archiveIconView.center.x = archiveIconOriginalCenter.x + translation.x - firstThreshold
                archiveIconView.image = UIImage (named: "archive_icon")
            }
        } else if sender.state == UIGestureRecognizerState.Ended {
            if translation.x < -secondThreshold {
                showOptions(listOptionsView)
            } else if translation.x < -firstThreshold {
                showOptions(laterOptionsView)
            } else if translation.x > firstThreshold {
                removeMessage()
            } else {
                UIView.animateWithDuration(0.4, delay:0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: [] ,animations: { () -> Void in
                    self.messageView.center = self.messageOriginalCenter
                    }, completion: nil)
            }
        }
    }
    
    @IBAction func onEdgePan(sender: UIScreenEdgePanGestureRecognizer) {
        let translation = sender.translationInView(view)
        let velocity = sender.velocityInView(view)
        if sender.state == UIGestureRecognizerState.Began {

        } else if sender.state == UIGestureRecognizerState.Changed {
            mainView.center.x = mainViewOriginalCenter.x + translation.x

        } else if sender.state == UIGestureRecognizerState.Ended {
            if velocity.x >= 0 {
                UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: [] ,animations: { () -> Void in
                    self.mainView.center.x = self.menuOpen
                self.isMenuOpen = true
                    }, completion: nil)
            } else {
                UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: [] ,animations: { () -> Void in
                    self.mainView.center.x = self.mainViewOriginalCenter.x
                    }, completion: nil)
                isMenuOpen = false
            }
        }
    }
    
    func onMainViewPan(sender: UIPanGestureRecognizer) {
        let translation = sender.translationInView(view)
        let velocity = sender.velocityInView(view)
        if isMenuOpen! {
            if sender.state == UIGestureRecognizerState.Changed {
                mainView.center.x = menuOpen + translation.x
            } else if sender.state == UIGestureRecognizerState.Ended {
                if velocity.x >= 0 {
                    UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: [] ,animations: { () -> Void in
                        self.mainView.center.x = self.menuOpen
                        }, completion: nil)
                } else {
                    UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: [] ,animations: { () -> Void in
                        self.mainView.center.x = self.mainViewOriginalCenter.x
                        }, completion: nil)
                    isMenuOpen = false
                }
            }
        }

    }
    @IBAction func onLaterOptionButton(sender: AnyObject) {
        laterOptionsView.alpha = 0
        hideMessage()
    }
    
    @IBAction func onListOptionButton(sender: AnyObject) {
        listOptionsView.alpha = 0
        hideMessage()
    }
    
    func hideMessage() {
        UIView.animateWithDuration(0.4, delay: 0, options: [] ,animations: { () -> Void in
            self.feedView.center.y = self.feedViewOriginalCenter.y - 86
            }, completion: nil)
    }
    
    func showOptions(optionView: UIView) {
        UIView.animateWithDuration(0.2, delay: 0, options: [] ,animations: { () -> Void in
            self.messageView.center.x = -self.fullThreshold
            self.laterIconView.alpha = 0
            }, completion: nil)
        UIView.animateWithDuration(0.2, delay: 0.2, options: [] ,animations: { () -> Void in
            optionView.alpha = 1
            }, completion: nil)
    }
    
    func removeMessage() {
        UIView.animateWithDuration(0.2, delay: 0, options: [] ,animations: { () -> Void in
            self.archiveIconView.alpha = 0
            self.messageView.center.x = self.fullThreshold * 3
            }, completion: { _ in
                 self.hideMessage()
            })
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer!, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer!) -> Bool {
        return true
    }
    
    func undo() {
        self.messageView.center = self.messageOriginalCenter
        UIView.animateWithDuration(0.6, delay: 0.4, options: [] ,animations: { () -> Void in
            self.feedView.center.y = self.feedViewOriginalCenter.y
            }, completion: nil)
    }

    @IBAction func onSegmentedControl(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
            case 0:
                UIView.animateWithDuration(0.4, delay:0, options: [] ,animations: { () -> Void in
                    self.inboxView.center.x = self.inboxOriginalCenter.x + 320
                    }, completion: nil);

            case 1:
                UIView.animateWithDuration(0.4, delay:0, options: [] ,animations: { () -> Void in
                    self.inboxView.center.x = self.inboxOriginalCenter.x
                    }, completion: nil);
            case 2:
                UIView.animateWithDuration(0.4, delay:0, options: [] ,animations: { () -> Void in
                    self.inboxView.center.x = self.inboxOriginalCenter.x - 320
                    }, completion: nil);
            default: 
                break; 
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
