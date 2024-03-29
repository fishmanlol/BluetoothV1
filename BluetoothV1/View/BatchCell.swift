//
//  GeneralBatchCell.swift
//  BluetoothV1
//
//  Created by Yi Tong on 8/8/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import UIKit
import Charts

class BatchCell: UITableViewCell {
    weak var timeLabel: UILabel!
    weak var shadowView: UIView!
    var model: DeviceModel?
    
    lazy var recordsView: UIView = {
        guard let model = model else { return UIView() }
        switch model {
        case .TEMP03, .WT01, .TEMP01:
            let singleRecordView = SingleRecordView(model: model)
            contentView.addSubview(singleRecordView)
            singleRecordView.snp.makeConstraints { (make) in
                make.edges.equalTo(shadowView)
            }
            
            shadowView.snp.updateConstraints { (make) in
                make.height.equalTo(singleRecordView.intrinsicContentSize.height)
            }
            
            return singleRecordView
        case .NIBP03, .NIBP04, .SpO2, .BC01, .PM10, .PULMO01, .BG01:
            let generalRecordsView = GeneralRecordsView(model: model)
            contentView.addSubview(generalRecordsView)
            generalRecordsView.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.left.equalTo(shadowView).offset(30)
                make.top.equalTo(shadowView).offset(20)
                make.bottom.equalTo(shadowView).offset(-20)
            }
            
            shadowView.snp.updateConstraints { (make) in
                make.height.equalTo(generalRecordsView.intrinsicContentSize.height)
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
        case .NIBP03, .NIBP04, .SpO2, .BC01, .PM10, .PULMO01, .BG01:
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
        
        
        let shadowView = UIView()
        shadowView.layer.cornerRadius = 12
        shadowView.layer.shadowOpacity = 0.23
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOffset = CGSize.zero
        shadowView.layer.shadowRadius = 4
        shadowView.layer.masksToBounds = false
        shadowView.layer.shouldRasterize = true
        shadowView.layer.rasterizationScale = UIScreen.main.scale
        shadowView.backgroundColor = .white
        
        self.shadowView = shadowView
        contentView.addSubview(shadowView)
        
        timeLabel.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(20)
        }
        
        shadowView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-10)
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
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 0, height: 140)
    }
    
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
        
        recordLabel.text = "\(value)"
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
    weak var chartView: LineChartView!
    var labels: [Record.RecordType: (UILabel, UILabel)] = [:]
    
    override var intrinsicContentSize: CGSize {
        var height = (CGFloat(labels.count) * 80)
        if model! == .PM10 {
            height += 200
        }
        return CGSize(width: 0, height: height)
    }
    
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
            if record.type == .ecg { //Ecg is graph, need handle separately
                guard let numbers = record.value as? [Double] else { continue }
                
                let xAxis = self.chartView.xAxis
                xAxis.setLabelCount(11, force: true)
                xAxis.valueFormatter = self
                
                self.chartView.rightAxis.enabled = false
                self.chartView.dragEnabled = false
                self.chartView.setScaleEnabled(false)
                self.chartView.pinchZoomEnabled = false
                self.chartView.highlightPerTapEnabled = false
                self.chartView.highlightPerDragEnabled = false
                self.chartView.chartDescription?.text = "ECG chart"
                
                //Complex calculation
                DispatchQueue.global().async {
                    var lineChartEntries = [ChartDataEntry]()
                    for i in 0..<numbers.count {
                        let entry = ChartDataEntry(x: Double(i), y: numbers[i], icon: nil)
                        
                        lineChartEntries.append(entry)
                    }
                    let line = LineChartDataSet(entries: lineChartEntries, label: nil)
                    line.setColor(NSUIColor(r: 38, g: 148, b: 189))
                    line.axisDependency = .left
                    line.drawCirclesEnabled = false
                    line.drawValuesEnabled = false
                    let chartData = LineChartData()
                    chartData.addDataSet(line)
                    
                    DispatchQueue.main.async {
                        self.chartView.data = chartData
                    }
                }
                continue
            }
            
            guard let (label, indicator) = labels[record.type] else { continue }
            
            switch record.type {
            case .sg: //Value is string
                guard let value = record.value as? String else { continue }
                label.text = "\(value)"
            default://Value is double
                guard let value = record.value as? Double else { continue }
                if floor(value).isEqual(to: value) {
                    label.text = "\(Int(value))"
                } else {
                    label.text = "\(value)"
                }
                
            }
            
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
            if type == .ecg { //ecg is graph
                let chartView = LineChartView()
                self.chartView = chartView
                vs.spacing = 30
                vs.distribution = .fill
                vs.addArrangedSubview(chartView)
                chartView.snp.makeConstraints { (make) in
                    make.left.right.equalToSuperview()
                }
                continue
            }
            
            let hs = UIStackView()
            hs.axis = .horizontal
            hs.alignment = .bottom
            hs.distribution = .fill
            
            //other type
            
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

extension GeneralRecordsView: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        guard let _ = axis else { return "" }
        return "\(Int((value / 250).rounded()))s"
    }
}
