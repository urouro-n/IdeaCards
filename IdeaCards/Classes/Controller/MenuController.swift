//
//  MenuController.swift
//  IdeaCards
//
//  Created by Kenta Nakai on 3/15/16.
//  Copyright © 2016 Nakai Kenta. All rights reserved.
//

import UIKit
import MessageUI

class MenuController: UITableViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet private weak var memoCountLabel: UILabel!
    @IBOutlet private weak var versionLabel: UILabel!
    
    private lazy var memoCount: Int = ICDaoMemo.defaultInstance().countMemos()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "メニュー"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "閉じる",
            style: .Plain,
            target: self,
            action: "onCloseItem:"
        )
    }
    
    func onCloseItem(item: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        
        if indexPath.section == 0 && indexPath.row == 0 {
            cell.detailTextLabel?.text = String(memoCount)
        } else if indexPath.section == 1 && indexPath.row == 1 {
            cell.detailTextLabel?.text = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as? String
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            navigationController?.pushViewController(MemoListController(), animated: true)
        } else if indexPath.section == 1 && indexPath.row == 0 {
            let controller = MFMailComposeViewController()
            controller.mailComposeDelegate = self
            controller.setToRecipients(["info@urouro.net"])
            controller.setSubject("アイデアカードへのフィードバック")
            presentViewController(controller, animated: true, completion: nil)
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
