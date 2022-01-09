//
//  AQIListTableViewCell.swift
//  AirQuality
//
//  Created by Prince Sojitra on 09/01/22.
//

import DTTableViewManager
import UIKit

class AQIListTableViewCell: UITableViewCell, ModelTransfer {

    @IBOutlet weak var cityView: UIView!
    @IBOutlet weak var airQualityLabel: UILabel!
    @IBOutlet weak var airQualityCircleView: UIView!
    @IBOutlet weak var airQualityCategoryLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var lastUpdatedLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        airQualityCircleView.layer.cornerRadius = airQualityCircleView.frame.height*0.5
        airQualityCircleView.layer.borderWidth = 3.0
        airQualityCircleView.layer.borderColor = UIColor(named: AQICategoryColor.unknown.rawValue)?.cgColor
        cityView.layer.cornerRadius = 10.0
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    func update(with model: AQIListIItemCellObjects) {
        if let airQualityIndex = model.airQualityIndex {
            airQualityLabel.text = String(format: "%.2f", airQualityIndex)
        }
        if let airQualityCategory = model.airQualityCategory {
            airQualityCategoryLabel.text = airQualityCategory.description
        }
        if let lastUpdatedTime = model.lastUpdated {
            lastUpdatedLabel.text = "\(AQIListStrings.lastUpdatedTitle) \(lastUpdatedTime)"
        }
        if let city = model.city {
            cityLabel.text = city
        }
        if let airQualityCategoryColor = model.airQualityCategoryColor {
            airQualityCircleView.layer.borderColor = airQualityCategoryColor.cgColor
        }
    }
}
