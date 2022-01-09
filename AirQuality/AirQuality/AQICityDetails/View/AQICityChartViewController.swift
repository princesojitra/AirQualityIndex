//
//  AQICityChartViewController.swift
//  AirQuality
//
//  Created by Prince Sojitra on 09/01/22.
//

import UIKit
import Starscream
import Charts
import SnapKit

class AQICityChartViewController: UIViewController, ChartViewDelegate
{
    var chartView: BarChartView!
    var containerStackView: UIStackView!
    let customMarkerView = CustomMarkerView()
    var cityDataModel: AQICityDetails.CityDataModel?
    var viewModel : AQICityChartViewModel!

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    fileprivate func commonInit() {
        edgesForExtendedLayout = []
        self.chartView = BarChartView()
        self.containerStackView = UIStackView(arrangedSubviews: [self.chartView])
        self.containerStackView.axis = .vertical
        view.backgroundColor = .white
        self.view.addSubview(self.containerStackView)
        self.containerStackView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(50.0)
            make.height.equalTo(500.0)
        }
    }

    init(cityDataModel: AQICityDetails.CityDataModel?) {
        self.cityDataModel = cityDataModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel = AQICityChartViewModel(cityModel: cityDataModel, refreshDelegate: self)
        commonInit()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = UIColor.white
        let item = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = item
        self.title = viewModel.cityDataModel?.cityName
        self.viewModel.prepareChartData()
        self.setupBarChart()
        self.setupMarker()
    }
    

    func setupBarChart() {
        chartView.delegate = self
        chartView.highlightPerTapEnabled = true
        chartView.highlightFullBarEnabled = true
        chartView.highlightPerDragEnabled = false

        chartView.pinchZoomEnabled = true
        chartView.setScaleEnabled(true)
        chartView.doubleTapToZoomEnabled = false
        chartView.fitScreen()
        chartView.drawBarShadowEnabled = false
        chartView.drawBordersEnabled = false
        chartView.drawGridBackgroundEnabled = false
        chartView.animate(yAxisDuration: 1.5 , easingOption: .easeOutBounce)
        chartView.legend.enabled = false
        chartView.borderColor = .chartLineColour
        chartView.setExtraOffsets(left: 10, top: 0, right: 20, bottom: 50)

        // Setup X axis
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.drawAxisLineEnabled = true
        xAxis.drawGridLinesEnabled = false
        xAxis.granularityEnabled = false
        xAxis.labelRotationAngle = -25
        xAxis.setLabelCount(viewModel.cityDataModel!.aqiHistoryData.count, force: false)
        xAxis.valueFormatter = IndexAxisValueFormatter(values: viewModel.cityDataModel!.aqiHistoryData.map { $0.lastUpdated.convertTo(format: "h:mm:ss a") })
        xAxis.axisMaximum = Double(viewModel.cityDataModel!.aqiHistoryData.count)
        xAxis.axisLineColor = .chartLineColour
        xAxis.labelTextColor = .chartLineColour

        // Setup left axis
        let leftAxis = chartView.leftAxis
        leftAxis.drawTopYLabelEntryEnabled = true
        leftAxis.drawAxisLineEnabled = true
        leftAxis.drawGridLinesEnabled = true
        leftAxis.granularityEnabled = false
        leftAxis.axisLineColor = .chartLineColour
        leftAxis.labelTextColor = .chartLineColour

        leftAxis.setLabelCount(5, force: false)
        leftAxis.axisMinimum = 0.0
        leftAxis.axisMaximum = 500.0

        // Remove right axis
        let rightAxis = chartView.rightAxis
        rightAxis.enabled = false

    }

    func setupMarker() {
        customMarkerView.chartView = chartView
        chartView.marker = customMarkerView
    }

    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        guard let dataSet = chartView.data?.dataSets[highlight.dataSetIndex] else { return }
        let entryIndex = dataSet.entryIndex(entry: entry)

        customMarkerView.rateLabel.text = "\(viewModel.items[entryIndex].aqi)"
        customMarkerView.countryLabel.text = viewModel.items[entryIndex].lastUpdated
    }
}

extension AQICityChartViewController: AQIChartViewDelegate
{
    func refreshCityChart() {
        self.chartView.data = self.viewModel.chartData
        setupBarChart()
        setupMarker()
    }
}
