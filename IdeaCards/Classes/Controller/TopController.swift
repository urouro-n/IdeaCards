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
    
    @IBOutlet fileprivate weak var leftCarousel: iCarousel!
    @IBOutlet fileprivate weak var rightCarousel: iCarousel!
    @IBOutlet fileprivate weak var crossButton: UIButton!
    
    var leftData: [String] = []
    var rightData: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        leftCarousel.delegate = self
        leftCarousel.dataSource = self
        leftCarousel.type = .linear
        leftCarousel.isVertical = true
        
        rightCarousel.delegate = self
        rightCarousel.dataSource = self
        rightCarousel.type = .linear
        rightCarousel.isVertical = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(TopController.itemAdded(_:)),
            name: NSNotification.Name(rawValue: ICItemManagerDidAddItem),
            object: nil
        )
        NotificationCenter.default.addObserver(self,
            selector: #selector(TopController.itemRemoved(_:)),
            name: NSNotification.Name(rawValue: ICItemManagerDidRemoveItem),
            object: nil
        )
        
        reloadData()
    }


    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self,
            name: NSNotification.Name(rawValue: ICItemManagerDidAddItem),
            object: nil
        )
        NotificationCenter.default.removeObserver(self,
            name: NSNotification.Name(rawValue: ICItemManagerDidRemoveItem),
            object: nil
        )
        
        super.viewWillDisappear(animated)
    }
    
    
    // MARK: - Action
    
    @IBAction func onCrossButton(_ sender: AnyObject) {
        if leftData.count == 0 && rightData.count == 0 {
            let alert = UIAlertController(
                title: "組み合わせるワードがありません",
                message: "画面を左右にスワイプしてワードを登録しましょう！",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        } else if leftData.count == 0 {
            let alert = UIAlertController(
                title: "片方のワードがありません",
                message: "画面を右にスワイプしてワードを登録しましょう！",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        } else if rightData.count == 0 {
            let alert = UIAlertController(
                title: "片方のワードがありません",
                message: "画面を左にスワイプしてワードを登録しましょう！",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        
        let controller = MemoInputController()
        controller.delegate = self
        controller.leftItem = itemCurrentIndex(leftCarousel)
        controller.rightItem = itemCurrentIndex(rightCarousel)
        
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .formSheet
        
        present(nav, animated: true, completion: nil)
    }


    // MARK: - Notification

    func itemAdded(_ notification: Notification) {
        reloadData()
    }
    
    func itemRemoved(_ notification: Notification) {
        reloadData()
    }
    
    
    // MARK: - iCarousel DataSource
    
    func numberOfItems(in carousel: iCarousel) -> Int {
        if carousel == leftCarousel {
            return leftData.count
        } else {
            return rightData.count
        }
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing reusingView: UIView?) -> UIView {
        let label: UILabel
        let viewFrame = CGRect(
            x: 0,
            y: 0,
            width: view.frame.size.width/2,
            height: view.frame.size.width/2
        )
        let labelSize = CGSize(
            width: viewFrame.size.width-20.0,
            height: viewFrame.size.height-20.0
        )
        var cellView: UIView? = reusingView
        
        if let cellView = cellView {
            label = cellView.viewWithTag(1) as! UILabel
        } else {
            cellView = UIImageView(frame: viewFrame)
            cellView!.contentMode = .center
            cellView!.backgroundColor = UIColor.white
            
            label = UILabel(frame: CGRect(x: 0, y: 0, width: labelSize.width, height: labelSize.height))
            label.backgroundColor = UIColor.clear
            label.textAlignment = .center
            label.font = label.font.withSize(25.0)
            label.tag = 1
            label.numberOfLines = 0
            
            cellView!.addSubview(label)
        }
        
        if carousel == leftCarousel {
            label.text = leftData[index]
            label.sizeThatFits(labelSize)
            label.center = CGPoint(
                x: cellView!.frame.size.width/2 - 5.0,
                y: cellView!.frame.size.height/2
            )
        } else {
            label.text = rightData[index]
            label.sizeThatFits(labelSize)
            label.center = CGPoint(
                x: cellView!.frame.size.width/2 + 5.0,
                y: cellView!.frame.size.height/2
            )
        }
        
        return cellView!
    }
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        switch option {
        case .wrap:
            return 1.0
        default:
            return value
        }
    }
    
    
    // MARK: - MemoInputControllerDelegate
    
    func memoInputControllerDidFinish(_ controller: MemoInputController!) {
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - MemoListControllerDelegate
    
    func memoListControllerDidFinish(_ controller: MemoListController!) {
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Public
    
    func reloadData() {
        let leftItems = ICItemManager.shared().leftItems() as! [String]
        let rightItems = ICItemManager.shared().rightItems() as! [String]
        var tempLeftArray: [String] = []
        var tempRightArray: [String] = []
        
        for _ in 0..<10 {
            tempLeftArray.append(contentsOf: leftItems)
            tempRightArray.append(contentsOf: rightItems)
        }
        
        leftData = tempLeftArray
        rightData = tempRightArray
        
        leftCarousel.reloadData()
        rightCarousel.reloadData()
    }
    
    
    // MARK: - Private
    
    fileprivate func itemCurrentIndex(_ carousel: iCarousel) -> String? {
        let label: UILabel = carousel.currentItemView!.viewWithTag(1) as! UILabel
        return label.text
    }
    
}
