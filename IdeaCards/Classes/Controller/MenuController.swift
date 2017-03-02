//
//  MenuController.swift
//  IdeaCards
//
//  Created by Kenta Nakai on 3/15/16.
//  Copyright © 2016 UROURO. All rights reserved.
//

import UIKit
import MessageUI

class MenuController: UITableViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet fileprivate weak var memoCountLabel: UILabel!
    @IBOutlet fileprivate weak var versionLabel: UILabel!
    
    fileprivate lazy var memoCount: Int = ICDaoMemo.defaultInstance().countMemos()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "メニュー"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "閉じる",
            style: .plain,
            target: self,
            action: #selector(MenuController.onCloseItem(_:))
        )
    }
    
    func onCloseItem(_ item: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if indexPath.section == 0 && indexPath.row == 0 {
            cell.detailTextLabel?.text = String(memoCount)
        } else if indexPath.section == 1 && indexPath.row == 1 {
            cell.detailTextLabel?.text = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            navigationController?.pushViewController(MemoListController(), animated: true)
        } else if indexPath.section == 1 && indexPath.row == 0 {
            let controller = MFMailComposeViewController()
            controller.mailComposeDelegate = self
            controller.setToRecipients(["info@urouro.net"])
            controller.setSubject("アイデアカードへのフィードバック")
            present(controller, animated: true, completion: nil)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}
