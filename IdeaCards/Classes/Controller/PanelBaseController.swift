//
//  PanelBaseController.swift
//  IdeaCards
//
//  Created by Kenta Nakai on 2016/01/16.
//  Copyright © 2016 UROURO. All rights reserved.
//

import UIKit
import JASidePanels

class PanelBaseController: JASidePanelController {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        buildUI()
    }
    
    fileprivate func buildUI() {
        let topController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TopController") as! TopController
        let leftController = EditController()
        leftController.type = .left
        let rightController = EditController()
        rightController.type = .right
        
        let topNav = UINavigationController(rootViewController: topController)
        topNav.setNavigationBarHidden(true, animated: false)
        let leftNav = UINavigationController(rootViewController: leftController)
        leftNav.setNavigationBarHidden(false, animated: false)
        let rightNav = UINavigationController(rootViewController: rightController)
        rightNav.setNavigationBarHidden(false, animated: false)
        
        leftPanel = leftNav
        centerPanel = topNav
        rightPanel = rightNav
        
        leftGapPercentage = 0.9
        rightGapPercentage = 0.9
    }
    
}
