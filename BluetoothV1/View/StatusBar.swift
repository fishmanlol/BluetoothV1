//
//  StatusBar.swift
//  Bluetooth-New
//
//  Created by Yi Tong on 8/1/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//https://xd.adobe.com/view/c99c2128-c82e-4146-59a0-39fe48345dc8-bfad/?fullscreen

import UIKit

class StatusBar: UIView {
    private weak var contentStackView: UIStackView!
    private weak var spinView: SpinView!
    private weak var textLabel: UILabel!
    
    var status: Status  = .hidden {
        didSet {
            statusChanged(from: oldValue, to: status)
        }
    }
    
    var title: String? {
        get {
            return textLabel.text
        }
        
        set {
            textLabel.text = newValue
        }
    }
    
    var titleColor: UIColor = UIColor.black {
        didSet {
            textLabel.textColor = titleColor
        }
    }
    
    var titleFont: UIFont = UIFont.avenirNext(bold: .regular, size: UIFont.middleFontSize) {
        didSet {
            textLabel.font = titleFont
        }
    }
    
    var spinColor: UIColor {
        get {
            return spinView.tintColor
        }
        
        set {
            spinView.tintColor = newValue
        }
    }
    
    private(set) var isAnimating: Bool = false
    
    func startAnimating () {
        spinView.startAnimating()
        isAnimating = true
    }
    
    func stopAnimating() {
        spinView.stopAnimating()
        isAnimating = false
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setup() {
        let contentStackView = UIStackView()
        contentStackView.axis = .horizontal
        contentStackView.alignment = .center
        contentStackView.spacing = 10
        self.contentStackView = contentStackView
        addSubview(contentStackView)
        
        let spinView = SpinView(spinViewStyle: .small)
        spinView.frequency = 0.8
        self.spinView = spinView
        contentStackView.addArrangedSubview(spinView)
        
        let textLabel = UILabel()
        textLabel.textColor = titleColor
        textLabel.font = titleFont
        self.textLabel = textLabel
        contentStackView.addArrangedSubview(textLabel)
        
        contentStackView.snp.makeConstraints { (make) in
            make.center.height.equalToSuperview()
        }
    }
    
    private func statusChanged(from oldStatus: Status, to newStatus: Status) {
        
    }
    
    enum Status {
        case succeed(String)
        case failed(String)
        case working(String)
        case hidden
    }
}
