//
//  AQICitychartModelTest.swift
//  AirQualityTests
//
//  Created by Prince Sojitra on 09/01/22.
//

import XCTest
@testable import AirQuality

class AQICitychartModelTest: XCTestCase {
    var viewModel: AQICityChartViewModel!
    var viewController: AQICityChartViewController!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func setUp() {
        super.setUp()
        viewController = AQICityChartViewController()
        viewController.viewDidLoad()
        viewController.refreshCityChart()
        viewController.setupBarChart()
        viewController.setupMarker()
    }

    override func tearDown() {
        super.tearDown()
    }

    func tesChartData() {
        let testAQIString = "[{\"city\":\"Kolkata\",\"aqi\":201.82153891079136},{\"city\":\"Pune\",\"aqi\":222.77115965463338},{\"city\":\"Hyderabad\",\"aqi\":203.95541066262123},{\"city\":\"Indore\",\"aqi\":53.77355415711368},{\"city\":\"Jaipur\",\"aqi\":142.861979325997},{\"city\":\"Chandigarh\",\"aqi\":44.35379100095008},{\"city\":\"Lucknow\",\"aqi\":75.31756776286858}]"
        AQICityDetails.parseResponse(from: testAQIString) { cityData, error in
            XCTAssertNil(error)
            XCTAssertNotNil(cityData)
            XCTAssertTrue(cityData!.count > 0)
            self.viewModel = AQICityChartViewModel(cityModel: cityData?.first!, refreshDelegate: nil)
            self.viewModel.prepareChartData()
        }
        self.viewModel.refreshCityDataToChart(with: viewModel.cityDataModel!)
        XCTAssertNotNil(self.viewModel.cityDataModel)
        XCTAssertTrue(self.viewModel.cityDataModel!.aqiHistoryData.count > 0)

    }
}
