//
//  TopController.swift
//  IdeaCards
//
//  Created by Kenta Nakai on 2/20/16.
//  Copyright © 2016 UROURO. All rights reserved.
//

import UIKit
import iCarousel

class TopController: UIViewController, iCarouselDataSource, iCarouselDelegate, MemoInputControllerDelegate, MemoListControllerDelegate {
    
    @IBOutlet private weak var leftCarousel: iCarousel!
    @IBOutlet private weak var rightCarousel: iCarousel!
    @IBOutlet private weak var crossButton: UIButton!
    
    var leftData: [String] = []
    var rightData: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.whiteColor()
        
        leftCarousel.delegate = self
        leftCarousel.dataSource = self
        leftCarousel.type = .Linear
        leftCarousel.vertical = true
        
        rightCarousel.delegate = self
        rightCarousel.dataSource = self
        rightCarousel.type = .Linear
        rightCarousel.vertical = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "itemAdded:",
            name: ICItemManagerDidAddItem,
            object: nil
        )
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "itemRemoved:",
            name: ICItemManagerDidRemoveItem,
            object: nil
        )
        
        reloadData()
    }


    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: ICItemManagerDidAddItem,
            object: nil
        )
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: ICItemManagerDidRemoveItem,
            object: nil
        )
        
        super.viewWillDisappear(animated)
    }
    
    
    // MARK: - Action
    
    @IBAction func onCrossButton(sender: AnyObject) {
        let controller = MemoInputController()
        controller.delegate = self
        controller.leftItem = itemCurrentIndex(leftCarousel)
        controller.rightItem = itemCurrentIndex(rightCarousel)
        
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .FormSheet
        
        presentViewController(nav, animated: true, completion: nil)
    }


    // MARK: - Notification

    func itemAdded(notification: NSNotification) {
        reloadData()
    }
    
    func itemRemoved(notification: NSNotification) {
        reloadData()
    }
    
    
    // MARK: - iCarousel DataSource
    
    func numberOfItemsInCarousel(carousel: iCarousel) -> Int {
        if carousel == leftCarousel {
            return leftData.count
        } else {
            return rightData.count
        }
    }
    
    func carousel(carousel: iCarousel, viewForItemAtIndex index: Int, reusingView: UIView?) -> UIView {
        let label: UILabel
        let viewFrame = CGRectMake(
            0,
            0,
            view.frame.size.width/2,
            view.frame.size.width/2
        )
        let labelSize = CGSizeMake(
            viewFrame.size.width-20.0,
            viewFrame.size.height-20.0
        )
        var cellView: UIView? = reusingView
        
        if let cellView = cellView {
            label = cellView.viewWithTag(1) as! UILabel
        } else {
            cellView = UIImageView(frame: viewFrame)
            cellView!.contentMode = .Center
            cellView!.backgroundColor = UIColor.whiteColor()
            
            label = UILabel(frame: CGRectMake(0, 0, labelSize.width, labelSize.height))
            label.backgroundColor = UIColor.clearColor()
            label.textAlignment = .Center
            label.font = label.font.fontWithSize(25.0)
            label.tag = 1
            label.numberOfLines = 0
            
            cellView!.addSubview(label)
        }
        
        if carousel == leftCarousel {
            label.text = leftData[index]
            label.sizeThatFits(labelSize)
            label.center = CGPointMake(
                cellView!.frame.size.width/2 - 5.0,
                cellView!.frame.size.height/2
            )
        } else {
            label.text = rightData[index]
            label.sizeThatFits(labelSize)
            label.center = CGPointMake(
                cellView!.frame.size.width/2 + 5.0,
                cellView!.frame.size.height/2
            )
        }
        
        return cellView!
    }
    
    func carousel(carousel: iCarousel, valueForOption option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        switch option {
        case .Wrap:
            return 1.0
        default:
            return value
        }
    }
    
    
    // MARK: - MemoInputControllerDelegate
    
    func memoInputControllerDidFinish(controller: MemoInputController!) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: - MemoListControllerDelegate
    
    func memoListControllerDidFinish(controller: MemoListController!) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: - Public
    
    func reloadData() {
        let leftItems = ICItemManager.sharedManager().leftItems() as! [String]
        let rightItems = ICItemManager.sharedManager().rightItems() as! [String]
        var tempLeftArray: [String] = []
        var tempRightArray: [String] = []
        
        for _ in 0..<10 {
            tempLeftArray.appendContentsOf(leftItems)
            tempRightArray.appendContentsOf(rightItems)
        }
        
        leftData = tempLeftArray
        rightData = tempRightArray
        
        leftCarousel.reloadData()
        rightCarousel.reloadData()
    }
    
    
    // MARK: - Private
    
    private func itemCurrentIndex(carousel: iCarousel) -> String? {
        let label: UILabel = carousel.currentItemView!.viewWithTag(1) as! UILabel
        return label.text
    }
    
}
