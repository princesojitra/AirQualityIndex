//
//  AirQualityTests.swift
//  AirQualityTests
//
//  Created by Prince Sojitra on 09/01/22.
//

import XCTest
@testable import AirQuality

class AQIListViewModelTest: XCTestCase {
    var viewModel: AQIListViewModel!
    var viewController: AQIListViewController!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func setUp() {
        super.setUp()
        viewController = AQIListViewController()
        viewModel = AQIListViewModel(delegate: nil)
        _ = viewModel.prepareCellObjects()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testTableCellObject() {
        let testAQIString = "[{\"city\":\"Kolkata\",\"aqi\":201.82153891079136},{\"city\":\"Pune\",\"aqi\":222.77115965463338},{\"city\":\"Hyderabad\",\"aqi\":203.95541066262123},{\"city\":\"Indore\",\"aqi\":53.77355415711368},{\"city\":\"Jaipur\",\"aqi\":142.861979325997},{\"city\":\"Chandigarh\",\"aqi\":44.35379100095008},{\"city\":\"Lucknow\",\"aqi\":75.31756776286858}]"
        AQICityDetails.parseResponse(from: testAQIString) { cityData, error in
            XCTAssertNil(error)
            XCTAssertNotNil(cityData)
            XCTAssertTrue(cityData!.count > 0)
            XCTAssertEqual(cityData?.first!.cityName, "Kolkata")
            XCTAssertNotNil(cityData?.first?.aqiHistoryData)
            XCTAssertTrue(cityData?.first!.aqiHistoryData.count ?? 0 > 0)
            self.viewModel.citiesAQIData = cityData ?? []
            _ = self.viewModel.prepareCellObjects()
        }
        XCTAssertTrue(self.viewModel.prepareCellObjects().count > 0)
        let cell = self.viewModel.cityListItemCellObject(cityData: self.viewModel.citiesAQIData.first!)
        XCTAssertEqual(cell.airQualityIndex, 201.82153891079136)
        XCTAssertEqual(cell.airQualityCategoryColor, AQICategory.poor.color)
        XCTAssertEqual(cell.airQualityCategory, AQICategory.poor)
        viewModel.processAQIData(with: self.viewModel.citiesAQIData)
    }
}
