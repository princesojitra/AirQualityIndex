//
//  AQIListViewControllerTest.swift
//  AirQualityTests
//
//  Created by Prince Sojitra on 09/01/22.
//

import XCTest
@testable import AirQuality

class AQIListViewControllerTest: XCTestCase {

    var viewController: AQIListViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let sut = storyboard.instantiateViewController(identifier: "AQIListViewController") as! AQIListViewController
        sut.loadViewIfNeeded()
        return sut
    }()

    override func setUp() {
        super.setUp()
        viewController.viewDidLoad()
        _ = viewController.viewModel?.prepareCellObjects()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testRefreshView() {
        XCTAssertNotNil(viewController.refreshScreen(withData:viewController.viewModel.prepareCellObjects()))
    }

    func testViewModelDelegate() {
        viewController.viewModel?.delegate = viewController
        XCTAssertNotNil(viewController.viewModel)
        XCTAssertNotNil(viewController.viewModel?.delegate)
        XCTAssertNotNil(viewController.viewModel?.delegate?.refreshScreen(withData: []))
    }
}
