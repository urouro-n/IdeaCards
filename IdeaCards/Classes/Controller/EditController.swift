//
//  EditController.swift
//  IdeaCards
//
//  Created by Kenta on 2017/03/02.
//  Copyright © 2017年 UROURO. All rights reserved.
//

import UIKit

enum EditType {
    case left
    case right
}

class EditController: UIViewController {
    
    var type: EditType = .left
    
    fileprivate lazy var tableView: UITableView = {
        let v = UITableView(frame: CGRect.zero, style: .plain)
        v.delegate = self
        v.dataSource = self
        
        switch self.type {
        case .left:
            v.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        case .right:
            v.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        }

        
        return v
    }()
    
    fileprivate lazy var addView: UIView = {
        let v = UIView(frame: CGRect(x: 0.0,
                                     y: 0.0,
                                     width: self.view.frame.size.width,
                                     height: 44.0))
        v.backgroundColor = UIColor.clear
        
        v.addSubview(self.addField)
        v.addSubview(self.addButton)
        
        return v
    }()
    
    fileprivate lazy var addField: UITextField = {
        let field = UITextField()
        switch self.type {
        case .right:
            field.frame = CGRect(x: 40.0, y: 5.0, width: 220.0, height: 34.0)
        case .left:
            field.frame = CGRect(x: 0.0, y: 5.0, width: 220.0, height: 34.0)
        }
        field.delegate = self
        field.borderStyle = .roundedRect
        field.returnKeyType = .done
        field.placeholder = "キーワードを入力"
        return field
    }()
    
    fileprivate lazy var addButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: self.addField.frame.origin.x + self.addField.frame.size.width,
                              y: 0.0,
                              width: 44.0,
                              height: 44.0)
        button.titleLabel?.font = UIFont(name: "Helvetica-Bold", size: 32.0)
        button.titleEdgeInsets = UIEdgeInsets(top: -5.0, left: 0.0, bottom: 0.0, right: 0.0)
        button.setTitle("+", for: .normal)
        button.setTitleColor(UIColor.darkGray, for: .normal)
        button.backgroundColor = UIColor.clear
        button.titleLabel?.shadowColor = UIColor.black
        button.titleLabel?.shadowOffset = CGSize(width: 0.0, height: -1.0)
        button.addTarget(self, action: #selector(EditController.onAddButton(_:)), for: .touchUpInside)
        return button
    }()
    
}

// MARK: - View Lifecycle
extension EditController {
    
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = UIColor.white
        
        view.addSubview(tableView)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: addView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(EditController.orientationChanged(_:)), name: Notification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        orientationChanged(nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
}


// MARK: - Action
extension EditController {
    
    func onAddButton(_ sender: UIButton) {
        addField.resignFirstResponder()
        
        add()
    }
    
    func orientationChanged(_ notification: Notification?) {
        let orientation = UIApplication.shared.statusBarOrientation
        
        switch orientation {
        case .portrait, .portraitUpsideDown, .unknown:
            switch type {
            case .right:
                tableView.frame = CGRect(x: 40.0,
                                         y: 0.0,
                                         width: view.frame.size.width - 40.0,
                                         height: view.frame.size.height)
                addField.frame = CGRect(x: 56.0,
                                        y: 5.0,
                                        width: 220.0,
                                        height: 34.0)
            case .left:
                tableView.frame = CGRect(x: 0.0,
                                         y: 0.0,
                                         width: view.frame.size.width - 40.0,
                                         height: view.frame.size.height)
                addField.frame = CGRect(x: 16.0,
                                        y: 5.0,
                                        width: 220.0,
                                        height: 34.0)
            }
            
            addButton.frame = CGRect(x: addField.frame.origin.x + addField.frame.size.width,
                                     y: 0.0,
                                     width: 44.0,
                                     height: 44.0)
            addView.frame = CGRect(x: 0.0,
                                   y: 0.0,
                                   width: view.frame.size.width,
                                   height: 44.0)
            
        case .landscapeLeft, .landscapeRight:
            switch type {
            case .right:
                tableView.frame = CGRect(x: 48.0,
                                         y: 0.0,
                                         width: view.frame.size.height - 48.0,
                                         height: view.frame.size.width)
                addField.frame = CGRect(x: 48.0,
                                        y: 8.0,
                                        width: view.frame.size.width + 30.0,
                                        height: 26.0)
                
            case .left:
                tableView.frame = CGRect(x: 0.0,
                                         y: 0.0,
                                         width: view.frame.size.height - 48.0,
                                         height: view.frame.size.width)
                addField.frame = CGRect(x: 0.0,
                                        y: 8.0,
                                        width: view.frame.size.width + 30.0,
                                        height: 26.0)
            }
            
            addButton.frame = CGRect(x: addField.frame.origin.x + addField.frame.size.width,
                                     y: 0.0,
                                     width: 44.0,
                                     height: 44.0)
            addView.frame = CGRect(x: 0.0,
                                   y: 0.0,
                                   width: view.frame.size.height,
                                   height: 44.0)
        }
    }
    
}

extension EditController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch type {
        case .right:
            return ICItemManager.shared().rightItems().count
        case .left:
            return ICItemManager.shared().leftItems().count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "CellIdentifier"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: identifier)
        }
        
        let items: [Any]
        
        switch type {
        case .right:
            items = ICItemManager.shared().rightItems()
        case .left:
            items = ICItemManager.shared().leftItems()
        }
        
        cell!.textLabel?.text = items[indexPath.row] as? String
        return cell!
    }
    
}

extension EditController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch type {
        case .right:
            ICItemManager.shared().deleteRightItem(at: indexPath.row)
        case .left:
            ICItemManager.shared().deleteLeftItem(at: indexPath.row)
        }
        
        tableView.deleteRows(at: [indexPath], with: .fade)
        
        reloadData()
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
}

extension EditController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        add()
        
        return true
    }
    
}

fileprivate extension EditController {
    
    func reloadData() {
        tableView.reloadData()
        
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if let basePanelController = appDelegate.basePanelController {
            let navController: UINavigationController = basePanelController.centerPanel as! UINavigationController
            let topController: TopController = navController.viewControllers[0] as! TopController
            topController.reloadData()
        }
    }
    
    func add() {
        guard let text = addField.text else {
            return
        }
        
        if text.characters.count <= 0 {
            return
        }
        
        switch type {
        case .right:
            ICItemManager.shared().addRightItem(text)
        case .left:
            ICItemManager.shared().addLeftItem(text)
        }
        
        addField.text = nil
        
        reloadData()
    }
    
}
