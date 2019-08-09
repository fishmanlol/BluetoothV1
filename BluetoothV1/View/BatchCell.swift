//
//  GeneralBatchCell.swift
//  BluetoothV1
//
//  Created by Yi Tong on 8/8/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import UIKit

class BatchCell: UITableViewCell {
    weak var timeLabel: UILabel!
    weak var backgroundImageView: UIImageView!
    var model: DeviceModel?
    
    private let temperatureCellBackgroundHeight: CGFloat = 140
    private let bloodPressureBackgoundHeight: CGFloat = 240
    
    lazy var recordsView: UIView = {
        guard let model = model else { return UIView() }
        switch model {
        case .TEMP03:
            let temperatureRecordsView = TemperatureRecordsView()
            contentView.addSubview(temperatureRecordsView)
            temperatureRecordsView.snp.makeConstraints { (make) in
                make.centerX.left.top.equalTo(backgroundImageView)
                make.bottom.equalTo(backgroundImageView).offset(-10)
            }
            
            backgroundImageView.snp.updateConstraints { (make) in
                make.height.equalTo(temperatureCellBackgroundHeight)
            }
            
            return temperatureRecordsView
        case .NIBP03, .NIBP04:
            let generalRecordsView = GeneralRecordsView(model: model)
            contentView.addSubview(generalRecordsView)
            generalRecordsView.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.left.equalTo(backgroundImageView).offset(30)
                make.top.equalTo(backgroundImageView).offset(20)
                make.bottom.equalTo(backgroundImageView).offset(-30)
            }
            
            backgroundImageView.snp.updateConstraints { (make) in
                make.height.equalTo(bloodPressureBackgoundHeight)
            }
            
            return generalRecordsView
            
        default: fatalError()
        }
        
        fatalError()
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public func configure(with batch: Batch, for model: DeviceModel) {
        self.model = model
        
        timeLabel.text = batch.date?.formattedString ?? ""
        
        switch model {
        case .TEMP03:
            guard let recordsView = recordsView as? TemperatureRecordsView else { return }
            recordsView.configure(with: batch)
        case .NIBP03, .NIBP04:
            guard let recordsView = recordsView as? GeneralRecordsView else { return }
//            recordsView.configure(with: batch)
        default:
            fatalError()
        }
    }
}

// MARK: - Private functions
extension BatchCell {
    private func setup() {
        selectionStyle = .none
        
        let timeLabel = UILabel()
        timeLabel.textAlignment = .center
        timeLabel.font = UIFont.avenirNext(bold: .regular, size: 17)
        timeLabel.textColor = .gray
        self.timeLabel = timeLabel
        contentView.addSubview(timeLabel)
        
        let backgroundImageView = UIImageView(image: UIImage(named: "cell_background_1"))
        backgroundImageView.contentMode = .scaleToFill
        self.backgroundImageView = backgroundImageView
        contentView.addSubview(backgroundImageView)
        
        timeLabel.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(20)
        }
        
        backgroundImageView.snp.makeConstraints { (make) in
            make.bottom.centerX.equalToSuperview()
            make.left.equalTo(30)
            make.height.equalTo(160)
            make.top.equalTo(timeLabel.snp.bottom).offset(10)
        }
    }
}

class TemperatureRecordsView: UIView {
    weak var temperatureLabel: UILabel!
    weak var unitLabel: UILabel!
    weak var indicator: UILabel!//↓↑
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public func configure(with batch: Batch) {
        if let record = batch.records.first, let value = record.value as? Double {
            unitLabel.textColor = record.level.tintColor
            temperatureLabel.textColor = record.level.tintColor
            temperatureLabel.text = "\(value.rounded())"
            indicator.textColor = record.level.tintColor
            indicator.text = record.level.symbol
        } else {
            temperatureLabel.text = "_ _"
            unitLabel.textColor = .gray
            temperatureLabel.textColor = .gray
        }
        
    }
    
//    public func setTemperature(_ val: Double?) {
//        if let val = val {
//
//
//
//            if isTemperatureLow(val) || isTemperatureHigh(val) {
//                unitLabel.textColor = UIColor(r: 255, g: 40, b: 0)
//                temperatureLabel.textColor = UIColor(r: 255, g: 40, b: 0)
//
//            } else {
//                unitLabel.textColor = UIColor(r: 38, g: 148, b: 189)
//                temperatureLabel.textColor = UIColor(r: 38, g: 148, b: 189)
//            }
//
//            temperatureLabel.text = "\(val.rounded())"
//        } else {
//            temperatureLabel.text = "_ _"
//            unitLabel.textColor = .gray
//            temperatureLabel.textColor = .gray
//        }
//
//    }
//
//    public func setUnit(_ unit: String) {
//        unitLabel.text = unit
//    }
    
    private func setup() {
        let temperatureLabel = UILabel()
        temperatureLabel.font = UIFont.avenirNext(bold: .regular, size: 64)
        temperatureLabel.text = "_ _"
        temperatureLabel.textColor = .gray
        self.temperatureLabel = temperatureLabel
        addSubview(temperatureLabel)
        
        let unitLabel = UILabel()
        unitLabel.textColor = .gray
        unitLabel.font = UIFont.avenirNext(bold: .regular, size: 24)
        unitLabel.text = "°F"
        unitLabel.setContentHuggingPriority(.defaultHigh + 1, for: .horizontal)
        self.unitLabel = unitLabel
        addSubview(unitLabel)
        
        let indicator = UILabel()
        self.indicator = indicator
        addSubview(indicator)
        
        temperatureLabel.snp.makeConstraints { (make) in
            make.centerX.bottom.equalToSuperview()
        }
        
        unitLabel.snp.makeConstraints { (make) in
            make.firstBaseline.equalTo(temperatureLabel)
            make.left.equalTo(temperatureLabel.snp.right)
        }
        
        indicator.snp.makeConstraints { (make) in
            make.left.equalTo(unitLabel.snp.right)
            make.top.equalTo(temperatureLabel)
        }
    }
}

class GeneralRecordsView: UIView {
    var model: DeviceModel!
    weak var verticalStackView: UIStackView!
    weak var horizontalStackView: UIStackView!
    var labels: [Record.RecordType: UILabel] = [:]
    
    init(model: DeviceModel) {
        self.model = model
        super.init(frame: .zero)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
//    public func configure(with batch: Batch) {
//        for record in batch.records {
//            guard let label = labels[record.type] else { return }
//            guard let value = record.value as? Double else { return }
//
//            switch record.type {
//            case .diastolic:
//
//            default:
//                <#code#>
//            }
//
//
//            label.text = "\(value.rounded())"
//        }
//    }
    
    private func setup() {
        let vs = UIStackView()
        vs.axis = .vertical
        vs.alignment = .fill
        vs.distribution = .equalSpacing
        vs.spacing = 0
        self.verticalStackView = vs
        addSubview(vs)
        
        for type in model.recordTypes {
            let hs = UIStackView()
            hs.axis = .horizontal
            hs.alignment = .bottom
            hs.distribution = .fill
            
            let imageView = UIImageView()
            imageView.contentMode = .left
            imageView.image = type.labelImage
            hs.addArrangedSubview(imageView)
            
            let label = UILabel()
            label.textAlignment = .right
            label.setContentHuggingPriority(.defaultHigh + 1, for: .horizontal)
            label.font = UIFont.avenirNext(bold: .regular, size: 30)
            label.text = "_ _"
            label.textColor = .gray
            labels[type] = label
            hs.addArrangedSubview(label)
            
            self.horizontalStackView = hs
            vs.addArrangedSubview(hs)
        }
        
        vs.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}


