//
//  BaseVC.swift
//  LAS_SAMPLE_014
//
//  Created by Minh Tuan on 16/06/2023.
//

import UIKit

class BaseVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return.default
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
}


extension BaseVC {
    func openMyFile(){
        guard let navi = UIWindow.keyWindow?.rootViewController as? UINavigationController else {
            return
        }
        let myFileVC: MyFileVC = MyFileVC()
        navi.pushViewController(myFileVC, animated: true)
        
    }
}
