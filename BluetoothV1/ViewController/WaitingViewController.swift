//
//  WaitingViewController.swift
//  BluetoothV1
//
//  Created by tongyi on 8/4/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import UIKit
import Lottie


class WaitingViewController: UIViewController {
    weak var textLabel: UILabel!
    weak var animationView: AnimationView!
    weak var cancelButton: UIButton!
    
    init() {
        super.init(nibName: nil, bundle: nil)
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        animationView.play()
    }
    
    @objc func cancelButtonTapped(sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

//MARK: Private functions
extension WaitingViewController {
    private func setup() {
        view.backgroundColor = .white
        
        let textLabel = UILabel()
        textLabel.text = "Waiting for the measurement of the device"
        textLabel.font = UIFont.avenirNext(bold: .medium, size: UIFont.largeFontSize)
        textLabel.numberOfLines = 0
        textLabel.textAlignment = .center
        self.textLabel = textLabel
        view.addSubview(textLabel)
        
        let animationView = AnimationView(name: "progress_bar")
        animationView.loopMode = .loop
        self.animationView = animationView
        view.addSubview(animationView)
        
        let cancelButton = UIButton(type: .system)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        cancelButton.roundedCorner()
        cancelButton.backgroundColor = UIColor.lightBlue
        cancelButton.tintColor = .white
        cancelButton.setTitle("Cancel", for: .normal)
        self.cancelButton = cancelButton
        view.addSubview(cancelButton)
        
        animationView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.center.equalToSuperview()
        }
        
        textLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(animationView.snp.top).offset(-30)
            make.width.equalToSuperview().multipliedBy(0.8)
        }
        
        let buttonWidth = min(view.bounds.width * 0.75, 300)
        cancelButton.snp.makeConstraints { (make) in
            make.width.equalTo(buttonWidth)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            } else {
                make.bottom.equalToSuperview()
            }
            make.centerX.equalToSuperview()
            make.height.equalTo(44)
        }
    }
}
