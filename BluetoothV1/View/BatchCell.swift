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
    
    private let singleRecordBackgroundHeight: CGFloat = 140
    private let bloodPressureBackgoundHeight: CGFloat = 240
    
    lazy var recordsView: UIView = {
        guard let model = model else { return UIView() }
        switch model {
        case .TEMP03, .WT01, .TEMP01:
            let singleRecordView = SingleRecordView(model: model)
            contentView.addSubview(singleRecordView)
            singleRecordView.snp.makeConstraints { (make) in
                make.centerX.left.top.equalTo(backgroundImageView)
                make.bottom.equalTo(backgroundImageView).offset(-10)
            }
            
            backgroundImageView.snp.updateConstraints { (make) in
                make.height.equalTo(singleRecordBackgroundHeight)
            }
            
            return singleRecordView
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
        case .TEMP03, .WT01, .TEMP01:
            guard let recordsView = recordsView as? SingleRecordView else { return }
            recordsView.configure(with: batch)
        case .NIBP03, .NIBP04:
            guard let recordsView = recordsView as? GeneralRecordsView else { return }
            recordsView.configure(with: batch)
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

class SingleRecordView: UIView {
    weak var recordLabel: UILabel!
    weak var unitLabel: UILabel!
    weak var indicator: UILabel!
    var model: DeviceModel!
    
    init(model: DeviceModel) {
        super.init(frame: .zero)
        self.model = model
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public func configure(with batch: Batch) {
        guard let record = batch.records.first, let value = record.value as? Double else {
            return
        }
        
        unitLabel.text = record.type.unit
        unitLabel.textColor = UIColor(r: 38, g: 148, b: 189)
        
        recordLabel.text = "\(value.rounded())"
        recordLabel.textColor = UIColor(r: 38, g: 148, b: 189)
        
        indicator.textColor = record.level.tintColor
        indicator.text = record.level.symbol
    }
    
    private func setup() {
        let recordLabel = UILabel()
        recordLabel.text = "_ _"
        recordLabel.font = UIFont.avenirNext(bold: .regular, size: 64)
        recordLabel.textColor = .gray
        self.recordLabel = recordLabel
        addSubview(recordLabel)
        
        let unitLabel = UILabel()
        
        switch model! {
        case .WT01:
            unitLabel.text = Record.RecordType.weight.unit
        case .TEMP03:
            unitLabel.text = Record.RecordType.temperature.unit
        default:
            break
        }
        
        unitLabel.textColor = .gray
        unitLabel.font = UIFont.avenirNext(bold: .regular, size: 24)
        unitLabel.setContentHuggingPriority(.defaultHigh + 1, for: .horizontal)
        self.unitLabel = unitLabel
        addSubview(unitLabel)
        
        let indicator = UILabel()
        self.indicator = indicator
        addSubview(indicator)
        
        recordLabel.snp.makeConstraints { (make) in
            make.centerX.bottom.equalToSuperview()
        }
        
        unitLabel.snp.makeConstraints { (make) in
            make.firstBaseline.equalTo(recordLabel)
            make.left.equalTo(recordLabel.snp.right).offset(2)
        }
        
        indicator.snp.makeConstraints { (make) in
            make.left.equalTo(unitLabel.snp.right)
            make.top.equalTo(recordLabel)
        }
    }
}

class GeneralRecordsView: UIView {
    var model: DeviceModel!
    weak var verticalStackView: UIStackView!
    weak var horizontalStackView: UIStackView!
    var labels: [Record.RecordType: (UILabel, UILabel)] = [:]
    
    init(model: DeviceModel) {
        self.model = model
        super.init(frame: .zero)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public func configure(with batch: Batch) {
        for record in batch.records {
            guard let (label, indicator) = labels[record.type] else { return }
            guard let value = record.value as? Double else { return }
            
            label.text = "\(value.rounded())"
            label.textColor = UIColor(r: 38, g: 148, b: 189)
            
            indicator.text = record.level.symbol
            indicator.textColor = record.level.tintColor
        }
    }
    
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
            hs.addArrangedSubview(label)
            
            let indicator = UILabel()
            indicator.setContentHuggingPriority(.defaultHigh + 1, for: .horizontal)
            hs.addArrangedSubview(indicator)
            
            indicator.snp.makeConstraints { (make) in
                make.top.equalToSuperview()
                make.width.greaterThanOrEqualTo(10)
            }
            
            if #available(iOS 11.0, *) {
                hs.setCustomSpacing(2, after: label)
            }
            
            labels[type] = (label, indicator)
            
            self.horizontalStackView = hs
            vs.addArrangedSubview(hs)
        }
        
        vs.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}


