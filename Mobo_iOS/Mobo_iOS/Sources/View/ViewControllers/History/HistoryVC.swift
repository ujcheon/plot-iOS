//
//  HistoryVC.swift
//  Mobo_iOS
//
//  Created by 천유정 on 31/12/2019.
//  Copyright © 2019 조경진. All rights reserved.
//

import UIKit

class HistoryVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationSetup()
        // Do any additional setup after loading the view.
    }
    
    func navigationSetup() {
           self.navigationController?.navigationBar.shadowImage = UIImage()
           
           self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
           
           self.navigationController?.navigationBar.isTranslucent = true
           
           self.navigationController?.view.backgroundColor = UIColor.white.withAlphaComponent(0.0)
       }

}
