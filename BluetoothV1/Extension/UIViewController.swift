//
//  UIViewController.swift
//  NewStartPart
//
//  Created by Yi Tong on 7/18/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import UIKit

extension UIViewController {
    
    static var displayTimer: Timer?
    
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
    
    func displayAlert(title: String? = nil, msg: String, dismissAfter seconds: TimeInterval = 1.35) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        present(alert, animated: true) {
            alert.view.superview?.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.alertBackgroundTapped))
            alert.view.superview?.addGestureRecognizer(tap)
            UIViewController.displayTimer = Timer.scheduledTimer(withTimeInterval: seconds, repeats: false) { [weak self] _ in
                self?.dismiss(animated: true)
            }
        }
    }
    
    @objc func alertBackgroundTapped() {
        self.dismiss(animated: false, completion: nil)
        UIViewController.displayTimer?.invalidate()
        UIViewController.displayTimer = nil
    }
}
