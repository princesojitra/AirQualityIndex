//
//  AQICityChartViewModel.swift
//  AirQuality
//
//  Created by Prince Sojitra on 09/01/22.
//


import Foundation
import UIKit
import Charts

protocol AQIChartViewDelegate: AnyObject {
    func refreshCityChart()
}

class AQICityChartViewModel: NSObject {
    var chartData: ChartData?
    var items = [CityItem]()
    var cityDataModel : AQICityDetails.CityDataModel?
    weak var refreshChartDelegate: AQIChartViewDelegate?

    init(cityModel: AQICityDetails.CityDataModel? = nil, refreshDelegate: AQIChartViewDelegate? = nil) {
        self.cityDataModel = cityModel
        self.refreshChartDelegate = refreshDelegate
    }
}

extension AQICityChartViewModel: AQICityChartDelegate
{
    func refreshCityDataToChart(with data: AQICityDetails.CityDataModel) {
        self.cityDataModel = data
        prepareChartData()
    }

    func prepareChartData() {
        guard let cityModel = self.cityDataModel else { return }
        self.items =  getFormattedItemValue(cityModel.aqiHistoryData)
        let dataEntries = items.map{ $0.transformToBarChartDataEntry() }
        let set1 = BarChartDataSet(entries: dataEntries)
        set1.setColor(.chartBarColour)
        set1.highlightColor = .chartHightlightColour
        set1.highlightAlpha = 1

        let data = BarChartData(dataSet: set1)
        data.setDrawValues(true)
        data.setValueTextColor(.chartLineColour)
        let barValueFormatter = BarValueFormatter()
        data.setValueFormatter(barValueFormatter)
        chartData = data
        self.refreshChartDelegate?.refreshCityChart()
    }

    func getFormattedItemValue(_ rawValues: [AQICityDetails.AQIDataModel]) -> [CityItem] {
        var items = [CityItem]()
        var index = 0

        for i in rawValues {
            let time = i.lastUpdated.convertTo(format: "h:mm a")
            let aqi = i.aqi.roundingToDecimal(place: 2)

            items.append(CityItem(index: index, aqi: aqi, lastUpdated: time))
            index += 1
        }
        return items
    }
}


// MARK: - Type Definition
struct CityItem {
    let index: Int
    let aqi: Double
    let lastUpdated: String

    func transformToBarChartDataEntry() -> BarChartDataEntry {
        let entry = BarChartDataEntry(x: Double(index), y: aqi)
        return entry
    }
}

class BarValueFormatter: ValueFormatter {
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        return String(format: "%.2f", value)
    }
}
