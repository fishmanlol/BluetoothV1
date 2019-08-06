//
//  UIViewController.swift
//  NewStartPart
//
//  Created by Yi Tong on 7/18/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import UIKit

extension UIViewController {
    func displayAlert(title: String?, msg: String, hasCancel: Bool, actionStyle:  UIAlertAction.Style = .default, actionTitle: String = "OK",action: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: actionTitle, style: actionStyle) { (_) in
            action()
        }
        
        alert.addAction(OKAction)
        
        if hasCancel {
            let CancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            alert.addAction(CancelAction)
        }
        
        present(alert, animated: true, completion: nil)
    }
}
